import Foundation
import SwiftData

@Model
class PlannedTransaction {
    var id: UUID
    var amount: Double
    var category: String
    var note: String?
    var dueDate: Date
    var type: TransactionType? // Optional for migration safety
    
    var safeType: TransactionType {
        type ?? .outgoing
    }
    
    init(amount: Double, category: String, note: String? = nil, dueDate: Date = .now, type: TransactionType = .outgoing) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.note = note
        self.dueDate = dueDate
        self.type = type
    }
}
