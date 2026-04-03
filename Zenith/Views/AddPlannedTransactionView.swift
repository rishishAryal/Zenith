import SwiftUI

struct AddPlannedTransactionView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var amount: Double = 0
    @State private var transactionType: TransactionType = .outgoing
    @State private var selectedCategoryId: UUID?
    @State private var note: String = ""
    @State private var dueDate: Date = .now
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            LivingBackground()
            
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
                if selectedCategoryId == nil {
                    selectedCategoryId = appViewModel.categories.first?.id
                }
            }
            .onTapGesture {
                isInputFocused = false
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
                .disabled(amount <= 0 || selectedCategoryId == nil)
                .opacity(amount <= 0 || selectedCategoryId == nil ? 0.5 : 1)
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
                    ForEach(appViewModel.categories) { cat in
                        CategoryPlannedItem(cat: cat, isSelected: selectedCategoryId == cat.id) {
                            selectedCategoryId = cat.id
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
        guard let catId = selectedCategoryId else { return }
        
        Task {
            let plan = PlannedTransaction(
                amount: amount,
                categoryId: catId,
                note: note.isEmpty ? nil : note,
                dueDate: dueDate,
                type: transactionType
            )
            await appViewModel.addPlannedTransaction(plan)
            dismiss()
        }
    }
}

struct CategoryPlannedItem: View {
    let cat: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: cat.iconName)
                    .font(.title2)
                Text(cat.name)
                    .font(Font.bodyText(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.onSurfaceVariant)
            .frame(width: 80, height: 80)
            .background(isSelected ? AnyView(AppTheme.primaryGradient) : AnyView(AppTheme.surfaceContainer))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
