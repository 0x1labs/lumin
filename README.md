# Lumin

Lumin is a macOS app that helps you take regular breaks to reduce eye strain and stay productive. It uses a lightweight SwiftUI overlay for breaks and simple timers for scheduling.

## Features

- Work breaks with configurable intervals
- Micro-breaks with different types (blink, posture)
- Water break reminders
- Statistics tracking
- Menu bar integration for quick access
- Configurable settings

## UI Overview

- Dashboard with upcoming breaks, status, and quick actions
- Settings (General, Break Schedule, Appearance, Shortcuts)
- Full-screen overlay during breaks (Regular/Micro/Water)

## Build & Run

Requirements:
- macOS 14+ (Sonoma)
- Xcode 15+

Option A — Xcode
1. Open the folder in Xcode
2. Build and Run (Cmd+R)

Option B — CLI app bundle (dev):
```bash
./run.sh
```
This compiles with SwiftPM, assembles `Lumin.app`, copies the app icon, ad‑hoc signs with the provided entitlements, and launches the app.

Notes:
- The included `Info.plist` sets `CFBundleIconFile` to `AppIcon`, and `Resources/AppIcon.icns` is bundled by `run.sh`.
- The package manifest is `swift-tools-version:5.9` for wider compatibility with Xcode 15.

## Project Structure

```
Lumin/
├── LuminApp.swift                     # App entry
├── Modules/
│   ├── Core/
│   │   ├── BreakManager.swift         # Timers and break scheduling
│   │   ├── SettingsManager.swift      # @AppStorage-backed settings
│   │   ├── Models/                    # Data models
│   │   └── Utilities/                 # Logger, errors, extensions
│   ├── Services/
│   │   └── NotificationManager.swift  # UNUserNotificationCenter wrapper
│   └── UI/
│       ├── MainApp/                   # Dashboard & Settings views
│       └── Overlays/                  # Break overlay window + view
├── Resources/                         # App icon, asset catalog
├── Package.swift
├── Info.plist
├── Lumin.entitlements
└── run.sh

## Permissions
- Notifications: requested on launch; can be adjusted under macOS System Settings → Notifications → Lumin

## Development
- Do not commit built artifacts (e.g., `Lumin.app/`). A `.gitignore` is provided.
- The `run.sh` script is for local development convenience and uses ad‑hoc signing.

## Contributing
Issues and PRs are welcome! Please file an issue with steps to reproduce for bugs.

## License
See `LICENSE`.
```
