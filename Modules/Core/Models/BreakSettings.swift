import Foundation

struct BreakSettings {
    var interval: TimeInterval = 1200 // 20 minutes
    var duration: TimeInterval = 20   // 20 seconds
    var isEnabled: Bool = true
    var startAtLogin: Bool = false
    
    init(interval: TimeInterval, duration: TimeInterval, isEnabled: Bool, startAtLogin: Bool) {
        self.interval = interval
        self.duration = duration
        self.isEnabled = isEnabled
        self.startAtLogin = startAtLogin
    }
}
