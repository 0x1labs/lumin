import SwiftUI
import AppKit
import Combine

class BreakOverlayController: NSWindowController, NSWindowDelegate, ObservableObject {
    private let breakType: BreakType
    private let duration: TimeInterval
    private let onSkip: () -> Void
    private let selectedMessage: String
    private let customIconSystemName: String?
    private var startTime: Date = Date()
    private var timer: Timer?
    private var hostingController: NSHostingController<AnyView>?
    @Published var displayTimeRemaining: TimeInterval = 0
    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?
    private var hasSkipped = false
    private var previousApplication: NSRunningApplication?
    
    init(breakType: BreakType, duration: TimeInterval, onSkip: @escaping () -> Void) {
        self.breakType = breakType
        self.duration = duration
        self.onSkip = onSkip
        self.displayTimeRemaining = duration
        self.selectedMessage = BreakOverlayController.message(for: breakType)
        self.customIconSystemName = nil
        
        Logger.debug("Creating BreakOverlayController with breakType: \(breakType), duration: \(duration)")
        
        // Create the window with a default frame
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.frame
        
        Logger.debug("Screen frame: \(screenFrame)")
        
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Check if window was created successfully
        if window.frame.isEmpty { Logger.debug("ERROR - Window frame is empty") }
        
        super.init(window: window)
        
        // Set window properties for fullscreen overlay
        // Use different window levels based on break type
        switch breakType {
        case .regular:
            window.level = .floating  // High level for regular breaks to ensure visibility
        case .micro, .water, .custom:
            window.level = .floating  // Same level for all breaks to ensure consistent behavior
        }
        
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.delegate = self
        
        // Prevent the window from becoming key or main to avoid stealing focus
        window.isReleasedWhenClosed = false
        window.canBecomeVisibleWithoutLogin = true
        
        // Additional properties to prevent focus stealing
        window.hidesOnDeactivate = false
        
        // Create the SwiftUI view
        let overlayView = BreakOverlayView(
            breakType: breakType,
            duration: duration,
            controller: self,
            message: selectedMessage,
            customIconSystemName: customIconSystemName,
            customTitle: nil,
            onSkip: { self.skipBreak() }
        )
        
        hostingController = NSHostingController(rootView: AnyView(overlayView))
        self.contentViewController = hostingController
        Logger.debug("BreakOverlayController initialized")
    }

    // Custom break convenience initializer
    convenience init(customTitle: String, customIconSystemName: String?, duration: TimeInterval, onSkip: @escaping () -> Void) {
        self.init(breakType: .custom, duration: duration, onSkip: onSkip)
        self.setCustom(message: customTitle, iconSystemName: customIconSystemName)
    }

    private func setCustom(message: String, iconSystemName: String?) {
        // Rebuild the SwiftUI view with custom parameters
        let overlayView = BreakOverlayView(
            breakType: .custom,
            duration: duration,
            controller: self,
            message: message,
            customIconSystemName: iconSystemName,
            customTitle: message,
            onSkip: { self.skipBreak() }
        )
        hostingController = NSHostingController(rootView: AnyView(overlayView))
        self.contentViewController = hostingController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func message(for breakType: BreakType) -> String {
        switch breakType {
        case .regular:
            return "Look away from the screen"
        case .micro:
            return "Blink and check posture!"
        case .water:
            return "Take a sip of water"
        case .custom:
            return "Break time!"
        }
    }

    private static func color(fromHex hex: String?) -> Color? {
        guard let hex = hex?.trimmingCharacters(in: .whitespacesAndNewlines), !hex.isEmpty else { return nil }
        var cleaned = hex
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        var int: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&int) else { return nil }
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 8:
            a = (int & 0xff000000) >> 24
            r = (int & 0x00ff0000) >> 16
            g = (int & 0x0000ff00) >> 8
            b = (int & 0x000000ff)
        case 6:
            a = 255
            r = (int & 0x00ff0000) >> 16
            g = (int & 0x0000ff00) >> 8
            b = (int & 0x000000ff)
        default:
            return nil
        }
        return Color(.sRGB, red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0, opacity: Double(a)/255.0)
    }
    
    func show() {
        Logger.debug("Showing break overlay")
        // Reset the start time when showing the overlay
        startTime = Date()
        hasSkipped = false
        // Ensure the window is properly positioned and sized before showing
        positionWindow()
        setupKeyMonitors()
        capturePreviousApplication()
        self.showWindow(nil)
        
        // Check if we can become main and key
        if let window = self.window { Logger.debug("Window can become main: \(window.canBecomeMain), key: \(window.canBecomeKey), visible: \(window.isVisible)") }
        
        // Bring Lumin to the front so keyboard shortcuts are captured
        NSApp.activate(ignoringOtherApps: true)
        
        // Ensure the window is ordered front but without stealing focus
        if let window = self.window {
            Logger.debug("Window frame: \(window.frame)")
            window.orderFrontRegardless()
            // Remove makeKeyAndOrderFront to prevent focus stealing
            // window.makeKeyAndOrderFront(nil)
            Logger.debug("Window made key and ordered front; visible: \(window.isVisible), main: \(window.isMainWindow), key: \(window.isKeyWindow)")
        } else {
            Logger.debug("ERROR - Window is nil")
        }
        
        // Start the timer after showing the window
        startTimer()
        Logger.debug("Break overlay shown")
    }
    
    private func positionWindow() {
        guard let window = self.window else { 
            print("Lumin: ERROR - Window is nil in positionWindow")
            return 
        }
        
        // Get the screen information
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.frame
        
        Logger.debug("Positioning window on screen with frame: \(screenFrame), screen count: \(NSScreen.screens.count), main: \(String(describing: NSScreen.main))")
        
        // Position and size the window to cover the entire screen
        window.setFrame(screenFrame, display: true)
        
        // Ensure the window is on the active space
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        
        Logger.debug("Window positioned with frame: \(window.frame)")
    }
    
    private func startTimer() {
        // Set the initial time remaining
        displayTimeRemaining = duration
        Logger.debug("Timer started with initial time remaining: \(displayTimeRemaining)s")
        
        // Create a timer that updates the display time remaining based on actual elapsed time
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(self.startTime)
            let remaining = max(0, self.duration - elapsed)
            
            self.displayTimeRemaining = remaining
            
            // If time is up, skip the break
            if remaining <= 0 { timer.invalidate(); self.skipBreak() }
        }
    }
    
    private func skipBreak() {
        guard !hasSkipped else { return }
        hasSkipped = true
        timer?.invalidate()
        removeKeyMonitors()
        self.close()
        onSkip()
        restorePreviousApplication()
    }

    func windowWillClose(_ notification: Notification) {
        Logger.debug("Break overlay window will close")
        timer?.invalidate()
        removeKeyMonitors()
        restorePreviousApplication()
    }
    
    func windowDidBecomeKey(_ notification: Notification) { Logger.debug("Break overlay window became key") }
    
    func windowDidBecomeMain(_ notification: Notification) { Logger.debug("Break overlay window became main") }
    
    func windowDidExpose(_ notification: Notification) { Logger.debug("Break overlay window exposed") }

    deinit {
        removeKeyMonitors()
    }

    private func setupKeyMonitors() {
        removeKeyMonitors()

        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            if self.shouldHandle(event: event) {
                self.skipBreak()
            }
        }

        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if self.shouldHandle(event: event) {
                self.skipBreak()
                return nil
            }
            return event
        }
    }

    private func removeKeyMonitors() {
        if let localKeyMonitor {
            NSEvent.removeMonitor(localKeyMonitor)
            self.localKeyMonitor = nil
        }
        if let globalKeyMonitor {
            NSEvent.removeMonitor(globalKeyMonitor)
            self.globalKeyMonitor = nil
        }
    }

    private func shouldHandle(event: NSEvent) -> Bool {
        guard !event.isARepeat else { return false }
        switch event.keyCode {
        case 49, 53: // space or escape
            return true
        default:
            return false
        }
    }

    private func capturePreviousApplication() {
        let currentApplication = NSRunningApplication.current
        if let frontmost = NSWorkspace.shared.frontmostApplication,
           frontmost.processIdentifier != currentApplication.processIdentifier {
            previousApplication = frontmost
        } else {
            previousApplication = nil
        }
    }

    private func restorePreviousApplication() {
        if let previousApplication,
           !previousApplication.isTerminated,
           previousApplication.processIdentifier != NSRunningApplication.current.processIdentifier {
            if #available(macOS 14, *) {
                previousApplication.activate()
            } else {
                previousApplication.activate(options: [.activateIgnoringOtherApps])
            }
        }
        previousApplication = nil
    }
}
