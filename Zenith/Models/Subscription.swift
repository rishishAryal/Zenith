import Foundation

struct Subscription: Codable, Identifiable {
    var id: UUID
    var name: String
    var amount: Double
    var billingDay: Int
    var categoryId: UUID?
    var icon: String
    var colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, icon
        case billingDay = "billing_day"
        case categoryId = "category_id"
        case colorHex = "color_hex"
    }
    
    init(name: String, amount: Double, billingDay: Int, categoryId: UUID? = nil, icon: String = "calendar", colorHex: String = "#CC97FF") {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.billingDay = billingDay
        self.categoryId = categoryId
        self.icon = icon
        self.colorHex = colorHex
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
        
        name = try container.decode(String.self, forKey: .name)
        billingDay = try container.decode(Int.self, forKey: .billingDay)
        categoryId = try? container.decode(UUID.self, forKey: .categoryId)
        icon = try container.decode(String.self, forKey: .icon)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .amount) {
            amount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .amount), let doubleVal = Double(stringVal) {
            amount = doubleVal
        } else {
            amount = 0
        }
    }
}
