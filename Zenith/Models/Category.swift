import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    
    init(name: String, iconName: String = "tag.fill", colorHex: String = "#7C4DFF") {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
    }
    
    static var defaults: [Category] {
        [
            Category(name: "General", iconName: "tag.fill", colorHex: "#9E9E9E"),
            Category(name: "Shop", iconName: "cart.fill", colorHex: "#7C4DFF"),
            Category(name: "Dining", iconName: "fork.knife", colorHex: "#FFAB40"),
            Category(name: "Travel", iconName: "airplane", colorHex: "#448AFF"),
            Category(name: "Media", iconName: "play.tv.fill", colorHex: "#E040FB"),
            Category(name: "Utilities", iconName: "bolt.fill", colorHex: "#FFD740"),
            Category(name: "Health", iconName: "heart.fill", colorHex: "#FF5252")
        ]
    }
}
