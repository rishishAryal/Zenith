import Foundation
import Combine

enum SettlementType: String, Codable, CaseIterable {
    case receivable = "receivable"
    case payable = "payable"
}

struct Settlement: Codable, Identifiable {
    var id: UUID
    var personName: String
    var amount: Double
    var remainingAmount: Double
    var type: SettlementType
    var isCompleted: Bool
    var dateCreated: Date
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, type, notes, date, status
        case personName = "person_name"
        case remainingAmount = "remaining_amount"
    }
    
    init(personName: String, amount: Double, type: SettlementType, notes: String? = nil, date: Date = .now) {
        self.id = UUID()
        self.personName = personName
        self.amount = amount
        self.remainingAmount = amount
        self.type = type
        self.isCompleted = false
        self.dateCreated = date
        self.notes = notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        personName = try container.decode(String.self, forKey: .personName)
        type = try container.decode(SettlementType.self, forKey: .type)
        notes = try? container.decode(String.self, forKey: .notes)
        dateCreated = try container.decode(Date.self, forKey: .date)
        
        if let status = try? container.decode(String.self, forKey: .status) {
            isCompleted = (status == "completed" || status == "settled")
        } else if let intVal = try? container.decode(Int.self, forKey: .status) {
            isCompleted = (intVal == 1)
        } else {
            isCompleted = false
        }
        
        if let doubleVal = try? container.decode(Double.self, forKey: .amount) {
            amount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .amount), let doubleVal = Double(stringVal) {
            amount = doubleVal
        } else {
            amount = 0
        }
        
        if let doubleVal = try? container.decode(Double.self, forKey: .remainingAmount) {
            remainingAmount = doubleVal
        } else if let stringVal = try? container.decode(String.self, forKey: .remainingAmount), let doubleVal = Double(stringVal) {
            remainingAmount = doubleVal
        } else {
            remainingAmount = 0
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(personName, forKey: .personName)
        try container.encode(amount, forKey: .amount)
        try container.encode(remainingAmount, forKey: .remainingAmount)
        try container.encode(type, forKey: .type)
        try container.encode(notes, forKey: .notes)
        try container.encode(dateCreated, forKey: .date)
        
        let status = isCompleted ? "completed" : "pending"
        try container.encode(status, forKey: .status)
    }
}
