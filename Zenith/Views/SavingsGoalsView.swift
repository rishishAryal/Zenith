import SwiftUI
import SwiftData

struct SavingsGoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SavingsGoal.targetAmount, order: .reverse) private var goals: [SavingsGoal]
    @AppStorage("currency") private var selectedCurrency = "USD"
    @State private var showingAddSheet = false
    var isNavigated: Bool = false
    
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    if isNavigated {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.onSurface)
                                .padding(12)
                                .background(AppTheme.surfaceContainer)
                                .clipShape(Circle())
                        }
                    } else {
                        Spacer()
                            .frame(width: 44) // Balancing the plus button
                    }
                    
                    Spacer()
                    
                    Text("Goals")
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
                    VStack(spacing: 32) {
                        // Total Saved Stats
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("TOTAL ASSETS")
                                    .font(Font.bodyText(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                    .tracking(2)
                                
                                Text(totalSaved, format: .currency(code: selectedCurrency))
                                    .font(Font.headline(size: 32, weight: .heavy))
                                    .foregroundColor(AppTheme.secondary)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(AppTheme.surfaceContainer, lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "lock.shield.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.tertiary)
                            }
                        }
                        .padding(32)
                        .glassCard()
                        .padding(.horizontal)
                        
                        // Goals Grid
                        if goals.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "target")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                                Text("No savings goals yet")
                                    .font(Font.bodyText(size: 16))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(goals) { goal in
                                    GoalCard(goal: goal)
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
            AddGoalView()
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct GoalCard: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currency") private var selectedCurrency = "USD"
    let goal: SavingsGoal
    @State private var showingDepositSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: goal.colorHex).opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: goal.icon)
                        .foregroundColor(Color(hex: goal.colorHex))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5))
                            .padding(8)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showingDepositSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(Font.headline(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                
                Text(goal.targetAmount, format: .currency(code: selectedCurrency))
                    .font(Font.bodyText(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.surfaceContainer)
                        Capsule().fill(AppTheme.primaryGradient)
                            .frame(width: geo.size.width * CGFloat(goal.progress))
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 5)
                            .animation(.spring(), value: goal.currentAmount)
                    }
                }
                .frame(height: 6)
                
                Text("\(Int(goal.progress * 100))%")
                    .font(Font.bodyText(size: 10, weight: .heavy))
                    .foregroundColor(AppTheme.primary)
            }
        }
        .padding(20)
        .glassCard()
        .alert("Delete Goal?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(goal)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(goal.name)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showingDepositSheet) {
            DepositView(goal: goal)
                .presentationDetents([.fraction(0.4)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var targetAmount: Double = 0
    @State private var icon = "target"
    
    private let icons = ["target", "car.fill", "house.fill", "airplane", "briefcase.fill", "gift.fill"]
    
    var body: some View {
        ZStack {
            LivingBackground()
            VStack(spacing: 32) {
                HStack {
                    Text("New Goal")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    Spacer()
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GOAL NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("New Car, Vacation...", text: $name)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TARGET AMOUNT")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        TextField("0", value: $targetAmount, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHOOSE ICON")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                            .tracking(2)
                        
                        HStack(spacing: 15) {
                            ForEach(icons, id: \.self) { i in
                                Image(systemName: i)
                                    .font(.title2)
                                    .foregroundColor(icon == i ? AppTheme.primary : AppTheme.onSurfaceVariant)
                                    .frame(width: 50, height: 50)
                                    .background(icon == i ? AppTheme.primary.opacity(0.1) : AppTheme.surfaceContainer)
                                    .clipShape(Circle())
                                    .onTapGesture { icon = i }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: save) {
                    Text("Initialize Pot")
                        .font(Font.headline(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(24)
        }
    }
    
    private func save() {
        guard !name.isEmpty && targetAmount > 0 else { return }
        let goal = SavingsGoal(name: name, targetAmount: targetAmount, icon: icon)
        modelContext.insert(goal)
        dismiss()
    }
}

struct DepositView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: SavingsGoal
    @State private var amount: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Invest in \(goal.name)")
                .font(Font.headline(size: 20, weight: .bold))
                .foregroundColor(AppTheme.onSurface)
            
            TextField("Amount", value: $amount, format: .number)
                .keyboardType(.decimalPad)
                .font(Font.headline(size: 32, weight: .heavy))
                .multilineTextAlignment(.center)
                .padding()
                .background(AppTheme.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button(action: {
                goal.currentAmount += amount
                dismiss()
            }) {
                Text("Deposit Capital")
                    .font(Font.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(32)
    }
}
