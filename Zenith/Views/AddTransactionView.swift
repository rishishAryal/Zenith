import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var amount: Double?
    @State private var transactionType: TransactionType = .outgoing
    @State private var selectedCategoryId: UUID?
    @State private var selectedSourceId: UUID?
    @State private var note: String = ""
    @FocusState private var isInputFocused: Bool
    
    private var filteredSources: [MoneySource] {
        if transactionType == .outgoing {
            return appViewModel.moneySources.filter { $0.includeInBudget }
        } else {
            return appViewModel.moneySources
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    typeSelector
                    sourcePicker
                    amountSection
                    categorySection
                    noteSection
                }
            }
        }
        .onAppear {
            if selectedSourceId == nil {
                selectedSourceId = filteredSources.first?.id
            }
            if selectedCategoryId == nil {
                selectedCategoryId = appViewModel.categories.first?.id
            }
        }
        .background(AppTheme.surfaceCard.opacity(0.95))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputFocused = false
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(transactionType == .outgoing ? "New Entry" : "New Income")
                .font(Font.headline(size: 20, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
            
            Spacer()
            
            Button { save() } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
        }
        .padding(.horizontal, 30)
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
    
    private var typeSelector: some View {
        Picker("Type", selection: $transactionType) {
            Text("Expense").tag(TransactionType.outgoing)
            Text("Income").tag(TransactionType.incoming)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .colorMultiply(AppTheme.primary)
        .onChange(of: transactionType) { oldValue, newValue in
            if !filteredSources.contains(where: { $0.id == selectedSourceId }) {
                selectedSourceId = filteredSources.first?.id
            }
        }
    }
    
    private var sourcePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SOURCE")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(3)
                .padding(.horizontal, 30)
            
            if appViewModel.moneySources.isEmpty {
                Text("No balance sources found. Add one in Settings.")
                    .font(Font.bodyText(size: 12))
                    .foregroundColor(AppTheme.error)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Spacer().frame(width: 18)
                        ForEach(filteredSources) { source in
                            Button {
                                selectedSourceId = source.id
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: source.icon)
                                    Text(source.name)
                                        .font(Font.bodyText(size: 12, weight: .bold))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background {
                                    if selectedSourceId == source.id {
                                        AppTheme.primaryGradient
                                    } else {
                                        AppTheme.surfaceContainer
                                    }
                                }
                                .foregroundColor(selectedSourceId == source.id ? .white : AppTheme.onSurface)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer().frame(width: 18)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("AMOUNT")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.primary)
                .tracking(3)
            
            TextField("0.00", value: $amount, format: .currency(code: selectedCurrency))
                .font(Font.headline(size: 44, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .focused($isInputFocused)
        }
        .padding(.bottom, 40)
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CATEGORY")
                .font(Font.bodyText(size: 10, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant)
                .tracking(3)
                .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer().frame(width: 10)
                    ForEach(appViewModel.categories) { category in
                        let isSelected = selectedCategoryId == category.id
                        Button {
                            withAnimation(.spring()) {
                                selectedCategoryId = category.id
                            }
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(isSelected ? AppTheme.primary : AppTheme.surfaceContainer)
                                        .shadow(color: isSelected ? AppTheme.primary.opacity(0.4) : .clear, radius: 20)
                                    
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 30))
                                        .foregroundColor(isSelected ? AppTheme.onSurface : AppTheme.onSurfaceVariant)
                                }
                                .frame(width: 64, height: 64)
                                
                                Text(category.name)
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(isSelected ? AppTheme.onSurface : AppTheme.onSurfaceVariant.opacity(0.6))
                            }
                            .opacity(isSelected ? 1.0 : 0.4)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer().frame(width: 10)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private var noteSection: some View {
        HStack {
            TextField("Add a note...", text: $note)
                .font(Font.bodyText(size: 16))
                .foregroundColor(AppTheme.onSurface)
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .focused($isInputFocused)
            
            Image(systemName: "square.and.pencil")
                .padding(.trailing, 24)
                .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.4))
        }
        .background(AppTheme.surfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }
    
    private var canSave: Bool {
        (amount ?? 0) > 0 && selectedSourceId != nil && selectedCategoryId != nil
    }
    
    private func save() {
        guard let validAmount = amount, validAmount > 0,
              let selectedSourceId = selectedSourceId,
              let selectedCategoryId = selectedCategoryId else { return }
        
        let newTransaction = Transaction(
            amount: validAmount,
            categoryId: selectedCategoryId,
            note: note.isEmpty ? nil : note,
            date: .now,
            type: transactionType,
            moneySourceId: selectedSourceId
        )
        
        Task {
            await appViewModel.addTransaction(newTransaction)
            dismiss()
        }
    }
}
