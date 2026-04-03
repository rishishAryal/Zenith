import SwiftUI

struct LoadingOverlay: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if appViewModel.isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                
                VStack(spacing: 24) {
                    CustomLoader()
                    
                    VStack(spacing: 8) {
                        Text("Syncing Zenith")
                            .font(Font.headline(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Updating your financial data...")
                            .font(Font.bodyText(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .transition(.opacity.animation(.easeInOut))
            .zIndex(999)
        }
    }
}

struct CustomLoader: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Outer Ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                .frame(width: 80, height: 80)
            
            // Animated Gradient Ring
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AppTheme.primaryGradient,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Center Logo Icon
            Image(systemName: "safari.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.primaryGradient)
                .symbolEffect(.pulse, options: .repeating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LoadingOverlay()
            .environmentObject(AppViewModel.shared)
    }
}
