# Lumin Developer Guide

This document captures the essentials for building, debugging, and contributing to Lumin as a developer. Pair it with the main [README](../README.md) for product-level context.

## Prerequisites

- macOS 14 (Sonoma) or newer
- Xcode 15 (Swift 5.9 toolchain) installed with command-line tools
- An Apple Developer ID certificate (optional, only needed for signed distribution)

## Project Layout

- `Modules/Core` – Break scheduling, settings persistence, statistics, and shared utilities.
- `Modules/UI/MainApp` – Dashboard, settings panels, and statistics views.
- `Modules/UI/Overlays` – Break overlay window/controller and SwiftUI presentation.
- `Docs/` – User and developer documentation.
- `run.sh` – SwiftPM helper script that builds, bundles, ad-hoc signs, and launches `Lumin.app`.

## Building & Running

### Xcode
1. Open the repository root in Xcode (`File → Open…`).
2. Select the *Lumin* scheme and your desired run destination.
3. Build and run with **⌘R**.

### Swift Package Manager
```
./run.sh
```
This script performs a clean SwiftPM build, assembles the macOS app bundle, copies resources (e.g., `AppIcon.icns`), applies ad-hoc signing, and launches the app.

### Troubleshooting
- Ensure Rosetta is not interfering; the binary is native arm64/x86_64.
- If the overlay does not appear, check `BreakManager.shared.isEnabled` in the dashboard or logs (`Console.app`).
- For permissions (notifications), remove and reinstall the app, then grant permissions again via System Settings.

## Development Workflow

### Overlay & Scheduling
- The overlay listens for `Esc` or `Space` to skip breaks; verify keyboard handling when altering overlay UI.
- Pause/resume is centralized in `BreakManager.toggleEnabled()`. The timers are rebuilt when resuming, so derived UI should observe manager state rather than maintain separate timers.
- Multi-monitor overlays are spawned in `BreakOverlayController`; remember to keep additional windows in sync when tweaking visuals.

### Statistics
- `StatisticsManager` records taken vs. skipped breaks. The overlay now calls separate completion and skip closures to keep counts accurate.
- Use the reset button in the Statistics tab to clear stored history quickly during testing.

### Styling
- Gradients and overlay preview live in `AppearanceView.swift`. New presets should be added in both the picker list and the preview switch.

## Distribution & Signing

Unsigned builds fire Gatekeeper warnings. To ship signed/notarized builds:
1. Enroll in the Apple Developer Program (US$99/year).
2. Codesign with your *Developer ID Application* certificate (`codesign --deep --force --sign ... Lumin.app`).
3. Notarize the archive via `xcrun notarytool submit` and staple the ticket (`xcrun stapler staple Lumin.app`).

Detailed end-user instructions for handling unsigned builds are in [`Docs/UserInstallation.md`](UserInstallation.md).

## Testing Checklist

- [ ] Dashboard quick actions start, skip, and pause/resume breaks.
- [ ] Overlays appear on every connected display and relinquish focus to the previous app after closing.
- [ ] Keyboard shortcuts (`Esc`, `Space`) skip breaks reliably.
- [ ] Statistics update for both successful and skipped breaks; reset button works.
- [ ] Appearance settings update overlays and preview in real time.

## Contributing

1. Fork the repository and create a topic branch.
2. Run `swift build` (and `./run.sh` for an integration test) before opening PRs.
3. Document user-facing changes in `README.md` or under `Docs/`.
4. Attach screenshots for UI changes when relevant.

Issues and pull requests are welcome. Please include reproduction steps for bug reports and reference related tickets when submitting patches.
