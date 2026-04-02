import SwiftUI

struct LivingBackground: View {
    // Atmospheric Blobs based on the CSS:
    // top-right: bg-primary-dim/20
    // bottom-left: bg-secondary/10
    
    var body: some View {
        ZStack {
            AppTheme.bgSurface
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                // Primary Blob (Top Right)
                Circle()
                    .fill(AppTheme.primaryDim.opacity(0.3))
                    .frame(width: proxy.size.width * 0.8, height: proxy.size.width * 0.8)
                    .blur(radius: 120)
                    .offset(x: proxy.size.width * 0.4, y: -proxy.size.height * 0.1)
                
                // Secondary Blob (Bottom Left)
                Circle()
                    .fill(AppTheme.secondary.opacity(0.2))
                    .frame(width: proxy.size.width * 0.6, height: proxy.size.width * 0.6)
                    .blur(radius: 100)
                    .offset(x: -proxy.size.width * 0.2, y: proxy.size.height * 0.6)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}
