import Foundation

struct BreakHistory: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let wasCompleted: Bool
    let breakType: BreakType
    
    init(id: UUID = UUID(), date: Date, duration: TimeInterval, wasCompleted: Bool, breakType: BreakType = .regular) {
        self.id = id
        self.date = date
        self.duration = duration
        self.wasCompleted = wasCompleted
        self.breakType = breakType
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, date, duration, wasCompleted, breakType
    }
    
    // MARK: - Equatable
    static func == (lhs: BreakHistory, rhs: BreakHistory) -> Bool {
        return lhs.id == rhs.id
    }
}