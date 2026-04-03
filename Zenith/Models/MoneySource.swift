import Foundation

struct MoneySource: Codable, Identifiable {
    var id: UUID
    var name: String
    var balance: Double
    var icon: String
    var includeInBudget: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, balance, icon
        case includeInBudget = "include_in_budget"
    }
    
    init(name: String, balance: Double, icon: String = "creditcard", includeInBudget: Bool = true) {
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.icon = icon
        self.includeInBudget = includeInBudget
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
        icon = try container.decode(String.self, forKey: .icon)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .balance) {
            balance = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .balance), let doubleVal = Double(stringVal) {
            balance = doubleVal
        } else {
            balance = 0
        }
        
        if let boolVal = try? container.decode(Bool.self, forKey: .includeInBudget) {
            includeInBudget = boolVal
        } else if let intVal = try? container.decode(Int.self, forKey: .includeInBudget) {
            includeInBudget = intVal == 1
        } else {
            includeInBudget = true
        }
    }
}
