import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subscription.billingDay) private var subscriptions: [Subscription]
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var showingAddSheet = false
    
    var totalMonthlySpent: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.onSurface)
                            .padding(12)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Subscriptions")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .padding(12)
                            .background(AppTheme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Total Card
                        VStack(spacing: 12) {
                            Text("TOTAL MONTHLY FIXED COST")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(3)
                            
                            Text(totalMonthlySpent, format: .currency(code: selectedCurrency))
                                .font(Font.headline(size: 40, weight: .heavy))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        .padding(.horizontal)
                        
                        // List
                        if subscriptions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                Text("No subscriptions yet")
                                    .font(Font.bodyText(size: 16))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                            }
                            .padding(.top, 60)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(subscriptions) { sub in
                                    SubscriptionRow(sub: sub)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 120)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddSubscriptionView()
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct SubscriptionRow: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currency") private var selectedCurrency = "USD"
    let sub: Subscription
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: sub.colorHex).opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(hex: sub.colorHex).opacity(0.2), lineWidth: 1))
                
                Image(systemName: sub.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: sub.colorHex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sub.name)
                    .font(Font.headline(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                
                Text("Billing day: \(sub.billingDay)")
                    .font(Font.bodyText(size: 14))
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(sub.amount, format: .currency(code: selectedCurrency))
                    .font(Font.headline(size: 18, weight: .heavy))
                    .foregroundColor(AppTheme.onSurface)
                
                Button(action: { modelContext.delete(sub) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.error.opacity(0.6))
                }
            }
        }
        .padding(20)
        .glassCard()
    }
}

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount: Double = 0
    @State private var billingDay = 1
    @State private var category = "Subscription"
    
    private let categories = ["Entertainment", "Utility", "Food", "Health", "Tech", "Other"]
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 32) {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("New Subscription")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button("Save") { save() }
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                        .disabled(name.isEmpty || amount <= 0)
                        .opacity(name.isEmpty || amount <= 0 ? 0.5 : 1)
                }
                .padding(.top, 10)
                
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        
                        TextField("Netflix, Spotify...", text: $name)
                            .textFieldStyle(.plain)
                            .font(Font.headline(size: 18))
                            .foregroundColor(AppTheme.onSurface)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    // Amount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MONTHLY AMOUNT")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .font(Font.headline(size: 18))
                            .foregroundColor(AppTheme.onSurface)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    HStack(spacing: 20) {
                        // Billing Day
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BILLING DAY")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            Picker("Day", selection: $billingDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORY")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                            
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                
                Spacer()
                
            }
            .padding(24)
        }
    }
    
    private func save() {
        guard !name.isEmpty && amount > 0 else { return }
        
        let icon: String = {
            switch category {
            case "Entertainment": return "play.tv.fill"
            case "Utility": return "bolt.fill"
            case "Food": return "fork.knife"
            case "Health": return "heart.fill"
            case "Tech": return "laptopcomputer"
            default: return "calendar"
            }
        }()
        
        let sub = Subscription(name: name, amount: amount, billingDay: billingDay, category: category, icon: icon)
        modelContext.insert(sub)
        dismiss()
    }
}


