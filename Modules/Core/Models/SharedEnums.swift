import Foundation

/// Shared enums used across the application
// Notifications removed

enum BreakType: String, CaseIterable, Codable {
    case regular = "Regular"
    case micro = "Micro"
    case water = "Water"
    case custom = "Custom"
}
