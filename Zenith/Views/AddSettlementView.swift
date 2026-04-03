import SwiftUI
import SwiftData

struct AddSettlementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var personName = ""
    @State private var amount: Double?
    @State private var type: SettlementType = .receivable
    @State private var notes = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            LivingBackground()
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack(spacing: 32) {
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Settlement")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button("Register") { save() }
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                        .disabled(personName.isEmpty || (amount ?? 0) <= 0)
                        .opacity(personName.isEmpty || (amount ?? 0) <= 0 ? 0.5 : 1)
                }
                .padding(.top, 10)
                Spacer().frame(height: 20)
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PERSON NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("Who is it?", text: $personName)
                            .focused($isInputFocused)
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
                            .focused($isInputFocused)
                            .keyboardType(.decimalPad)
                            .lineLimit(1)
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
                            .focused($isInputFocused)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                Spacer()
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
    }
    
    private func save() {
        guard let validAmount = amount, validAmount > 0 else { return }
        let settlement = Settlement(personName: personName, amount: validAmount, type: type, notes: notes.isEmpty ? nil : notes)
        modelContext.insert(settlement)
        dismiss()
    }
}
