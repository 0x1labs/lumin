import SwiftUI
import Observation
import Foundation
import UserNotifications
import AppKit

@Observable
class BreakManager {
    static let shared = BreakManager()
    
    // Properties for UI access
    var isEnabled: Bool {
        get { SettingsManager.shared.isEnabled }
        set {
            SettingsManager.shared.isEnabled = newValue
            if newValue {
                startTimers()
            } else {
                stopTimers()
            }
        }
    }
    
    var areMicroBreaksEnabled: Bool {
        get { SettingsManager.shared.microBreaksEnabled }
        set {
            SettingsManager.shared.microBreaksEnabled = newValue
            // Only affect the micro-break timer
            if newValue {
                restartMicroTimer()
            } else {
                microBreakTimer?.invalidate()
                microBreakTimer = nil
            }
        }
    }
    
    var areWaterBreaksEnabled: Bool {
        get { SettingsManager.shared.waterBreaksEnabled }
        set {
            SettingsManager.shared.waterBreaksEnabled = newValue
            // Only affect the water-break timer
            if newValue {
                restartWaterTimer()
            } else {
                waterBreakTimer?.invalidate()
                waterBreakTimer = nil
            }
        }
    }
    
    // Computed properties for UI access
    var workInterval: TimeInterval {
        get { SettingsManager.shared.workInterval }
        set {
            SettingsManager.shared.workInterval = newValue
            // Only restart the regular work timer
            if isEnabled { restartWorkTimer() }
        }
    }
    
    var breakDuration: TimeInterval {
        get { SettingsManager.shared.breakDuration }
        set { SettingsManager.shared.breakDuration = newValue }
    }
    
    var microBreakInterval: TimeInterval {
        get { SettingsManager.shared.microBreakInterval }
        set {
            SettingsManager.shared.microBreakInterval = newValue
            // Only restart the micro-break timer if enabled
            if isEnabled && areMicroBreaksEnabled { restartMicroTimer() }
        }
    }
    
    var microBreakDuration: TimeInterval {
        get { SettingsManager.shared.microBreakDuration }
        set { SettingsManager.shared.microBreakDuration = newValue }
    }
    
    var waterBreakInterval: TimeInterval {
        get { SettingsManager.shared.waterBreakInterval }
        set {
            SettingsManager.shared.waterBreakInterval = newValue
            // Only restart the water-break timer if enabled
            if isEnabled && areWaterBreaksEnabled { restartWaterTimer() }
        }
    }
    
    var waterBreakDuration: TimeInterval {
        get { SettingsManager.shared.waterBreakDuration }
        set { SettingsManager.shared.waterBreakDuration = newValue }
    }
    
    // Public properties to access next break times
    var nextWorkBreakDate: Date? {
        return regularBreakTimer?.fireDate
    }
    
    var nextMicroBreakDate: Date? {
        return microBreakTimer?.fireDate
    }
    
    var nextWaterBreakDate: Date? {
        return waterBreakTimer?.fireDate
    }
    
    // Computed properties to access break settings
    private var regularBreakSettings: BreakSettings {
        return BreakSettings(
            interval: SettingsManager.shared.workInterval,
            duration: SettingsManager.shared.breakDuration,
            isEnabled: SettingsManager.shared.isEnabled,
            notificationStyle: SettingsManager.shared.notificationStyle,
            startAtLogin: SettingsManager.shared.startAtLogin
        )
    }
    
    private var microBreakSettings: BreakSettings {
        return BreakSettings(
            interval: SettingsManager.shared.microBreakInterval,
            duration: SettingsManager.shared.microBreakDuration,
            isEnabled: SettingsManager.shared.microBreaksEnabled,
            notificationStyle: SettingsManager.shared.notificationStyle,
            startAtLogin: SettingsManager.shared.startAtLogin
        )
    }
    
    private var waterBreakSettings: BreakSettings {
        return BreakSettings(
            interval: SettingsManager.shared.waterBreakInterval,
            duration: SettingsManager.shared.waterBreakDuration,
            isEnabled: SettingsManager.shared.waterBreaksEnabled,
            notificationStyle: SettingsManager.shared.notificationStyle,
            startAtLogin: SettingsManager.shared.startAtLogin
        )
    }
    
    // Timer references
    private var regularBreakTimer: Timer?
    private var microBreakTimer: Timer?
    private var waterBreakTimer: Timer?
    private var breakOverlayController: BreakOverlayController?
    
    // State
    var isOnBreak = false
    
    private init() {
        print("Lumin: Initializing BreakManager")
        print("Lumin: Initial work interval: \(workInterval)")
        print("Lumin: Initial break duration: \(breakDuration)")
        print("Lumin: Initial micro break interval: \(microBreakInterval)")
        print("Lumin: Initial micro break duration: \(microBreakDuration)")
        print("Lumin: Initial water break interval: \(waterBreakInterval)")
        print("Lumin: Initial water break duration: \(waterBreakDuration)")
        print("Lumin: Initial isEnabled: \(isEnabled)")
        print("Lumin: Initial areMicroBreaksEnabled: \(areMicroBreaksEnabled)")
        print("Lumin: Initial areWaterBreaksEnabled: \(areWaterBreaksEnabled)")
        startTimers()
    }
    
    // Use NotificationManager for notifications honoring user style
    private func notify(title: String, subtitle: String) {
        let style = SettingsManager.shared.notificationStyle
        NotificationManager.shared.scheduleBreakNotification(title: title, body: subtitle, style: style)
    }
    
    // Define a function to handle breaks
    private func handleBreak(type: BreakType, duration: TimeInterval) {
        guard isEnabled else {
            print("Lumin: Breaks are disabled, not starting \(type.rawValue) break")
            return
        }

        // Prevent overlapping breaks
        guard !isOnBreak else {
            print("Lumin: A break is already in progress. Ignoring \(type.rawValue) break trigger.")
            return
        }

        print("Lumin: Starting \(type.rawValue) break for \(duration) seconds")
        isOnBreak = true

        print("Lumin: Creating BreakOverlayController with breakType: \(type)")
        breakOverlayController = BreakOverlayController(breakType: type, duration: duration, onSkip: {
            print("Lumin: Break skipped by user")
            self.endBreak(type: type)
        })
        print("Lumin: Showing BreakOverlayController")
        breakOverlayController?.show()
        print("Lumin: BreakOverlayController shown")

        // Add additional debug to check if the controller was created
        if breakOverlayController == nil {
            print("Lumin: ERROR - BreakOverlayController is nil after creation")
        } else {
            print("Lumin: BreakOverlayController created successfully")
        }

        // If a micro break was triggered, reset only the micro timer from now
        if type == .micro {
            restartMicroTimer()
        }

        notify(title: "\(type.rawValue) Break", subtitle: "Take a \(type.rawValue) break for \(Int(duration)) seconds.")

        // End the break after the duration, but ensure it's at least 1 second to allow the overlay to show
        let adjustedDuration = max(1.0, duration)
        print("Lumin: Scheduling break end in \(adjustedDuration) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + adjustedDuration) {
            print("Lumin: Break duration elapsed, ending break")
            self.endBreak(type: type)
        }
    }
    
    private func endBreak(type: BreakType) {
        Logger.debug("\(type.rawValue) break ended")
        isOnBreak = false
        notify(title: "\(type.rawValue) Break Ended", subtitle: "Your \(type.rawValue) break is over.")
        breakOverlayController?.close()
        breakOverlayController = nil

        // Restart only the corresponding timer
        switch type {
        case .regular:
            restartWorkTimer()
        case .micro:
            // Micro timer was reset at trigger time; leave others untouched
            break
        case .water:
            restartWaterTimer()
        }
    }
    
    // Define a function to start timers
    func startTimers() {
        guard isEnabled else { 
        Logger.debug("Breaks are disabled, not starting timers")
            return 
        }
        
        Logger.debug("Starting all break timers")
        Logger.debug("Work interval: \(workInterval), Break duration: \(breakDuration)")
        Logger.debug("Micro break interval: \(microBreakInterval), Micro break duration: \(microBreakDuration)")
        Logger.debug("Water break interval: \(waterBreakInterval), Water break duration: \(waterBreakDuration)")
        
        // Create regular break timer if not present
        if regularBreakTimer == nil {
            Logger.debug("Creating regular break timer with interval \(workInterval)")
            let regular = Timer(timeInterval: workInterval, repeats: true) { _ in
                Logger.debug("Regular break timer fired")
                self.handleBreak(type: .regular, duration: self.breakDuration)
            }
            regular.tolerance = workInterval * 0.1
            RunLoop.main.add(regular, forMode: .common)
            regularBreakTimer = regular
            Logger.debug("Regular break timer created with fire date: \(String(describing: regularBreakTimer?.fireDate))")
        } else {
            Logger.debug("Regular break timer already active; not recreating")
        }
        
        // Start micro break timer if enabled
        if areMicroBreaksEnabled {
            Logger.debug("Creating micro break timer with interval \(microBreakInterval)")
            if microBreakTimer == nil {
                let micro = Timer(timeInterval: microBreakInterval, repeats: true) { _ in
                    Logger.debug("Micro break timer fired")
                    self.handleBreak(type: .micro, duration: self.microBreakDuration)
                }
                micro.tolerance = microBreakInterval * 0.1
                RunLoop.main.add(micro, forMode: .common)
                microBreakTimer = micro
                Logger.debug("Micro break timer created with fire date: \(String(describing: microBreakTimer?.fireDate))")
            } else {
                Logger.debug("Micro break timer already active; not recreating")
            }
        }
        
        // Start water break timer if enabled
        if areWaterBreaksEnabled {
            Logger.debug("Creating water break timer with interval \(waterBreakInterval)")
            if waterBreakTimer == nil {
                let water = Timer(timeInterval: waterBreakInterval, repeats: true) { _ in
                    Logger.debug("Water break timer fired")
                    self.handleBreak(type: .water, duration: self.waterBreakDuration)
                }
                water.tolerance = waterBreakInterval * 0.1
                RunLoop.main.add(water, forMode: .common)
                waterBreakTimer = water
                Logger.debug("Water break timer created with fire date: \(String(describing: waterBreakTimer?.fireDate))")
            } else {
                Logger.debug("Water break timer already active; not recreating")
            }
        }
        
        Logger.debug("Timers started - Regular: \(regularBreakTimer != nil), Micro: \(microBreakTimer != nil), Water: \(waterBreakTimer != nil)")
    }
    
    // Function to skip the next break
    func skipNextBreak() {
        Logger.debug("Skipping next break")
        // Restart the work timer from now
        restartWorkTimer()
    }
    
    // Function to start a break now
    func startBreak() {
        Logger.debug("Starting break now")
        // Use a reasonable default duration for manual breaks
        let duration = 20.0
        handleBreak(type: .regular, duration: duration)
    }
    
    // Function to restart the work timer from the current time
    private func restartWorkTimer() {
        Logger.debug("Restarting work timer from current time")
        
        // Invalidate the existing regular break timer
        regularBreakTimer?.invalidate()
        
        // Start a new regular break timer with the work interval
        let regular = Timer(timeInterval: workInterval, repeats: true) { _ in
            Logger.debug("Regular break timer fired")
            self.handleBreak(type: .regular, duration: self.breakDuration)
        }
        regular.tolerance = workInterval * 0.1
        RunLoop.main.add(regular, forMode: .common)
        regularBreakTimer = regular
        
        Logger.debug("Work timer restarted with interval: \(workInterval)s")
    }

    // Restart the micro-break timer from now (does not affect other timers)
    private func restartMicroTimer() {
        guard isEnabled, areMicroBreaksEnabled else { return }
        microBreakTimer?.invalidate()
        let micro = Timer(timeInterval: microBreakInterval, repeats: true) { _ in
            Logger.debug("Micro break timer fired")
            self.handleBreak(type: .micro, duration: self.microBreakDuration)
        }
        micro.tolerance = microBreakInterval * 0.1
        RunLoop.main.add(micro, forMode: .common)
        microBreakTimer = micro
        Logger.debug("Micro timer restarted with interval: \(microBreakInterval)s")
    }

    // Restart the water-break timer from now (does not affect other timers)
    private func restartWaterTimer() {
        guard isEnabled, areWaterBreaksEnabled else { return }
        waterBreakTimer?.invalidate()
        let water = Timer(timeInterval: waterBreakInterval, repeats: true) { _ in
            Logger.debug("Water break timer fired")
            self.handleBreak(type: .water, duration: self.waterBreakDuration)
        }
        water.tolerance = waterBreakInterval * 0.1
        RunLoop.main.add(water, forMode: .common)
        waterBreakTimer = water
        Logger.debug("Water timer restarted with interval: \(waterBreakInterval)s")
    }
    
    // Function to start a break now
    func startBreakNow() {
        Logger.debug("Starting break now")
        // Use the regular break settings duration
        let duration = breakDuration
        handleBreak(type: .regular, duration: duration)
    }
    
    // Function to stop all timers
    func stopTimers() {
        Logger.debug("Stopping all break timers")
        regularBreakTimer?.invalidate()
        microBreakTimer?.invalidate()
        waterBreakTimer?.invalidate()
        isOnBreak = false
    }
    
    func toggleEnabled() {
        isEnabled.toggle()
        Logger.debug("Breaks \(isEnabled ? "enabled" : "disabled") at \(Date())")
    }
    
    // Function to update break settings
    func updateRegularBreakSettings(interval: TimeInterval, duration: TimeInterval) {
        SettingsManager.shared.workInterval = interval
        SettingsManager.shared.breakDuration = duration
        // Restart only the regular timer
        if isEnabled { restartWorkTimer() }
    }
    
    func updateMicroBreakSettings(interval: TimeInterval, duration: TimeInterval) {
        SettingsManager.shared.microBreakInterval = interval
        SettingsManager.shared.microBreakDuration = duration
        // Restart only the micro timer if enabled
        if isEnabled && areMicroBreaksEnabled { restartMicroTimer() }
    }
    
    func updateWaterBreakSettings(interval: TimeInterval, duration: TimeInterval) {
        SettingsManager.shared.waterBreakInterval = interval
        SettingsManager.shared.waterBreakDuration = duration
        // Restart only the water timer if enabled
        if isEnabled && areWaterBreaksEnabled { restartWaterTimer() }
    }
}
