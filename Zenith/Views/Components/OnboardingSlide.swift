import SwiftUI

struct OnboardingSlide: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon with Dynamic Glow
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(Font.headline(size: 32, weight: .black))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.onSurface)
                
                Text(description)
                    .font(Font.bodyText(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ZStack {
        AppTheme.bgSurface.ignoresSafeArea()
        OnboardingSlide(
            icon: "sparkles",
            title: "Welcome to Zenith",
            description: "Experience the next generation of personal wealth management with precision and beauty.",
            color: AppTheme.primary
        )
    }
    .preferredColorScheme(.dark)
}
