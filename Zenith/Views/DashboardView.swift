import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var transactions: [Transaction]
    @Query private var subscriptions: [Subscription]
    @Query private var goals: [SavingsGoal]
    @Query private var sources: [MoneySource]
    @Query private var categories: [Category]
    
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    // Sum of outgoing expenses from currently included sources for this month
    private var totalSpent: Double {
        // We filter transactions that were deducted from "Included" sources
        let includedSourceIds = Set(sources.filter { $0.includeInBudget }.map { $0.id })
        return transactions.filter { 
            $0.safeType == .outgoing && includedSourceIds.contains($0.sourceId ?? UUID())
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalSubscriptionsAmount: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    // The "Total Budget" is the current liquid wealth in included sources + what we've already spent
    private var availableMonthlyBudget: Double {
        let currentBalance = sources.filter { $0.includeInBudget }.reduce(0) { $0 + $1.balance }
        return max(currentBalance + totalSpent - totalSubscriptionsAmount, 0)
    }
    
    private var progress: Double {
        guard availableMonthlyBudget > 0 else { return 0 }
        let ratio = totalSpent / availableMonthlyBudget
        return min(max(ratio, 0), 1)
    }
    
    private var remaining: Double {
        sources.filter { $0.includeInBudget }.reduce(0) { $0 + $1.balance } - totalSubscriptionsAmount
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LivingBackground()
                
                VStack(spacing: 0) {
                    // Top Navigation Header
                    HStack {
                        Text("Zenith")
                            .font(Font.headline(size: 24, weight: .black))
                            .foregroundStyle(AppTheme.primaryGradient)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                        
                        // Hero Ring
                        HeroRing(
                            totalSpent: totalSpent,
                            remaining: remaining,
                            progress: progress,
                            currency: selectedCurrency
                        )
                        .padding(.top, 20)
                        
                        // Wealth Overview Section (New)
                        if !goals.isEmpty || !subscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("WEALTH OVERVIEW")
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                    .tracking(2)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        // Savings Goals Cards
                                        ForEach(goals) { goal in
                                            NavigationLink(destination: SavingsGoalsView(isNavigated: true)) {
                                                DashboardGoalCard(goal: goal, currency: selectedCurrency)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        // Subscriptions Summary Card
                                        if !subscriptions.isEmpty {
                                            NavigationLink(destination: SubscriptionsView()) {
                                                DashboardSubscriptionCard(count: subscriptions.count, total: totalSubscriptionsAmount, currency: selectedCurrency)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Bento Insights
                        VStack(spacing: 20) {
                            if !transactions.filter({ $0.safeType == .outgoing }).isEmpty {
                                EquityPulseChart(transactions: transactions.filter({ $0.safeType == .outgoing }), currency: selectedCurrency)
                            }
                            
                            let outgoing = transactions.filter({ $0.safeType == .outgoing })
                            let grouped = Dictionary(grouping: outgoing) { $0.category }
                            let topCategories = grouped.map { (key, value) in
                                (category: key, amount: value.reduce(0) { $0 + $1.amount })
                            }.sorted { $0.amount > $1.amount }
                            
                            if !topCategories.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    ForEach(Array(topCategories), id: \.category) { item in
                                        NavigationLink(destination: CategoryDetailView(categoryName: item.category)) {
                                            let meta = iconAndColor(for: item.category)
                                            InsightCard(icon: meta.0, title: item.category, amount: item.amount, currency: selectedCurrency, color: meta.1)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            // Removed manual Transfer Wealth button as per specification
                        }
                        .padding(.horizontal)
                        
                        
                        // Bottom Padding for custom tab bar + Floating Action Button
                        Spacer().frame(height: 180)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
    
    private func iconAndColor(for categoryName: String) -> (String, Color) {
        if let category = categories.first(where: { $0.name.lowercased() == categoryName.lowercased() }) {
            return (category.iconName, Color(hex: category.colorHex))
        }
        // Fallback to General if it exists
        if let general = categories.first(where: { $0.name == "General" }) {
            return (general.iconName, Color(hex: general.colorHex))
        }
        return ("tag.fill", AppTheme.primary)
    }
}

// Subcomponents for Dashboard
struct HeroRing: View {
    let totalSpent: Double
    let remaining: Double
    let progress: Double
    let currency: String
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(AppTheme.surfaceContainer, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(90))
            
            // Progress track
            Circle()
                .trim(from: 0.1, to: 0.1 + (animationProgress * 0.8))
                .stroke(
                    AppTheme.primaryGradient,
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .shadow(color: AppTheme.primary.opacity(0.4), radius: 15, x: 0, y: 0)
            
            // Inner Text
            VStack(spacing: 8) {
                Text("CURRENT SPEND")
                    .font(Font.bodyText(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .tracking(3)
                
                Text(totalSpent, format: .currency(code: currency))
                    .font(Font.headline(size: 48, weight: .heavy))
                    .foregroundStyle(AppTheme.onSurface)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.secondary)
                        .frame(width: 8, height: 8)
                        .shadow(color: AppTheme.secondary, radius: 8)
                    Text("\(remaining.formatted(.currency(code: currency))) REMAINING")
                        .font(Font.bodyText(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.secondary.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.secondary.opacity(0.2), lineWidth: 1))
            }
        }
        .frame(width: 330, height: 330)
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animationProgress = progress
            }
        }
    }
}

struct EquityPulseChart: View {
    let transactions: [Transaction]
    let currency: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Expenses")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    Text("Tracked over last 10 transactions")
                        .font(Font.bodyText(size: 12))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                Spacer()
                // Removed static +12.4% text to avoid confusion with expenses
            }
            
            let sortedTransactions = Array(transactions.sorted { $0.date < $1.date }.suffix(10))
            
            Chart(sortedTransactions) { transaction in
                LineMark(
                    x: .value("Date", transaction.date),
                    y: .value("Amount", transaction.amount)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(AppTheme.secondary)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                
                // Added annotation to satisfy user request "add labels so its clear"
                PointMark(
                    x: .value("Date", transaction.date),
                    y: .value("Amount", transaction.amount)
                )
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .annotation(position: .top, spacing: 4) {
                    Text(transaction.category.prefix(4).uppercased())
                        .font(Font.bodyText(size: 8, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                
                AreaMark(
                    x: .value("Date", transaction.date),
                    y: .value("Amount", transaction.amount)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.secondary.opacity(0.2), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 120)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
        .padding(24)
        .glassCard()
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let amount: Double
    let currency: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.title3)
                    )
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(Font.bodyText(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .tracking(2)
                
                Text(amount, format: .currency(code: currency))
                    .font(Font.headline(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
            }
        }
        .padding(20)
        .glassCard()
    }
}

// Compact Wealth Cards for Dashboard
struct DashboardGoalCard: View {
    let goal: SavingsGoal
    let currency: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: goal.colorHex).opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: goal.icon)
                        .font(.caption)
                        .foregroundColor(Color(hex: goal.colorHex))
                }
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(Font.bodyText(size: 10, weight: .heavy))
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(Font.headline(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                Text(goal.currentAmount, format: .currency(code: currency))
                    .font(Font.bodyText(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.surfaceContainer)
                    .frame(height: 4)
                
                GeometryReader { geo in
                    Capsule()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geo.size.width * CGFloat(goal.progress))
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(width: 150)
        .glassCard()
    }
}

struct DashboardSubscriptionCard: View {
    let count: Int
    let total: Double
    let currency: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count) FIXED COSTS")
                    .font(Font.bodyText(size: 8, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .tracking(1)
                Text(total, format: .currency(code: currency))
                    .font(Font.headline(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }
        }
        .padding(16)
        .glassCard()
    }
}
