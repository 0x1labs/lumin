import Foundation
import SwiftUI

struct CustomBreak: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var iconSystemName: String
    var interval: TimeInterval
    var duration: TimeInterval
    var isEnabled: Bool

    init(
        id: UUID = UUID(), name: String, iconSystemName: String, interval: TimeInterval,
        duration: TimeInterval, isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.iconSystemName = iconSystemName
        self.interval = interval
        self.duration = duration
        self.isEnabled = isEnabled
    }
}
