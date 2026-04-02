import Foundation
import SwiftData

@Model
final class Budget {
    var monthlyLimit: Double
    var month: Date
    
    init(monthlyLimit: Double, month: Date) {
        self.monthlyLimit = monthlyLimit
        self.month = month
    }
}
