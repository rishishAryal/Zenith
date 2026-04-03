import Foundation

enum TransactionType: String, Codable {
    case incoming
    case outgoing
}

struct Transaction: Codable, Identifiable {
    var id: UUID
    var amount: Double
    var categoryId: UUID
    var note: String?
    var date: Date
    var type: TransactionType?
    var moneySourceId: UUID
    
    // For local UI purposes where we might still use the name
    var category: String?
    
    var safeType: TransactionType {
        type ?? .outgoing
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, note, date, type, category
        case categoryId = "category_id"
        case moneySourceId = "money_source_id"
    }
    
    init(amount: Double, categoryId: UUID, note: String? = nil, date: Date = .now, type: TransactionType = .outgoing, moneySourceId: UUID) {
        self.id = UUID()
        self.amount = amount
        self.categoryId = categoryId
        self.note = note
        self.date = date
        self.type = type
        self.moneySourceId = moneySourceId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Resilience: Handle strings for UUIDs (some backends return them like that)
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            id = uuid
        } else if let stringUUID = try? container.decode(String.self, forKey: .id), let uuid = UUID(uuidString: stringUUID) {
            id = uuid
        } else {
            id = UUID()
        }
        
        if let uuid = try? container.decode(UUID.self, forKey: .categoryId) {
            categoryId = uuid
        } else if let stringUUID = try? container.decode(String.self, forKey: .categoryId), let uuid = UUID(uuidString: stringUUID) {
            categoryId = uuid
        } else {
            categoryId = UUID()
        }
        
        if let uuid = try? container.decode(UUID.self, forKey: .moneySourceId) {
            moneySourceId = uuid
        } else if let stringUUID = try? container.decode(String.self, forKey: .moneySourceId), let uuid = UUID(uuidString: stringUUID) {
            moneySourceId = uuid
        } else {
            moneySourceId = UUID()
        }
        
        note = try? container.decode(String.self, forKey: .note)
        date = try container.decode(Date.self, forKey: .date)
        type = try? container.decode(TransactionType.self, forKey: .type)
        category = try? container.decode(String.self, forKey: .category)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .amount) {
            amount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .amount), let doubleVal = Double(stringVal) {
            amount = doubleVal
        } else {
            amount = 0
        }
    }
}
