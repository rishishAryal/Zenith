import Foundation

struct Budget: Codable, Identifiable {
    var monthlyLimit: Double
    var month: Date
    
    // Non-persistent ID for Identifiable
    var id: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: month)
    }
    
    enum CodingKeys: String, CodingKey {
        case monthlyLimit = "monthly_limit"
        case month
    }
    
    init(monthlyLimit: Double, month: Date) {
        self.monthlyLimit = monthlyLimit
        self.month = month
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        month = try container.decode(Date.self, forKey: .month)
        
        if let doubleVal = try? container.decode(Double.self, forKey: .monthlyLimit) {
            monthlyLimit = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .monthlyLimit), let doubleVal = Double(stringVal) {
            monthlyLimit = doubleVal
        } else {
            monthlyLimit = 0
        }
    }
}
