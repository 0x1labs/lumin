import Foundation
import SwiftUI
import Observation

@Observable
class SettingsManager {
    static let shared = SettingsManager()
    
    @AppStorage("workInterval") @ObservationIgnored private var _breakInterval: TimeInterval = 1200 // 20 minutes
    @AppStorage("breakDuration") @ObservationIgnored private var _breakDuration: TimeInterval = 20  // 20 seconds
    @AppStorage("microBreakInterval") @ObservationIgnored private var _microBreakInterval: TimeInterval = 300 // 5 minutes
    @AppStorage("microBreakDuration") @ObservationIgnored private var _microBreakDuration: TimeInterval = 2  // 2 seconds (shorter duration)
    @AppStorage("waterBreakInterval") @ObservationIgnored private var _waterBreakInterval: TimeInterval = 1800 // 30 minutes
    @AppStorage("waterBreakDuration") @ObservationIgnored private var _waterBreakDuration: TimeInterval = 5  // 5 seconds
    @AppStorage("isEnabled") @ObservationIgnored private var _isEnabled: Bool = true
    @AppStorage("regularBreaksEnabled") @ObservationIgnored private var _regularBreaksEnabled: Bool = true
    @AppStorage("microBreaksEnabled") @ObservationIgnored private var _microBreaksEnabled: Bool = true
    @AppStorage("waterBreaksEnabled") @ObservationIgnored private var _waterBreaksEnabled: Bool = true
    @AppStorage("customBreaksEnabled") @ObservationIgnored private var _customBreaksEnabled: Bool = true
    @AppStorage("startAtLogin") @ObservationIgnored private var _startAtLogin: Bool = false
    @AppStorage("breakType") @ObservationIgnored private var _breakType: BreakType = .regular
    @AppStorage("naturalBreakDetection") @ObservationIgnored private var _naturalBreakDetection: Bool = false
    @AppStorage("customBreaks") @ObservationIgnored private var _customBreaksData: Data = Data()
    @ObservationIgnored private var _customBreaksCache: [CustomBreak]? = nil
    
    var breakInterval: TimeInterval {
        get { _breakInterval }
        set { 
            guard newValue >= 60 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2001, userInfo: [NSLocalizedDescriptionKey: "Break interval must be at least 1 minute"]))
                return
            }
            _breakInterval = newValue 
        }
    }
    
    var breakDuration: TimeInterval {
        get { _breakDuration }
        set { 
            guard newValue >= 1 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2002, userInfo: [NSLocalizedDescriptionKey: "Break duration must be at least 1 second"]))
                return
            }
            // Hard upper bound to prevent extreme values
            guard newValue <= 3600 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2102, userInfo: [NSLocalizedDescriptionKey: "Break duration cannot exceed 1 hour"]))
                return
            }
            _breakDuration = newValue 
        }
    }
    
    var microBreakInterval: TimeInterval {
        get { _microBreakInterval }
        set { 
            guard newValue >= 60 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2003, userInfo: [NSLocalizedDescriptionKey: "Micro-break interval must be at least 1 minute"]))
                return
            }
            _microBreakInterval = newValue 
        }
    }
    
    var microBreakDuration: TimeInterval {
        get { _microBreakDuration }
        set { 
            guard newValue >= 1 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2004, userInfo: [NSLocalizedDescriptionKey: "Micro-break duration must be at least 1 second"]))
                return
            }
            guard newValue <= 3600 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2104, userInfo: [NSLocalizedDescriptionKey: "Micro-break duration cannot exceed 1 hour"]))
                return
            }
            _microBreakDuration = newValue 
        }
    }
    
    var waterBreakInterval: TimeInterval {
        get { _waterBreakInterval }
        set { 
            guard newValue >= 60 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2005, userInfo: [NSLocalizedDescriptionKey: "Water break interval must be at least 1 minute"]))
                return
            }
            guard newValue <= 3600 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2105, userInfo: [NSLocalizedDescriptionKey: "Water break interval cannot exceed 1 hour"]))
                return
            }
            _waterBreakInterval = newValue 
        }
    }
    
    var waterBreakDuration: TimeInterval {
        get { _waterBreakDuration }
        set { 
            guard newValue >= 1 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2006, userInfo: [NSLocalizedDescriptionKey: "Water break duration must be at least 1 second"]))
                return
            }
            guard newValue <= 3600 else {
                ErrorHandler.shared.handleUserInputError(NSError(domain: "Lumin", code: 2106, userInfo: [NSLocalizedDescriptionKey: "Water break duration cannot exceed 1 hour"]))
                return
            }
            _waterBreakDuration = newValue 
        }
    }
    
    var isEnabled: Bool {
        get { _isEnabled }
        set { _isEnabled = newValue }
    }
    
    var regularBreaksEnabled: Bool {
        get { _regularBreaksEnabled }
        set { _regularBreaksEnabled = newValue }
    }
    
    var microBreaksEnabled: Bool {
        get { _microBreaksEnabled }
        set { _microBreaksEnabled = newValue }
    }
    
    var waterBreaksEnabled: Bool {
        get { _waterBreaksEnabled }
        set { _waterBreaksEnabled = newValue }
    }
    
    var customBreaksEnabled: Bool {
        get { _customBreaksEnabled }
        set { _customBreaksEnabled = newValue }
    }
    
    var startAtLogin: Bool {
        get { _startAtLogin }
        set { _startAtLogin = newValue }
    }
    
    
    var breakType: BreakType {
        get { _breakType }
        set { _breakType = newValue }
    }
    
    var naturalBreakDetection: Bool {
        get { _naturalBreakDetection }
        set { _naturalBreakDetection = newValue }
    }

    var customBreaks: [CustomBreak] {
        get {
            if let cache = _customBreaksCache { return cache }
            let data = _customBreaksData
            guard !data.isEmpty else { _customBreaksCache = []; return [] }
            do {
                let decoded = try JSONDecoder().decode([CustomBreak].self, from: data)
                _customBreaksCache = decoded
                return decoded
            } catch {
                Logger.debug("Failed to decode customBreaks: \(error)")
                _customBreaksCache = []
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                _customBreaksData = data
                _customBreaksCache = newValue
            } catch {
                ErrorHandler.shared.handlePersistenceError(error)
            }
        }
    }
    
    private init() {
        // Load initial settings
        loadSettings()
    }
    
    private func loadSettings() {
        // Settings are automatically loaded by @AppStorage
        Logger.debug("Settings loaded: interval=\(breakInterval), break=\(breakDuration), microInterval=\(microBreakInterval), microDuration=\(microBreakDuration), waterInterval=\(waterBreakInterval), waterDuration=\(waterBreakDuration), enabled=\(isEnabled), microEnabled=\(microBreaksEnabled), waterEnabled=\(waterBreaksEnabled), startAtLogin=\(startAtLogin), type=\(breakType), natural=\(naturalBreakDetection), customBreaks=\(customBreaks.count)")
    }
    
    func saveSettings() {
        // Settings are automatically saved by @AppStorage
        Logger.debug("Settings saved: interval=\(breakInterval), break=\(breakDuration), microInterval=\(microBreakInterval), microDuration=\(microBreakDuration), waterInterval=\(waterBreakInterval), waterDuration=\(waterBreakDuration), enabled=\(isEnabled), microEnabled=\(microBreaksEnabled), waterEnabled=\(waterBreaksEnabled), startAtLogin=\(startAtLogin), type=\(breakType), natural=\(naturalBreakDetection), customBreaks=\(customBreaks.count)")
    }
    
    func resetToDefaults() {
        breakInterval = 1200 // 20 minutes
        breakDuration = 20  // 20 seconds
        microBreakInterval = 600 // 10 minutes
        microBreakDuration = 2  // 2 seconds
        waterBreakInterval = 1800 // 30 minutes
        waterBreakDuration = 5  // 5 seconds
        isEnabled = true
        microBreaksEnabled = true
        waterBreaksEnabled = true
        customBreaksEnabled = true
        regularBreaksEnabled = true
        startAtLogin = false
        breakType = .regular
        naturalBreakDetection = false
        customBreaks = []
        
        Logger.debug("Settings reset to defaults")
    }
}
