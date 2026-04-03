import SwiftUI
import Combine

struct LogPaymentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let settlement: Settlement
    
    @State private var amount: Double?
    @State private var selectedSourceId: UUID?
    @State private var notes: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var isSaving = false
    
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
                    
                    Button {
                        savePayment()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(AppTheme.primary)
                        } else {
                            Text("Apply")
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .disabled((amount ?? 0) <= 0 || selectedSourceId == nil || isSaving)
                    .opacity(((amount ?? 0) <= 0 || selectedSourceId == nil || isSaving) ? 0.5 : 1)
                }
                .padding(.top, 10)
                
                if let error = appViewModel.errorMessage {
                    Text(error)
                        .font(Font.bodyText(size: 14))
                        .foregroundColor(AppTheme.error)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
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
                            HStack {
                                Text("SOURCE ACCOUNT")
                                Spacer()
                                if appViewModel.moneySources.isEmpty {
                                    Text("Add a source first")
                                        .font(Font.bodyText(size: 10, weight: .bold))
                                        .foregroundColor(AppTheme.error)
                                }
                            }
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                            
                            Picker("Select Source", selection: $selectedSourceId) {
                                if appViewModel.moneySources.isEmpty {
                                    Text("No Accounts Found").tag(nil as UUID?)
                                } else {
                                    Text("Select Account").tag(nil as UUID?)
                                }
                                ForEach(appViewModel.moneySources) { source in
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
                            .background(appViewModel.moneySources.isEmpty ? AppTheme.error.opacity(0.1) : AppTheme.surfaceContainer)
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
            amount = settlement.remainingAmount
            if selectedSourceId == nil {
                selectedSourceId = appViewModel.moneySources.first?.id
            }
            appViewModel.errorMessage = nil
        }
    }
    
    private func savePayment() {
        guard let validAmount = amount, validAmount > 0, let sourceId = selectedSourceId else { return }
        
        isSaving = true
        Task {
            await appViewModel.paySettlement(settlement, amount: validAmount, moneySourceId: sourceId)
            isSaving = false
            if appViewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}
