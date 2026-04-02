import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    // Zenith Branded Logo/Text
                    Text("Zenith")
                        .font(Font.headline(size: 64, weight: .black))
                        .foregroundStyle(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Text("ELEVATE YOUR WEALTH")
                        .font(Font.bodyText(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .tracking(8)
                        .padding(.leading, 8) // Compensation for tracking
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .preferredColorScheme(.dark)
}
