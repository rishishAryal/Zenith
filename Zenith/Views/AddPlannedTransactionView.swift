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
    @FocusState private var isInputFocused: Bool
    
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
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack(spacing: 32) {
                header
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        typeSelector
                        amountSection
                        dateSection
                        categorySection
                        noteSection
                    }
                }
            }
            .padding(24)
            .onAppear {
                if amount <= 0 { amount = 0 }
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
}

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.onSurfaceVariant)
                .font(.headline)
            
            Spacer()
            
            Text("Plan Flow")
                .font(Font.headline(size: 20, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
            
            Spacer()
            
            Button("Add") { savePlan() }
                .font(.headline)
                .foregroundColor(AppTheme.primary)
                .disabled(amount <= 0)
                .opacity(amount <= 0 ? 0.5 : 1)
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
                .lineLimit(1)
                .focused($isInputFocused)
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
                .focused($isInputFocused)
                .padding()
                .background(AppTheme.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
