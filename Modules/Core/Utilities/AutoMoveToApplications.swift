import Foundation
import AppKit

enum AutoMoveToApplications {
    static func moveIfNeeded() {
        let fileManager = FileManager.default
        let bundlePath = Bundle.main.bundlePath
        let bundleURL = URL(fileURLWithPath: bundlePath)
        let bundleName = bundleURL.lastPathComponent

        // Already in /Applications or ~/Applications
        if isInApplications(path: bundlePath) {
            return
        }

        // Only attempt when launched from a disk image or outside Applications
        // Common case: /Volumes/<DMGName>/App.app
        let isOnMountedVolume = bundlePath.hasPrefix("/Volumes/")

        // Destination preferences: /Applications first, then ~/Applications fallback
        let globalDest = URL(fileURLWithPath: "/Applications").appendingPathComponent(bundleName)
        let userDest = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications")
            .appendingPathComponent(bundleName)

        // Ensure ~/Applications exists for fallback
        let userAppsDir = userDest.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: userAppsDir.path) {
            try? fileManager.createDirectory(at: userAppsDir, withIntermediateDirectories: true)
        }

        // Ask user politely before moving (async to ensure app finished launching)
        if isOnMountedVolume || !isInApplications(path: bundlePath) {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Move to Applications?"
                alert.informativeText = "This will move \(bundleName) to the Applications folder and relaunch it."
                alert.addButton(withTitle: "Move to Applications")
                alert.addButton(withTitle: "Not Now")

                let response = alert.runModal()
                guard response == .alertFirstButtonReturn else { return }

                // Try /Applications first
                if copyApp(from: bundleURL, to: globalDest) {
                    relaunch(from: globalDest)
                    return
                }

                // Fallback to ~/Applications
                if copyApp(from: bundleURL, to: userDest) {
                    relaunch(from: userDest)
                    return
                }
            }
        }
    }

    private static func isInApplications(path: String) -> Bool {
        if path.hasPrefix("/Applications/") { return true }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home + "/Applications/") { return true }
        return false
    }

    private static func copyApp(from source: URL, to destination: URL) -> Bool {
        let fm = FileManager.default
        // Remove any existing item at destination to avoid copy errors
        if fm.fileExists(atPath: destination.path) {
            // Try moving to Trash; if that fails, remove permanently
            if (try? fm.trashItem(at: destination, resultingItemURL: nil)) == nil {
                try? fm.removeItem(at: destination)
            }
        }
        do {
            try fm.copyItem(at: source, to: destination)
            return true
        } catch {
            NSLog("AutoMove: copy failed: \(error.localizedDescription)")
            return false
        }
    }

    private static func relaunch(from appURL: URL) {
        // Open the moved app, then quit current instance
        NSWorkspace.shared.open(appURL)
        if NSApp != nil {
            NSApp.terminate(nil)
        } else {
            exit(0)
        }
    }
}
