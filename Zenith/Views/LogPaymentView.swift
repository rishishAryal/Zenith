import SwiftUI
import SwiftData

struct LogPaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    @Query(sort: \MoneySource.name) private var sources: [MoneySource]
    @Query private var categories: [Category]
    
    let settlement: Settlement
    
    @State private var amount: Double?
    @State private var selectedSourceId: UUID?
    @State private var notes: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            LivingBackground()
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button("Close") { dismiss() }
                        .font(.headline)
                        .foregroundColor(AppTheme.onSurfaceVariant)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Log Payment")
                            .font(Font.headline(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.onSurface)
                        
                        Text(settlement.personName)
                            .font(Font.bodyText(size: 12))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                    }
                    
                    Spacer()
                    
                    Button("Apply") { savePayment() }
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                        .disabled((amount ?? 0) <= 0 || selectedSourceId == nil)
                        .opacity(((amount ?? 0) <= 0 || selectedSourceId == nil) ? 0.5 : 1)
                }
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Card
                        VStack(spacing: 12) {
                            Text("REMAINING BALANCE")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            Text(settlement.remainingAmount, format: .currency(code: selectedCurrency))
                                .font(Font.headline(size: 36, weight: .black))
                                .foregroundColor(AppTheme.onSurface)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .glassCard()
                        
                        // Amount Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PAYMENT AMOUNT")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            TextField("0.00", value: $amount, format: .number)
                                .focused($isInputFocused)
                                .keyboardType(.decimalPad)
                                .font(Font.headline(size: 24, weight: .bold))
                                .lineLimit(1)
                                .padding()
                                .background(AppTheme.surfaceContainer)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Source Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SOURCE ACCOUNT")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            Picker("Select Source", selection: $selectedSourceId) {
                                Text("Select Account").tag(nil as UUID?)
                                ForEach(sources) { source in
                                    HStack {
                                        Image(systemName: source.icon)
                                        Text(source.name)
                                    }
                                    .tag(source.id as UUID?)
                                }
                            }
                            .tint(AppTheme.onSurface)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NOTES (OPTIONAL)")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            TextField("What's this for?", text: $notes)
                                .focused($isInputFocused)
                                .padding()
                                .background(AppTheme.surfaceContainer)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
            }
            .padding(24)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputFocused = false
                }
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)
            }
        }
        .onAppear {
            // Default to full remaining amount
            amount = settlement.remainingAmount
            // Default to first source if available
            if selectedSourceId == nil {
                selectedSourceId = sources.first?.id
            }
        }
    }
    
    private func savePayment() {
        guard let validAmount = amount, validAmount > 0, let sourceId = selectedSourceId else { return }
        
        // 1. Update Settlement
        settlement.remainingAmount = max(settlement.remainingAmount - validAmount, 0)
        if settlement.remainingAmount <= 0 {
            settlement.isCompleted = true
        }
        
        // 2. Update MoneySource Balance
        if let source = sources.first(where: { $0.id == sourceId }) {
            if settlement.type == .payable {
                source.balance -= validAmount // I paid someone
            } else {
                source.balance += validAmount // Someone paid me
            }
            
            // 3. Create Transaction for History
            let transaction = Transaction(
                amount: validAmount,
                category: "Settlement",
                note: "Payment to/from \(settlement.personName): \(notes)",
                date: .now,
                type: settlement.type == .payable ? .outgoing : .incoming,
                sourceId: sourceId
            )
            modelContext.insert(transaction)
        }
        
        dismiss()
    }
}
