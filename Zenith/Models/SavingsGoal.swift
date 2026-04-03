import Foundation

struct SavingsGoal: Codable, Identifiable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var icon: String
    var colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, deadline, icon
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case colorHex = "color_hex"
    }
    
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
        deadline = try? container.decode(Date.self, forKey: .deadline)
        icon = try container.decode(String.self, forKey: .icon)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .targetAmount) {
            targetAmount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .targetAmount), let doubleVal = Double(stringVal) {
            targetAmount = doubleVal
        } else {
            targetAmount = 0
        }
        
        if let doubleVal = try? container.decode(Double.self, forKey: .currentAmount) {
            currentAmount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .currentAmount), let doubleVal = Double(stringVal) {
            currentAmount = doubleVal
        } else {
            currentAmount = 0
        }
    }
}
