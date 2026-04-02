import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case incoming
    case outgoing
}

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var category: String
    var note: String?
    var date: Date
    var type: TransactionType?
    var sourceId: UUID?
    
    @Transient
    var safeType: TransactionType {
        type ?? .outgoing
    }
    
    init(amount: Double, category: String, note: String? = nil, date: Date = .now, type: TransactionType = .outgoing, sourceId: UUID? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
        self.type = type
        self.sourceId = sourceId
    }
}
