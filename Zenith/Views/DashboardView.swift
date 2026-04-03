import SwiftUI
import Charts
import Combine

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    private var totalSpent: Double {
        let includedSourceIds = Set(appViewModel.moneySources.filter { $0.includeInBudget }.map { $0.id })
        return appViewModel.transactions.filter { 
            $0.safeType == .outgoing && includedSourceIds.contains($0.moneySourceId)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalSubscriptionsAmount: Double {
        appViewModel.subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    private var availableMonthlyBudget: Double {
        let currentBalance = appViewModel.moneySources.filter { $0.includeInBudget }.reduce(0) { $0 + $1.balance }
        return max(currentBalance + totalSpent - totalSubscriptionsAmount, 0)
    }
    
    private var progress: Double {
        guard availableMonthlyBudget > 0 else { return 0 }
        let ratio = totalSpent / availableMonthlyBudget
        return min(max(ratio, 0), 1)
    }
    
    private var remaining: Double {
        appViewModel.moneySources.filter { $0.includeInBudget }.reduce(0) { $0 + $1.balance } - totalSubscriptionsAmount
    }

    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
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
                        HeroRing(
                            totalSpent: totalSpent,
                            remaining: remaining,
                            progress: progress,
                            currency: selectedCurrency
                        )
                        .padding(.top, 20)
                        
                        if !appViewModel.goals.isEmpty || !appViewModel.subscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("WEALTH OVERVIEW")
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                    .tracking(2)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(appViewModel.goals) { goal in
                                            NavigationLink(destination: SavingsGoalsView(isNavigated: true).environmentObject(appViewModel)) {
                                                DashboardGoalCard(goal: goal, currency: selectedCurrency)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        if !appViewModel.subscriptions.isEmpty {
                                            NavigationLink(destination: SubscriptionsView().environmentObject(appViewModel)) {
                                                DashboardSubscriptionCard(count: appViewModel.subscriptions.count, total: totalSubscriptionsAmount, currency: selectedCurrency)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        VStack(spacing: 20) {
                            let outgoing = appViewModel.transactions.filter({ $0.safeType == .outgoing })
                            
                            if !outgoing.isEmpty {
                                EquityPulseChart(transactions: outgoing, currency: selectedCurrency, categories: appViewModel.categories)
                            }
                            
                            let grouped = Dictionary(grouping: outgoing) { $0.categoryId }
                            let topCategories = grouped.map { (key, value) in
                                (categoryId: key, amount: value.reduce(0) { $0 + $1.amount })
                            }.sorted { $0.amount > $1.amount }
                            
                            if !topCategories.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    ForEach(topCategories, id: \.categoryId) { item in
                                        if let cat = appViewModel.categories.first(where: { $0.id == item.categoryId }) {
                                            NavigationLink(destination: CategoryDetailView(category: cat).environmentObject(appViewModel)) {
                                                InsightCard(icon: cat.iconName, title: cat.name, amount: item.amount, currency: selectedCurrency, color: Color(hex: cat.colorHex))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 180)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            await appViewModel.refresh(categories: [.transactions, .moneySources, .budgets, .goals, .subscriptions])
        }
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
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(AppTheme.surfaceContainer, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(90))
            
            Circle()
                .trim(from: 0.1, to: 0.1 + (animationProgress * 0.8))
                .stroke(
                    AppTheme.primaryGradient,
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .shadow(color: AppTheme.primary.opacity(0.4), radius: 15, x: 0, y: 0)
            
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
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animationProgress = newValue
            }
        }
    }
}

struct EquityPulseChart: View {
    let transactions: [Transaction]
    let currency: String
    let categories: [Category]
    
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
                
                PointMark(
                    x: .value("Date", transaction.date),
                    y: .value("Amount", transaction.amount)
                )
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .annotation(position: .top, spacing: 4) {
                    let catName = categories.first(where: { $0.id == transaction.categoryId })?.name ?? "..."
                    Text(catName.prefix(4).uppercased())
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
