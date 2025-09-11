import Foundation

/// Shared enums used across the application
enum NotificationStyle: String, CaseIterable, Codable {
    case banner = "Banner"
    case sound = "Sound Only"
    case silent = "Silent"
}

enum BreakType: String, CaseIterable, Codable {
    case regular = "Regular"
    case micro = "Micro"
    case water = "Water"
}