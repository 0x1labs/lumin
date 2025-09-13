import SwiftUI
import AppKit

@main
struct LuminApp: App {
    init() {
        // Offer to move the app to Applications on first launch (if needed)
        AutoMoveToApplications.moveIfNeeded()

        // Notifications removed; no permission requested

        // Initialize BreakManager early
        _ = BreakManager.shared
        print("Lumin: BreakManager initialized")

        // Warm custom breaks cache early to speed up opening settings later
        _ = SettingsManager.shared.customBreaks

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
