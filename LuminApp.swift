import SwiftUI
import AppKit
import UserNotifications

@main
struct LuminApp: App {
    init() {
        // Offer to move the app to Applications on first launch (if needed)
        AutoMoveToApplications.moveIfNeeded()

        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }

        // Initialize BreakManager early
        _ = BreakManager.shared
        print("Lumin: BreakManager initialized")

        // Check if another instance is already running
        let runningApps = NSWorkspace.shared.runningApplications
        let currentBundleID = Bundle.main.bundleIdentifier
        
        if let bundleID = currentBundleID {
            let sameBundleApps = runningApps.filter { app in
                app.bundleIdentifier == bundleID && 
                app.processIdentifier != NSRunningApplication.current.processIdentifier
            }
            
            if !sameBundleApps.isEmpty {
                // Another instance is running, focus it and exit
                sameBundleApps.first?.activate(options: [])
                NSApp.terminate(nil)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}
