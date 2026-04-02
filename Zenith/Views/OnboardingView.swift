import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Segmented Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= currentPage ? AppTheme.primary : AppTheme.onSurfaceVariant.opacity(0.3))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // Top Bar
                HStack {
                    Button(action: { withAnimation { currentPage -= 1 } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(Font.bodyText(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                    }
                    .opacity(currentPage > 0 && currentPage < 3 ? 1 : 0)
                    .disabled(!(currentPage > 0 && currentPage < 3))
                    
                    Spacer()
                    
                    Button("Skip") {
                        withAnimation(.spring()) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .font(Font.bodyText(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .opacity(currentPage < 3 ? 1 : 0)
                    .disabled(!(currentPage < 3))
                }
                .padding(.horizontal, 30)
                .padding(.top, 15)
                .frame(height: 50)
                
                // TabView with Onboarding Slides
                TabView(selection: $currentPage) {
                    OnboardingSlide(
                        icon: "star.fill",
                        title: "Zenith Experience",
                        description: "Welcome to a new era of wealth management. Zenith combines high-fidelity design with robust financial tools to help you master your liquidity.",
                        color: AppTheme.primary
                    )
                    .tag(0)
                    
                    OnboardingSlide(
                        icon: "building.columns.fill",
                        title: "Wealth Tracking",
                        description: "Connect your bank accounts, cash, or assets. Choose which sources contribute to your live spending power.",
                        color: AppTheme.secondary
                    )
                    .tag(1)
                    
                    OnboardingSlide(
                        icon: "target",
                        title: "Financial Goals",
                        description: "Set major life milestones and watch your progress grow. Zenith uses visual rings to help you stay focused on your long-term wealth accumulation.",
                        color: AppTheme.tertiary
                    )
                    .tag(2)
                    
                    ZStack(alignment: .bottom) {
                        OnboardingSlide(
                            icon: "checkmark.circle.fill",
                            title: "Ready to Begin",
                            description: "You're all set to take control of your financial future. Enter Zenith to start tracking your wealth with precision.",
                            color: AppTheme.secondary
                        )
                        
                        // "Enter Zenith" Button - overlaid at bottom to prevent layout shift
                        Button(action: {
                            withAnimation(.spring()) {
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text("Enter Zenith")
                                .font(Font.headline(size: 18, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(AppTheme.primaryGradient)
                                .clipShape(Capsule())
                                .shadow(color: AppTheme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // We use our own segments
                
                // Bottom Navigation (Next Button)
                Button(action: { withAnimation { currentPage += 1 } }) {
                    HStack {
                        Text("Next Step")
                        Image(systemName: "arrow.right")
                    }
                    .font(Font.headline(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(AppTheme.primary.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.primary.opacity(0.5), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(currentPage < 3 ? 1 : 0)
                .disabled(!(currentPage < 3))
            }
        }
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
