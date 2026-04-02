import SwiftUI
import SwiftData

struct SettlementDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let settlement: Settlement
    
    @State private var paymentAmount: Double?
    @State private var showingPaymentField = false
    
    var progress: Double {
        guard settlement.amount > 0 else { return 0 }
        let cleared = settlement.amount - settlement.remainingAmount
        return min(max(cleared / settlement.amount, 0), 1)
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.onSurfaceVariant)
                    }
                    
                    Spacer()
                    
                    Text("Details")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button {
                        delete()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(AppTheme.error.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Person Info
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(settlement.type == .receivable ? AppTheme.secondary.opacity(0.1) : AppTheme.tertiary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Text(settlement.personName.prefix(1).uppercased())
                                    .font(Font.headline(size: 32, weight: .black))
                                    .foregroundColor(settlement.type == .receivable ? AppTheme.secondary : AppTheme.tertiary)
                            }
                            
                            Text(settlement.personName)
                                .font(Font.headline(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.onSurface)
                            
                            Text(settlement.type == .receivable ? "OWES YOU" : "YOU OWE")
                                .font(Font.bodyText(size: 12, weight: .black))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(3)
                        }
                        
                        // Remaining Amount Card
                        VStack(spacing: 12) {
                            Text("REMAINING BALANCE")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            Text(settlement.remainingAmount, format: .currency(code: selectedCurrency))
                                .font(Font.headline(size: 48, weight: .black))
                                .foregroundColor(settlement.isCompleted ? AppTheme.secondary : AppTheme.onSurface)
                                .minimumScaleFactor(0.5)
                        }
                        .padding(.vertical, 30)
                        
                        // Progress Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("CLEARANCE PROGRESS")
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                    .tracking(2)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(Font.bodyText(size: 10, weight: .black))
                                    .foregroundColor(AppTheme.primary)
                            }
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppTheme.surfaceContainer)
                                    .frame(height: 12)
                                
                                GeometryReader { geo in
                                    Capsule()
                                        .fill(AppTheme.primaryGradient)
                                        .frame(width: geo.size.width * CGFloat(progress))
                                }
                                .frame(height: 12)
                            }
                            
                            HStack {
                                Text("Cleared: \((settlement.amount - settlement.remainingAmount).formatted(.currency(code: selectedCurrency)))")
                                Spacer()
                                Text("Total: \(settlement.amount.formatted(.currency(code: selectedCurrency)))")
                            }
                            .font(Font.bodyText(size: 12))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                        }
                        .padding(24)
                        .glassCard()
                        .padding(.horizontal)
                        
                        // Notes
                        if let notes = settlement.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("NOTES")
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                    .tracking(2)
                                
                                Text(notes)
                                    .font(Font.bodyText(size: 14))
                                    .foregroundColor(AppTheme.onSurface)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(24)
                            .glassCard()
                            .padding(.horizontal)
                        }
                        
                        // Action Button
                        if !settlement.isCompleted {
                            Button {
                                withAnimation {
                                    showingPaymentField.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Log Payment")
                                }
                                .font(Font.headline(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(AppTheme.primaryGradient)
                                .clipShape(Capsule())
                                .padding(.horizontal)
                            }
                        } else {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("SETTLEMENT COMPLETED")
                            }
                            .font(Font.headline(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.secondary)
                            .padding(.vertical, 20)
                        }
                        
                        if showingPaymentField {
                            VStack(spacing: 16) {
                                TextField("Enter amount...", value: $paymentAmount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(AppTheme.surfaceContainer)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal)
                                
                                Button(action: applyPayment) {
                                    Text("Apply Payment")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.bgSurface)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(AppTheme.onSurface)
                                        .clipShape(Capsule())
                                        .padding(.horizontal)
                                }
                                .disabled((paymentAmount ?? 0) <= 0)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func applyPayment() {
        guard let amount = paymentAmount, amount > 0 else { return }
        
        withAnimation {
            settlement.remainingAmount = max(settlement.remainingAmount - amount, 0)
            if settlement.remainingAmount <= 0 {
                settlement.isCompleted = true
            }
            showingPaymentField = false
            paymentAmount = nil
        }
    }
    
    private func delete() {
        modelContext.delete(settlement)
        dismiss()
    }
}
