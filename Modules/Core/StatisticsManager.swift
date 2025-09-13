import Foundation

// MARK: - Data Models
struct BreakEvent: Codable, Equatable {
    let id: UUID
    let type: StatisticsBreakType
    let scheduledTime: Date
    let actualTime: Date?
    let duration: TimeInterval?
    let completed: Bool
}

enum StatisticsBreakType: Codable, Equatable {
    case regular
    case micro
    case water
    case custom(String) // For custom breaks with their name
}

struct DailyStatistics: Codable {
    let date: Date
    var totalBreaks: Int = 0
    var completedBreaks: Int = 0
    var regularBreaks: Int = 0
    var microBreaks: Int = 0
    var waterBreaks: Int = 0
    var customBreaks: [String: Int] = [:] // [customBreakName: count]
    var totalTime: TimeInterval = 0 // Total time spent on breaks
    
    var completionRate: Double {
        totalBreaks > 0 ? Double(completedBreaks) / Double(totalBreaks) * 100 : 0
    }
}

// MARK: - Statistics Manager
@Observable
class StatisticsManager {
    static let shared = StatisticsManager()
    
    private let userDefaults = UserDefaults.standard
    private let breakEventsKey = "BreakEvents"
    private let dailyStatsKey = "DailyStatistics"
    
    private var breakEvents: [BreakEvent] = []
    private var dailyStats: [String: DailyStatistics] = [:] // [dateString: stats]
    
    private init() {
        loadStatistics()
    }
    
    // MARK: - Public Methods
    
    func recordBreakScheduled(type: StatisticsBreakType, scheduledTime: Date) {
        // For scheduled breaks, we don't record them until they're taken or skipped
        // This is because scheduled breaks from repeating timers would create too many entries
    }
    
    func recordBreakTaken(type: StatisticsBreakType, scheduledTime: Date, actualTime: Date, duration: TimeInterval) {
        let event = BreakEvent(
            id: UUID(),
            type: type,
            scheduledTime: scheduledTime,
            actualTime: actualTime,
            duration: duration,
            completed: true
        )
        
        breakEvents.append(event)
        updateDailyStats(for: scheduledTime, type: type, completed: true, duration: duration)
        saveStatistics()
    }
    
    func recordBreakSkipped(type: StatisticsBreakType, scheduledTime: Date) {
        let event = BreakEvent(
            id: UUID(),
            type: type,
            scheduledTime: scheduledTime,
            actualTime: Date(),
            duration: 0,
            completed: false
        )
        
        breakEvents.append(event)
        updateDailyStats(for: scheduledTime, type: type, completed: false, duration: 0)
        saveStatistics()
    }
    
    // MARK: - Statistics Accessors
    
    func getDailyStats(for date: Date) -> DailyStatistics {
        let dateString = dateString(from: date)
        return dailyStats[dateString] ?? DailyStatistics(date: date)
    }
    
    func getWeeklyStats(endingAt date: Date = Date()) -> [DailyStatistics] {
        var stats: [DailyStatistics] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: date) {
                stats.append(getDailyStats(for: day))
            }
        }
        
        return stats.reversed() // Oldest to newest
    }
    
    func getTotalBreaks(by type: StatisticsBreakType) -> Int {
        return breakEvents.filter { $0.type == type && $0.completed }.count
    }
    
    func getCompletionRate() -> Double {
        let completed = breakEvents.filter { $0.completed }.count
        return breakEvents.isEmpty ? 0 : Double(completed) / Double(breakEvents.count) * 100
    }
    
    func getMostActiveDay() -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        // Look at last 30 days
        guard let startDate = calendar.date(byAdding: .day, value: -30, to: today) else { return nil }
        
        var dailyCounts: [Date: Int] = [:]
        
        for event in breakEvents where event.completed {
            let day = calendar.startOfDay(for: event.actualTime ?? event.scheduledTime)
            if day >= startDate {
                dailyCounts[day, default: 0] += 1
            }
        }
        
        return dailyCounts.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Private Methods
    
    private func updateDailyStats(for date: Date, type: StatisticsBreakType, completed: Bool, duration: TimeInterval) {
        let dateString = dateString(from: date)
        var stats = dailyStats[dateString] ?? DailyStatistics(date: date)
        
        stats.totalBreaks += 1
        if completed {
            stats.completedBreaks += 1
            stats.totalTime += duration
            
            switch type {
            case .regular:
                stats.regularBreaks += 1
            case .micro:
                stats.microBreaks += 1
            case .water:
                stats.waterBreaks += 1
            case .custom(let name):
                stats.customBreaks[name, default: 0] += 1
            }
        }
        
        dailyStats[dateString] = stats
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func loadStatistics() {
        // Load break events
        if let data = userDefaults.data(forKey: breakEventsKey),
           let events = try? JSONDecoder().decode([BreakEvent].self, from: data) {
            breakEvents = events
        }
        
        // Load daily statistics
        if let data = userDefaults.data(forKey: dailyStatsKey),
           let stats = try? JSONDecoder().decode([String: DailyStatistics].self, from: data) {
            dailyStats = stats
        }
    }
    
    private func saveStatistics() {
        // Save break events
        if let data = try? JSONEncoder().encode(breakEvents) {
            userDefaults.set(data, forKey: breakEventsKey)
        }
        
        // Save daily statistics
        if let data = try? JSONEncoder().encode(dailyStats) {
            userDefaults.set(data, forKey: dailyStatsKey)
        }
    }
    
    func resetStatistics() {
        breakEvents.removeAll()
        dailyStats.removeAll()
        userDefaults.removeObject(forKey: breakEventsKey)
        userDefaults.removeObject(forKey: dailyStatsKey)
    }
}