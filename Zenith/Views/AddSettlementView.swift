import SwiftUI
import SwiftData

struct AddSettlementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var personName = ""
    @State private var amount: Double?
    @State private var type: SettlementType = .receivable
    @State private var notes = ""
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 32) {
                HStack {
                    Text("New Settlement")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    Spacer()
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PERSON NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("Who is it?", text: $personName)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TOTAL AMOUNT")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("0.00", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SETTLEMENT TYPE")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        Picker("Type", selection: $type) {
                            ForEach(SettlementType.allCases, id: \.self) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .colorMultiply(AppTheme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADDITIONAL NOTES")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("Any detail...", text: $notes)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer()
                
                Button(action: save) {
                    Text("Register Settlement")
                        .font(Font.headline(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppTheme.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                }
                .disabled(personName.isEmpty || (amount ?? 0) <= 0)
                .opacity(personName.isEmpty || (amount ?? 0) <= 0 ? 0.5 : 1)
            }
            .padding(24)
        }
    }
    
    private func save() {
        guard let validAmount = amount, validAmount > 0 else { return }
        let settlement = Settlement(personName: personName, amount: validAmount, type: type, notes: notes.isEmpty ? nil : notes)
        modelContext.insert(settlement)
        dismiss()
    }
}
