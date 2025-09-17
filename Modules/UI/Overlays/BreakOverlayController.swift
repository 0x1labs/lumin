import SwiftUI
import AppKit
import Combine

/// Controls the break overlay window and mirrors it across every connected display.
class BreakOverlayController: NSWindowController, NSWindowDelegate, ObservableObject {
    private let breakType: BreakType
    private let duration: TimeInterval
    private let onSkip: () -> Void
    private let onComplete: () -> Void

    private var selectedMessage: String
    private var customIconSystemName: String?
    private var customTitle: String?

    private var startTime: Date = Date()
    private var timer: Timer?
    private var hostingController: NSHostingController<AnyView>?
    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?
    private var previousApplication: NSRunningApplication?
    private var completionState: Bool?

    private var additionalWindows: [NSWindow] = []

    @Published var displayTimeRemaining: TimeInterval = 0

    init(breakType: BreakType, duration: TimeInterval, onSkip: @escaping () -> Void, onComplete: @escaping () -> Void) {
        self.breakType = breakType
        self.duration = duration
        self.onSkip = onSkip
        self.onComplete = onComplete
        self.selectedMessage = BreakOverlayController.message(for: breakType)
        self.displayTimeRemaining = duration

        Logger.debug("Creating BreakOverlayController with breakType: \(breakType), duration: \(duration)")

        let primaryScreen = NSScreen.main ?? NSScreen.screens.first ?? NSScreen()
        let window = NSWindow(
            contentRect: primaryScreen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        super.init(window: window)

        configure(window: window, for: primaryScreen, assignDelegate: true)
        updateMainWindowContent()
    }

    convenience init(customTitle: String, customIconSystemName: String?, duration: TimeInterval, onSkip: @escaping () -> Void, onComplete: @escaping () -> Void) {
        self.init(breakType: .custom, duration: duration, onSkip: onSkip, onComplete: onComplete)
        setCustom(message: customTitle, iconSystemName: customIconSystemName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setCustom(message: String, iconSystemName: String?) {
        selectedMessage = message
        customTitle = message
        customIconSystemName = iconSystemName
        updateMainWindowContent()
        refreshAdditionalWindows()
    }

    // MARK: - Window lifecycle

    func show() {
        Logger.debug("Showing break overlay")
        startTime = Date()
        displayTimeRemaining = duration
        completionState = nil

        positionPrimaryWindow()
        setupAdditionalWindows()
        setupKeyMonitors()
        capturePreviousApplication()

        showWindow(nil)
        window?.orderFrontRegardless()
        additionalWindows.forEach { $0.orderFrontRegardless() }

        NSApp.activate(ignoringOtherApps: true)
        startTimer()
    }

    private func positionPrimaryWindow() {
        guard let window = window else { return }
        let screens = NSScreen.screens
        let primary = NSScreen.main ?? screens.first
        if let primary {
            configure(window: window, for: primary, assignDelegate: true)
            if let hosting = hostingController {
                install(hosting, in: window)
            }
        }
    }

    private func setupAdditionalWindows() {
        closeAdditionalWindows()
        let screens = NSScreen.screens
        guard let primary = NSScreen.main ?? screens.first else { return }

        for screen in screens where screen != primary {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            configure(window: window, for: screen, assignDelegate: false)
            let hosting = NSHostingController(rootView: AnyView(makeOverlayView()))
            install(hosting, in: window)
            additionalWindows.append(window)
        }
    }

    private func closeAdditionalWindows() {
        additionalWindows.forEach { window in
            window.orderOut(nil)
            window.close()
        }
        additionalWindows.removeAll()
    }

    private func configure(window: NSWindow, for screen: NSScreen, assignDelegate: Bool) {
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
        let hosting = NSHostingController(rootView: AnyView(makeOverlayView()))
        hostingController = hosting
        if let window = window {
            install(hosting, in: window)
        } else {
            contentViewController = hosting
        }
    }

    private func refreshAdditionalWindows() {
        for window in additionalWindows {
            let hosting = NSHostingController(rootView: AnyView(makeOverlayView()))
            install(hosting, in: window)
        }
    }

    private func install(_ hosting: NSHostingController<AnyView>, in window: NSWindow) {
        window.contentViewController = hosting
        let bounds = window.contentView?.bounds ?? NSRect(origin: .zero, size: window.frame.size)
        hosting.view.frame = bounds
        hosting.view.autoresizingMask = [.width, .height]
    }

    // MARK: - Timer handling

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            let elapsed = Date().timeIntervalSince(self.startTime)
            let remaining = max(0, self.duration - elapsed)
            self.displayTimeRemaining = remaining
            if remaining <= 0 {
                timer.invalidate()
                self.finishBreak(completed: true)
            }
        }
    }

    private func skipBreak() {
        finishBreak(completed: false)
    }

    private func finishBreak(completed: Bool) {
        guard completionState == nil else { return }
        completionState = completed
        timer?.invalidate()
        removeKeyMonitors()
        closeAdditionalWindows()
        close()
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        timer?.invalidate()
        removeKeyMonitors()
        closeAdditionalWindows()

        if let completed = completionState {
            completed ? onComplete() : onSkip()
        } else {
            onSkip()
        }

        restorePreviousApplication()
        completionState = nil
    }

    // MARK: - Keyboard handling

    private func setupKeyMonitors() {
        removeKeyMonitors()

        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.shouldHandle(event: event) else { return }
            self.skipBreak()
        }

        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if self.shouldHandle(event: event) {
                self.skipBreak()
                return nil
            }
            return event
        }
    }

    private func removeKeyMonitors() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
    }

    private func shouldHandle(event: NSEvent) -> Bool {
        guard !event.isARepeat else { return false }
        switch event.keyCode {
        case 49, 53: // Space, Escape
            return true
        default:
            return false
        }
    }

    // MARK: - Focus management

    private func capturePreviousApplication() {
        let current = NSRunningApplication.current
        if let frontmost = NSWorkspace.shared.frontmostApplication,
           frontmost.processIdentifier != current.processIdentifier {
            previousApplication = frontmost
        } else {
            previousApplication = nil
        }
    }

    private func restorePreviousApplication() {
        guard let previousApplication,
              !previousApplication.isTerminated,
              previousApplication.processIdentifier != NSRunningApplication.current.processIdentifier else {
            self.previousApplication = nil
            return
        }

        if #available(macOS 14, *) {
            previousApplication.activate()
        } else {
            previousApplication.activate(options: [.activateIgnoringOtherApps])
        }
        self.previousApplication = nil
    }

    // MARK: - Utilities

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
}
