import LocalAuthentication
import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("requiresFaceID") private var requiresFaceID = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isUnlocked = false
    @State private var showSplash = true
    @Environment(\.modelContext) private var modelContext
    @Query private var existingCategories: [Category]
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                Group {
                    if !hasCompletedOnboarding {
                        OnboardingView()
                    } else if requiresFaceID && !isUnlocked {
                        LockedView(isUnlocked: $isUnlocked)
                    } else {
                        NavigationStack {
                            MainTabView()
                        }
                    }
                }
            }
        }
        .onAppear {
            seedCategoriesIfNeeded()
            
            // Splash transition logic
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
    
    private func seedCategoriesIfNeeded() {
        if existingCategories.isEmpty {
            for category in Category.defaults {
                modelContext.insert(category)
            }
        }
    }
}

enum Tab {
    case dashboard, transactions, wealth, tools
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showAdd: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .transactions:
                    TransactionsView()
                case .wealth:
                    SavingsGoalsView()
                case .tools:
                    ToolsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Premium Curved Nav Bar
            ZStack(alignment: .top) {
                // Background with Curve
                TabCurveShape()
                    .fill(AppTheme.surfaceCard.opacity(0.85))
                    .background(.ultraThinMaterial)
                    .clipShape(TabCurveShape()) // Clip to the curve itself
                    .frame(height: 80)
                    .shadow(color: Color.black.opacity(0.5), radius: 25, x: 0, y: 15)
                
                HStack(spacing: 0) {
                    // Left Tabs
                    TabBarButton(icon: "house.fill", title: "Home", isSelected: selectedTab == .dashboard) {
                        selectedTab = .dashboard
                    }
                    .frame(maxWidth: .infinity)
                    
                    TabBarButton(icon: "list.bullet.rectangle.portrait", title: "Activity", isSelected: selectedTab == .transactions) {
                        selectedTab = .transactions
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Center Diamond Add Button
                    Button(action: { showAdd = true }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 58, height: 58)
                                .shadow(color: AppTheme.primary.opacity(0.4), radius: 15, x: 0, y: 10)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -35) // Peak floating height
                    .frame(width: 80)
                    
                    // Right Tabs
                    TabBarButton(icon: "target", title: "Goals", isSelected: selectedTab == .wealth) {
                        selectedTab = .wealth
                    }
                    .frame(maxWidth: .infinity)
                    
                    TabBarButton(icon: "briefcase.fill", title: "Manage", isSelected: selectedTab == .tools) {
                        selectedTab = .tools
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 15) // Slightly tighter
            .padding(.bottom, 5)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showAdd) {
            AddTransactionView()
                .presentationDetents([.fraction(0.85)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AppTheme.primary : Color.white.opacity(0.3))
                
                Text(title)
                    .font(Font.bodyText(size: 10, weight: isSelected ? .black : .bold))
                    .foregroundColor(isSelected ? AppTheme.primary : Color.white.opacity(0.3))
            }
            .frame(height: 55)
        }
    }
}

// Authentication Lock Screen remains mostly same but uses Theme colors
struct LockedView: View {
    @Binding var isUnlocked: Bool
    @State private var lockJiggle = false
    
    var body: some View {
        ZStack {
            AppTheme.bgSurface.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.primary)
                    .rotationEffect(.degrees(lockJiggle ? 15 : 0))
                    .animation(lockJiggle ? .spring(response: 0.2, dampingFraction: 0.2).repeatCount(3, autoreverses: true) : .default, value: lockJiggle)
                
                Text("Zenith is Locked")
                    .font(Font.headline(size: 24))
                    .foregroundColor(.white)
                
                Button("Unlock with Face ID") {
                    authenticate()
                }
                .font(.headline)
                .padding()
                .background(AppTheme.primaryGradient)
                .clipShape(Capsule())
                .foregroundColor(.white)
            }
        }
        .onAppear(perform: authenticate)
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock Zenith to view your finances."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            self.isUnlocked = true
                        }
                    } else {
                        lockJiggle.toggle()
                    }
                }
            }
        } else {
            #if targetEnvironment(simulator)
                isUnlocked = true
            #else
                lockJiggle.toggle()
            #endif
        }
    }
}
