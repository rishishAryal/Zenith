import SwiftUI

struct TabCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = height / 2
        
        // Circular cutout logic
        let cutoutRadius: CGFloat = 38 // Slightly larger than the 29pt button radius
        let center = width / 2
        
        // Start top-left
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Line to start of cutout
        path.addLine(to: CGPoint(x: center - cutoutRadius, y: 0))
        
        // Smoother entry to the arc
        path.addQuadCurve(
            to: CGPoint(x: center - cutoutRadius + 5, y: 5),
            control: CGPoint(x: center - cutoutRadius + 2, y: 0)
        )
        
        // The Cutout (Circular Arc)
        path.addArc(
            center: CGPoint(x: center, y: 5),
            radius: cutoutRadius - 5,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        
        // Smoother exit from the arc
        path.addQuadCurve(
            to: CGPoint(x: center + cutoutRadius, y: 0),
            control: CGPoint(x: center + cutoutRadius - 2, y: 0)
        )
        
        // Line to top-right
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Right Side rounding
        path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Bottom line
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        
        // Left Side rounding
        path.addArc(center: CGPoint(x: cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        path.closeSubpath()
        return path
    }
}
