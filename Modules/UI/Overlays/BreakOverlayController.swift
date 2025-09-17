import SwiftUI
import AppKit
import Combine

class BreakOverlayController: NSWindowController, NSWindowDelegate, ObservableObject {
    private let breakType: BreakType
    private let duration: TimeInterval
    private let onSkip: () -> Void
    private var selectedMessage: String
    private var customIconSystemName: String?
    private var customTitle: String?
    private var startTime: Date = Date()
    private var timer: Timer?
    private var hostingController: NSHostingController<AnyView>?
    @Published var displayTimeRemaining: TimeInterval = 0
    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?
    private var hasSkipped = false
    private var previousApplication: NSRunningApplication?
    private var additionalWindows: [NSWindow] = []
    
    init(breakType: BreakType, duration: TimeInterval, onSkip: @escaping () -> Void) {
        self.breakType = breakType
        self.duration = duration
        self.onSkip = onSkip
        self.selectedMessage = BreakOverlayController.message(for: breakType)
        self.customIconSystemName = nil
        self.customTitle = nil
        self.displayTimeRemaining = duration
        
        Logger.debug("Creating BreakOverlayController with breakType: \(breakType), duration: \(duration)")
        
        let screens = NSScreen.screens
        let screen = NSScreen.main ?? screens.first ?? NSScreen()
        let screenFrame = screen.frame
        
        Logger.debug("Screen frame: \(screenFrame)")
        
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        if window.frame.isEmpty { Logger.debug("ERROR - Window frame is empty") }
        
        super.init(window: window)
        
        configure(window: window, for: screen)
        updateMainWindowContent()
        Logger.debug("BreakOverlayController initialized")
    }

    // Custom break convenience initializer
    convenience init(customTitle: String, customIconSystemName: String?, duration: TimeInterval, onSkip: @escaping () -> Void) {
        self.init(breakType: .custom, duration: duration, onSkip: onSkip)
        self.setCustom(message: customTitle, iconSystemName: customIconSystemName)
    }

    private func setCustom(message: String, iconSystemName: String?) {
        selectedMessage = message
        customTitle = message
        customIconSystemName = iconSystemName
        updateMainWindowContent()
        refreshAdditionalWindows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(window: NSWindow, for screen: NSScreen, assignDelegate: Bool = true) {
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        if assignDelegate { window.delegate = self }
        window.isReleasedWhenClosed = false
        window.canBecomeVisibleWithoutLogin = true
        window.hidesOnDeactivate = false
        window.setFrame(screen.frame, display: true)
    }

    private func makeOverlayView() -> BreakOverlayView {
        BreakOverlayView(
            breakType: breakType,
            duration: duration,
            controller: self,
            message: selectedMessage,
            customIconSystemName: customIconSystemName,
            customTitle: customTitle,
            onSkip: { self.skipBreak() }
        )
    }

    private func updateMainWindowContent() {
        let overlayView = makeOverlayView()
        hostingController = NSHostingController(rootView: AnyView(overlayView))
        self.contentViewController = hostingController
    }

    private func refreshAdditionalWindows() {
        for window in additionalWindows {
            let hosting = NSHostingController(rootView: AnyView(makeOverlayView()))
            window.contentViewController = hosting
        }
    }

    private func setupAdditionalWindows() {
        closeAdditionalWindows()
        let screens = NSScreen.screens
        guard let mainScreen = NSScreen.main ?? screens.first else { return }
        let mainIdentifier = screenIdentifier(for: mainScreen)
        for screen in screens {
            if let mainIdentifier, let identifier = screenIdentifier(for: screen), identifier == mainIdentifier {
                continue
            }
            if screen == mainScreen { continue }
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            configure(window: window, for: screen, assignDelegate: false)
            let hosting = NSHostingController(rootView: AnyView(makeOverlayView()))
            window.contentViewController = hosting
            additionalWindows.append(window)
        }
    }

    private func closeAdditionalWindows() {
        for window in additionalWindows {
            window.orderOut(nil)
            window.close()
        }
        additionalWindows.removeAll()
    }

    private func screenIdentifier(for screen: NSScreen) -> UInt32? {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        if let number = screen.deviceDescription[key] as? NSNumber {
            return number.uint32Value
        }
        return nil
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
        setupAdditionalWindows()
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
        
        for window in additionalWindows {
            window.orderFrontRegardless()
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

        let screens = NSScreen.screens
        let screen = NSScreen.main ?? screens.first

        if let screen {
            Logger.debug("Positioning window on screen with frame: \(screen.frame), screen count: \(screens.count), main: \(String(describing: NSScreen.main))")
            configure(window: window, for: screen, assignDelegate: true)
        }

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
        closeAdditionalWindows()
        self.close()
        onSkip()
        restorePreviousApplication()
    }

    func windowWillClose(_ notification: Notification) {
        Logger.debug("Break overlay window will close")
        timer?.invalidate()
        removeKeyMonitors()
        closeAdditionalWindows()
        restorePreviousApplication()
    }
    
    func windowDidBecomeKey(_ notification: Notification) { Logger.debug("Break overlay window became key") }
    
    func windowDidBecomeMain(_ notification: Notification) { Logger.debug("Break overlay window became main") }
    
    func windowDidExpose(_ notification: Notification) { Logger.debug("Break overlay window exposed") }

    deinit {
        removeKeyMonitors()
        closeAdditionalWindows()
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
