import SwiftUI

struct PlannedFlowView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    let searchText: String
    let filterOption: TransactionsView.FilterOption
    
    private var filteredItems: [PlannedTransaction] {
        var filtered = appViewModel.plannedTransactions
        
        switch filterOption {
        case .expense: filtered = filtered.filter { $0.safeType == .outgoing }
        case .income: filtered = filtered.filter { $0.safeType == .incoming }
        case .all: break
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                let catName = appViewModel.categories.first(where: { $0.id == item.categoryId })?.name ?? ""
                return catName.localizedCaseInsensitiveContains(searchText) ||
                       (item.note ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        Group {
            if filteredItems.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
                    Text("No Planned Items")
                        .font(Font.bodyText(size: 16))
                        .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredItems) { item in
                            PlannedTransactionRow(item: item)
                                .environmentObject(appViewModel)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

struct PlannedTransactionRow: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @AppStorage("currency") private var selectedCurrency = "USD"
    let item: PlannedTransaction
    
    @State private var isSettling = false
    @State private var showingSourcePicker = false
    
    var body: some View {
        HStack(spacing: 16) {
            let cat = appViewModel.categories.first(where: { $0.id == item.categoryId })
            let icon = cat?.iconName ?? "tag.fill"
            let color = Color(hex: cat?.colorHex ?? "#9E9E9E")
            
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cat?.name ?? "Other")
                    .font(Font.headline(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                
                Text(item.dueDate.formatted(.dateTime.day().month().year()))
                    .font(Font.bodyText(size: 12))
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(item.safeType == .incoming ? "+" : "-")\(item.amount.formatted(.currency(code: selectedCurrency)))")
                    .font(Font.headline(size: 18, weight: .heavy))
                    .foregroundColor(item.safeType == .outgoing ? AppTheme.onSurface : AppTheme.secondary)
                
                Button(action: { showingSourcePicker = true }) {
                    HStack(spacing: 4) {
                        if isSettling {
                            ProgressView().tint(.white).scaleEffect(0.7)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text(item.safeType == .outgoing ? "PAID" : "RCVD")
                        }
                    }
                    .font(Font.bodyText(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(item.safeType == .outgoing ? AppTheme.primaryGradient : AppTheme.secondaryGradient)
                    .clipShape(Capsule())
                }
                .disabled(isSettling)
            }
        }
        .padding(16)
        .glassCard()
        .confirmationDialog("Settle Planned Flow", isPresented: $showingSourcePicker, titleVisibility: .visible) {
            ForEach(appViewModel.moneySources) { source in
                Button(source.name) {
                    settle(into: source.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select the source account for this \(item.safeType == .outgoing ? "expense" : "income").")
        }
        .contextMenu {
            Button(role: .destructive) {
                Task {
                    await appViewModel.deletePlannedTransaction(item)
                }
            } label: {
                Label("Remove Plan", systemImage: "trash")
            }
        }
    }
    
    private func settle(into sourceId: UUID) {
        withAnimation {
            isSettling = true
        }
        
        Task {
            let transaction = Transaction(
                amount: item.amount,
                categoryId: item.categoryId ?? UUID(), // Fallback if needed
                note: item.note,
                date: .now,
                type: item.safeType,
                moneySourceId: sourceId
            )
            await appViewModel.addTransaction(transaction)
            await appViewModel.deletePlannedTransaction(item)
            isSettling = false
        }
    }
}
