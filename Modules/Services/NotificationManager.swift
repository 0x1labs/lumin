import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void = { _, _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
                ErrorHandler.shared.handleNotificationError(error)
                completion(false, error)
                return
            }
            
            print("Notification authorization \(granted ? "granted" : "denied")")
            completion(granted, nil)
        }
    }
    
    func scheduleBreakNotification(title: String, body: String, style: NotificationStyle, completion: @escaping (Error?) -> Void = { _ in }) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        // Honor notification style
        switch style {
        case .banner:
            content.sound = .default
            if #available(macOS 12.0, *) {
                content.interruptionLevel = .active
            }
        case .sound:
            content.sound = .default
            if #available(macOS 12.0, *) {
                content.interruptionLevel = .active
            }
        case .silent:
            content.sound = nil
            if #available(macOS 12.0, *) {
                content.interruptionLevel = .passive
            }
        }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule break notification: \(error)")
                ErrorHandler.shared.handleNotificationError(error)
                completion(error)
                return
            }
            
            print("Break notification scheduled successfully")
            completion(nil)
        }
    }
}
