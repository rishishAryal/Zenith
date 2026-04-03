import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
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
        var filtered = appViewModel.transactions
        switch filterOption {
        case .expense: filtered = filtered.filter { $0.safeType == .outgoing }
        case .income: filtered = filtered.filter { $0.safeType == .incoming }
        case .all: break
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { tx in
                let categoryName = appViewModel.categories.first(where: { $0.id == tx.categoryId })?.name ?? ""
                return categoryName.localizedCaseInsensitiveContains(searchText) ||
                (tx.note ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .newest: return filtered.sorted { $0.date > $1.date }
        case .oldest: return filtered.sorted { $0.date < $1.date }
        case .highest: return filtered.sorted { $0.amount > $1.amount }
        case .lowest: return filtered.sorted { $0.amount < $1.amount }
        }
    }
    
    private var groupedTransactions: [(Date?, [Transaction])] {
        let items = filteredAndSortedTransactions
        
        if sortOption == .highest || sortOption == .lowest {
            return [(nil, items)]
        } else {
            let grouped = Dictionary(grouping: items) { transaction in
                Calendar.current.startOfDay(for: transaction.date)
            }
            let array: [(Date?, [Transaction])] = grouped.map { ($0.key, $0.value) }
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
                
                Picker("Tab", selection: $selectedTab) {
                    ForEach(TransactionTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                .colorMultiply(AppTheme.primary)
                
                VStack(spacing: 12) {
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
                .environmentObject(appViewModel)
                .presentationDetents([.fraction(0.85)])
                .presentationBackground(.ultraThinMaterial)
        }
        .refreshable {
            await appViewModel.refresh(categories: [.transactions, .plannedTransactions])
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
                    .padding(.bottom, 120)
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
    @EnvironmentObject var appViewModel: AppViewModel
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let transaction: Transaction
    @State private var isDeleted = false
    
    private var source: MoneySource? {
        appViewModel.moneySources.first(where: { $0.id == transaction.moneySourceId })
    }
    
    private var category: Category? {
        appViewModel.categories.first(where: { $0.id == transaction.categoryId })
    }
    
    var body: some View {
        if !isDeleted {
            HStack(spacing: 20) {
                let icon = category?.iconName ?? "tag.fill"
                let color = Color(hex: category?.colorHex ?? "#9E9E9E")
                
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
                    Text(category?.name ?? "Other")
                        .font(Font.headline(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 8))
                        Text(source?.name.uppercased() ?? "NO SOURCE")
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
        withAnimation(.easeOut) {
            isDeleted = true
        }
        
        Task {
            await appViewModel.deleteTransaction(transaction)
        }
    }
}
