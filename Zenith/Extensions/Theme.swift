import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct AppTheme {
    static let bgSurface = Color(hex: "#070d1f")
    static let surfaceContainer = Color(hex: "#11192e")
    static let surfaceCard = Color(hex: "#1c253e")
    static let onSurface = Color(hex: "#dfe4fe")
    static let onSurfaceVariant = Color(hex: "#a5aac2")
    
    static let primary = Color(hex: "#cc97ff")
    static let primaryDim = Color(hex: "#9c48ea")
    
    static let secondary = Color(hex: "#6bff8f")
    static let secondaryDim = Color(hex: "#5bf083")
    
    static let tertiary = Color(hex: "#ff716a")
    static let tertiaryDim = Color(hex: "#ff928b")
    
    static let outline = Color(hex: "#6f758b")
    static let error = Color(hex: "#ff6e84")
    
    // Gradients
    static let primaryGradient = LinearGradient(colors: [primary, primaryDim], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let secondaryGradient = LinearGradient(colors: [secondary, secondaryDim], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let tertiaryGradient = LinearGradient(colors: [tertiary, tertiaryDim], startPoint: .topLeading, endPoint: .bottomTrailing)
}

extension Font {
    // We default to native iOS Rounded and Default design scales.
    // If you decide to add the font files, replace with: .custom("Manrope-ExtraBold", size: size)
    static func headline(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    static func bodyText(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}
