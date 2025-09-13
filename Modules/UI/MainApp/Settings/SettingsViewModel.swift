import Foundation
import SwiftUI
import Observation

@Observable
class SettingsViewModel {
    // MARK: - Properties
    var workInterval: TimeInterval = 1200 // 20 minutes
    var breakDuration: TimeInterval = 20  // 20 seconds
    var microBreakInterval: TimeInterval = 600 // 10 minutes
    var microBreakDuration: TimeInterval = 5  // 5 seconds
    var waterBreakInterval: TimeInterval = 1800 // 30 minutes
    var waterBreakDuration: TimeInterval = 5  // 5 seconds
    var isEnabled: Bool = true
    var microBreaksEnabled: Bool = true
    var waterBreaksEnabled: Bool = true
    var startAtLogin: Bool = false
    var breakType: BreakType = .regular
    var naturalBreakDetection: Bool = false
    
    init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Loads settings from UserDefaults
    func loadSettings() {
        workInterval = SettingsManager.shared.breakInterval
        breakDuration = SettingsManager.shared.breakDuration
        microBreakInterval = SettingsManager.shared.microBreakInterval
        microBreakDuration = SettingsManager.shared.microBreakDuration
        waterBreakInterval = SettingsManager.shared.waterBreakInterval
        waterBreakDuration = SettingsManager.shared.waterBreakDuration
        isEnabled = SettingsManager.shared.isEnabled
        microBreaksEnabled = SettingsManager.shared.microBreaksEnabled
        waterBreaksEnabled = SettingsManager.shared.waterBreaksEnabled
        startAtLogin = SettingsManager.shared.startAtLogin
        breakType = SettingsManager.shared.breakType
        naturalBreakDetection = SettingsManager.shared.naturalBreakDetection
        
        Logger.debug("SettingsViewModel: Loaded settings")
    }
    
    /// Saves settings to UserDefaults
    func saveSettings() {
        // Update settings manager
        SettingsManager.shared.breakInterval = workInterval
        SettingsManager.shared.breakDuration = breakDuration
        SettingsManager.shared.microBreakInterval = microBreakInterval
        SettingsManager.shared.microBreakDuration = microBreakDuration
        SettingsManager.shared.waterBreakInterval = waterBreakInterval
        SettingsManager.shared.waterBreakDuration = waterBreakDuration
        SettingsManager.shared.isEnabled = isEnabled
        SettingsManager.shared.microBreaksEnabled = microBreaksEnabled
        SettingsManager.shared.waterBreaksEnabled = waterBreaksEnabled
        SettingsManager.shared.startAtLogin = startAtLogin
        SettingsManager.shared.breakType = breakType
        SettingsManager.shared.naturalBreakDetection = naturalBreakDetection
        
        Logger.debug("SettingsViewModel: Saved settings successfully")
    }
    
    /// Resets all settings to their default values
    func resetToDefaults() {
        workInterval = 1200 // 20 minutes
        breakDuration = 20  // 20 seconds
        microBreakInterval = 600 // 10 minutes
        microBreakDuration = 5  // 5 seconds
        waterBreakInterval = 1800 // 30 minutes
        waterBreakDuration = 5  // 5 seconds
        isEnabled = true
        microBreaksEnabled = true
        waterBreaksEnabled = true
        startAtLogin = false
        breakType = .regular
        naturalBreakDetection = false
        
        Logger.debug("SettingsViewModel: Reset to defaults")
    }
}
