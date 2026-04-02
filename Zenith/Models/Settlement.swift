import Foundation
import SwiftData

enum SettlementType: String, Codable, CaseIterable {
    case receivable = "Receivable"
    case payable = "Payable"
}

@Model
final class Settlement {
    var id: UUID
    var personName: String
    var amount: Double
    var remainingAmount: Double
    var type: SettlementType
    var isCompleted: Bool
    var dateCreated: Date
    var notes: String?
    
    init(personName: String, amount: Double, type: SettlementType, notes: String? = nil, dateCreated: Date = .now) {
        self.id = UUID()
        self.personName = personName
        self.amount = amount
        self.remainingAmount = amount
        self.type = type
        self.isCompleted = false
        self.dateCreated = dateCreated
        self.notes = notes
    }
}
