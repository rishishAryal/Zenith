import Foundation

struct PlannedTransaction: Codable, Identifiable {
    var id: UUID
    var amount: Double
    var categoryId: UUID?
    var note: String?
    var dueDate: Date
    var type: TransactionType?
    
    var safeType: TransactionType {
        type ?? .outgoing
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, note, type
        case categoryId = "category_id"
        case dueDate = "due_date"
    }
    
    init(amount: Double, categoryId: UUID? = nil, note: String? = nil, dueDate: Date = .now, type: TransactionType = .outgoing) {
        self.id = UUID()
        self.amount = amount
        self.categoryId = categoryId
        self.note = note
        self.dueDate = dueDate
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Resilience: Handle strings for UUIDs
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            id = uuid
        } else if let stringUUID = try? container.decode(String.self, forKey: .id), let uuid = UUID(uuidString: stringUUID) {
            id = uuid
        } else {
            id = UUID()
        }
        
        categoryId = try? container.decode(UUID.self, forKey: .categoryId)
        note = try? container.decode(String.self, forKey: .note)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        type = try? container.decode(TransactionType.self, forKey: .type)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .amount) {
            amount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .amount), let doubleVal = Double(stringVal) {
            amount = doubleVal
        } else {
            amount = 0
        }
    }
}
