import Foundation
import SwiftData

@Model
class SavingsGoal {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var icon: String
    var colorHex: String
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    init(name: String, targetAmount: Double, currentAmount: Double = 0, deadline: Date? = nil, icon: String = "target", colorHex: String = "#CC97FF") {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.icon = icon
        self.colorHex = colorHex
    }
}
