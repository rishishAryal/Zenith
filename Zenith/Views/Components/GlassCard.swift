import SwiftUI

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surfaceCard.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    // The CSS has border-top: 1px solid rgba(223, 228, 254, 0.1)
                    .stroke(LinearGradient(
                        colors: [AppTheme.onSurface.opacity(0.15), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}
