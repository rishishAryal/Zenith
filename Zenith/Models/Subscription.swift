import Foundation
import SwiftData

@Model
class Subscription {
    var id: UUID
    var name: String
    var amount: Double
    var billingDay: Int // Day of month (1-31)
    var category: String
    var icon: String
    var colorHex: String
    
    init(name: String, amount: Double, billingDay: Int, category: String = "Subscription", icon: String = "calendar", colorHex: String = "#CC97FF") {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.billingDay = billingDay
        self.category = category
        self.icon = icon
        self.colorHex = colorHex
    }
}
