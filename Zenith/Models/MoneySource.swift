import Foundation
import SwiftData

@Model
final class MoneySource {
    var id: UUID
    var name: String
    var balance: Double
    var icon: String
    var includeInBudget: Bool
    
    init(name: String, balance: Double, icon: String = "creditcard", includeInBudget: Bool = true) {
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.icon = icon
        self.includeInBudget = includeInBudget
    }
}
