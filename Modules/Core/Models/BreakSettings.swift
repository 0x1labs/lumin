import Foundation

struct BreakSettings {
    var interval: TimeInterval = 1200 // 20 minutes
    var duration: TimeInterval = 20   // 20 seconds
    var isEnabled: Bool = true
    var notificationStyle: NotificationStyle = .banner
    var startAtLogin: Bool = false
    
    init(interval: TimeInterval, duration: TimeInterval, isEnabled: Bool, notificationStyle: NotificationStyle, startAtLogin: Bool) {
        self.interval = interval
        self.duration = duration
        self.isEnabled = isEnabled
        self.notificationStyle = notificationStyle
        self.startAtLogin = startAtLogin
    }
}