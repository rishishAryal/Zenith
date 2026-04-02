import SwiftUI
import SwiftData

struct PlannedFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlannedTransaction.dueDate, order: .forward) private var plannedItems: [PlannedTransaction]
    
    let searchText: String
    let filterOption: TransactionsView.FilterOption
    
    private var filteredItems: [PlannedTransaction] {
        var filtered = plannedItems
        
        // Filter by type
        switch filterOption {
        case .expense: filtered = filtered.filter { $0.safeType == .outgoing }
        case .income: filtered = filtered.filter { $0.safeType == .incoming }
        case .all: break
        }
        
        // Filter by search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.note ?? "").localizedCaseInsensitiveContains(searchText)
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
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currency") private var selectedCurrency = "USD"
    let item: PlannedTransaction
    
    @State private var isSettling = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            let (icon, color) = iconAndColor(for: item.category)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.category)
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
                
                Button(action: settle) {
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
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(item)
            } label: {
                Label("Remove Plan", systemImage: "trash")
            }
        }
    }
    
    private func settle() {
        withAnimation {
            isSettling = true
        }
        
        // Delay slightly for effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let transaction = Transaction(
                amount: item.amount,
                category: item.category,
                note: item.note,
                date: .now,
                type: item.safeType
            )
            modelContext.insert(transaction)
            modelContext.delete(item)
        }
    }
    
    private func iconAndColor(for category: String) -> (String, Color) {
        switch category {
        case "Food", "Dining": return ("fork.knife", AppTheme.secondary)
        case "Travel": return ("airplane", AppTheme.tertiary)
        case "Subscriptions", "Media": return ("sparkles", AppTheme.primaryDim)
        case "Shopping", "Electronics": return ("bag.fill", AppTheme.primary)
        case "Utilities": return ("bolt.fill", AppTheme.secondaryDim)
        case "Health": return ("heart.fill", AppTheme.error)
        default: return ("tag.fill", AppTheme.primary)
        }
    }
}
