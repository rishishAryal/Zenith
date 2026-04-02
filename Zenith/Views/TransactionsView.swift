import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest
    @State private var filterOption: FilterOption = .all
    @State private var selectedTab: TransactionTab = .history
    @State private var showingAddPlanned = false
    
    enum TransactionTab: String, CaseIterable, Identifiable {
        case history = "Settled"
        case planned = "Planned Flow"
        var id: Self { self }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case newest = "Newest"
        case oldest = "Oldest"
        case highest = "Highest Amount"
        case lowest = "Lowest Amount"
        var id: Self { self }
    }
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case expense = "Expenses"
        case income = "Income"
        var id: Self { self }
    }
    
    private var filteredAndSortedTransactions: [Transaction] {
        var filtered = transactions
        switch filterOption {
        case .expense: filtered = filtered.filter { $0.safeType == .outgoing }
        case .income: filtered = filtered.filter { $0.safeType == .incoming }
        case .all: break
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                ($0.note ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .newest: return filtered.sorted { $0.date > $1.date }
        case .oldest: return filtered.sorted { $0.date < $1.date }
        case .highest: return filtered.sorted { $0.amount > $1.amount }
        case .lowest: return filtered.sorted { $0.amount < $1.amount }
        }
    }
    
    // Group transactions by Date if applicable
    private var groupedTransactions: [(Date?, [Transaction])] {
        let items = filteredAndSortedTransactions
        
        if sortOption == .highest || sortOption == .lowest {
            return [(nil, items)]
        } else {
            let grouped = Dictionary(grouping: items) { transaction in
                Calendar.current.startOfDay(for: transaction.date)
            }
            let array: [(Date?, [Transaction])] = grouped.map { ($0.key, $0.value) }
            // For newest, descending. For oldest, ascending.
            if sortOption == .newest {
                return array.sorted { ($0.0 ?? Date.distantPast) > ($1.0 ?? Date.distantPast) }
            } else {
                return array.sorted { ($0.0 ?? Date.distantPast) < ($1.0 ?? Date.distantPast) }
            }
        }
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Custom Header over glass
                HStack {
                    Text("Transactions")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Text("Zenith")
                        .font(Font.headline(size: 24, weight: .black))
                        .foregroundStyle(AppTheme.primaryGradient)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Tab Picker
                Picker("Tab", selection: $selectedTab) {
                    ForEach(TransactionTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                .colorMultiply(AppTheme.primary)
                
                // Filter and Search Toolbar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.onSurfaceVariant)
                        TextField("Search notes or categories...", text: $searchText)
                            .foregroundColor(AppTheme.onSurface)
                    }
                    .padding(12)
                    .background(AppTheme.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top)
                    
                    // Filters & Add Button
                    HStack {
                        Menu {
                            Picker("Filter", selection: $filterOption) {
                                ForEach(FilterOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(filterOption.rawValue)
                            }
                            .font(Font.bodyText(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if selectedTab == .planned {
                            Button(action: { showingAddPlanned = true }) {
                                HStack {
                                    Image(systemName: "clock.badge.plus")
                                    Text("NEW PLAN")
                                }
                                .font(Font.bodyText(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.primaryGradient)
                                .clipShape(Capsule())
                                .shadow(color: AppTheme.primary.opacity(0.3), radius: 10)
                            }
                        } else {
                            Menu {
                                Picker("Sort", selection: $sortOption) {
                                    ForEach(SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(sortOption.rawValue)
                                    Image(systemName: "arrow.up.arrow.down")
                                }
                                .font(Font.bodyText(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.surfaceContainer)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                if selectedTab == .history {
                    historyListView
                } else {
                    PlannedFlowView(searchText: searchText, filterOption: filterOption)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddPlanned) {
            AddPlannedTransactionView()
                .presentationDetents([.fraction(0.85)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
    
    private var historyListView: some View {
        Group {
            if filteredAndSortedTransactions.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
                    Text("No Transactions Yet")
                        .font(Font.bodyText(size: 16))
                        .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(groupedTransactions, id: \.0) { dateGroup, dayTransactions in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    if let date = dateGroup {
                                        Text(dateLabel(for: date).uppercased())
                                            .font(Font.bodyText(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.onSurfaceVariant)
                                            .tracking(2)
                                        
                                        Spacer()
                                        
                                        Text(date.formatted(.dateTime.day().month()))
                                            .font(Font.bodyText(size: 10, weight: .bold))
                                            .foregroundColor(AppTheme.outline)
                                            .tracking(2)
                                    } else {
                                        Text("RESULTS")
                                            .font(Font.bodyText(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.onSurfaceVariant)
                                            .tracking(2)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(dayTransactions) { transaction in
                                        TransactionRow(transaction: transaction)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .padding(.bottom, 120) // padding for custom tab bar
                }
            }
        }
    }

    
    private func dateLabel(for date: Date?) -> String {
        guard let validDate = date else { return "All" }
        if Calendar.current.isDateInToday(validDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(validDate) {
            return "Yesterday"
        } else {
            return validDate.formatted(.dateTime.weekday(.wide))
        }
    }
}

struct TransactionRow: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currency") private var selectedCurrency = "USD"
    @Query private var sources: [MoneySource]
    
    let transaction: Transaction
    @State private var isDeleted = false
    
    private var sourceName: String {
        sources.first(where: { $0.id == transaction.sourceId })?.name ?? "No Source"
    }
    
    var body: some View {
        if !isDeleted {
            HStack(spacing: 20) {
                // Icon based on category
                let (icon, color) = iconAndColor(for: transaction.category)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
                        .shadow(color: color.opacity(0.15), radius: 10, x: 0, y: 0)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.category)
                        .font(Font.headline(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 8))
                        Text(sourceName.uppercased())
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.7))
                    
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                            .font(Font.bodyText(size: 14))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(transaction.date.formatted(.dateTime.hour().minute()))
                        .font(Font.bodyText(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                    
                    Text("\(transaction.safeType == .incoming ? "+" : "-")\(transaction.amount.formatted(.currency(code: selectedCurrency)))")
                        .font(Font.headline(size: 20, weight: .heavy))
                        .foregroundColor(transaction.safeType == .outgoing ? AppTheme.onSurface : AppTheme.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    if transaction.safeType == .outgoing {
                        Text("DEBIT")
                            .font(Font.bodyText(size: 8, weight: .bold))
                            .foregroundColor(AppTheme.primary.opacity(0.6))
                            .tracking(2)
                    } else {
                        Text("SETTLED")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.secondary.opacity(0.6))
                            .tracking(2)
                    }
                }
                
                // Add Trash Button
                Button(action: delete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.error.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .glassCard()
        }
    }
    
    private func delete() {
        // Revert balance before deletion
        if let source = sources.first(where: { $0.id == transaction.sourceId }) {
            if transaction.safeType == .outgoing {
                source.balance += transaction.amount
            } else {
                source.balance -= transaction.amount
            }
        }
        
        withAnimation(.easeOut) {
            isDeleted = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            modelContext.delete(transaction)
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
