import SwiftUI
import SwiftData

struct AddPlannedTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var amount: Double = 0
    @State private var transactionType: TransactionType = .outgoing
    @State private var selectedCategory: String = "Shop"
    @State private var note: String = ""
    @State private var dueDate: Date = .now
    
    let categories = [
        ("Shop", "cart.fill"),
        ("Dining", "fork.knife"),
        ("Travel", "airplane"),
        ("Media", "play.tv.fill"),
        ("Utilities", "bolt.fill"),
        ("Health", "heart.fill")
    ]
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 32) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        typeSelector
                        amountSection
                        dateSection
                        categorySection
                        noteSection
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                saveButton
            }
            .padding(24)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Plan Future Flow")
                .font(Font.headline(size: 24, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
            
            Spacer()
            
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.onSurfaceVariant)
        }
    }
    
    private var typeSelector: some View {
        Picker("Type", selection: $transactionType) {
            Text("Planned Expense").tag(TransactionType.outgoing)
            Text("Planned Income").tag(TransactionType.incoming)
        }
        .pickerStyle(.segmented)
        .colorMultiply(AppTheme.primary)
    }
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXPECTED AMOUNT")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(2)
            
            TextField("0", value: $amount, format: .number)
                .keyboardType(.decimalPad)
                .font(Font.headline(size: 32, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
                .padding()
                .background(AppTheme.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TARGET DATE")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(2)
            
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(AppTheme.primary)
                .padding()
                .background(AppTheme.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORY")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.0) { cat in
                        CategoryItem(cat: cat, isSelected: selectedCategory == cat.0) {
                            selectedCategory = cat.0
                        }
                    }
                }
            }
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOTES (OPTIONAL)")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(2)
            
            TextField("e.g. Electricity, Bonus...", text: $note)
                .padding()
                .background(AppTheme.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var saveButton: some View {
        Button(action: savePlan) {
            Text("Add to Planned Flow")
                .font(Font.headline(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(AppTheme.primaryGradient)
                .clipShape(Capsule())
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
        }
        .disabled(amount <= 0)
        .opacity(amount <= 0 ? 0.5 : 1)
    }
    
    private func savePlan() {
        let plan = PlannedTransaction(
            amount: amount,
            category: selectedCategory,
            note: note.isEmpty ? nil : note,
            dueDate: dueDate,
            type: transactionType
        )
        modelContext.insert(plan)
        dismiss()
    }
}

// Sub-component to reduce complexity
struct CategoryItem: View {
    let cat: (String, String)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: cat.1)
                    .font(.title2)
                Text(cat.0)
                    .font(Font.bodyText(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.onSurfaceVariant)
            .frame(width: 70, height: 70)
            .background(isSelected ? AnyView(AppTheme.primaryGradient) : AnyView(AppTheme.surfaceContainer))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
