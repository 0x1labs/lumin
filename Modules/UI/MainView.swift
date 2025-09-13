
import SwiftUI

#if os(macOS)
import AppKit
#endif

struct MainView: View {
    @State private var selection: NavigationItem? = .dashboard
    @State private var breakManager = BreakManager.shared
    
    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selection) {
                    Section("Main") {
                        NavigationLink("Dashboard", value: NavigationItem.dashboard)
                        NavigationLink("Statistics", value: NavigationItem.statistics)
                    }
                    
                    Section("Preferences") {
                        NavigationLink("General", value: NavigationItem.general)
                        NavigationLink("Break Schedule", value: NavigationItem.breakSchedule)
                        NavigationLink("Custom Breaks", value: NavigationItem.customBreaks)
                        NavigationLink("Appearance", value: NavigationItem.appearance)
                        NavigationLink("Shortcuts", value: NavigationItem.shortcuts)
                    }

                    Section("About") {
                        NavigationLink("About", value: NavigationItem.about)
                        NavigationLink("Help", value: NavigationItem.help)
                    }
                }
                .navigationDestination(for: NavigationItem.self) { item in
                    switch item {
                    case .dashboard:
                        DashboardView()
                    case .statistics:
                        StatisticsView()
                    case .general:
                        GeneralSettingsView()
                    case .breakSchedule:
                        BreakScheduleView()
                    case .customBreaks:
                        CustomBreaksView()
                    case .appearance:
                        AppearanceView()
                    case .shortcuts:
                        ShortcutsView()
                    case .about:
                        AboutView()
                    case .help:
                        HelpView()
                    }
                }
                
                // About section at the bottom
                VStack {
                    Divider()
                    HStack {
                        Spacer()
                        Text("Lumin v1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                }
                .padding(.bottom, 2) // Add a small padding to ensure it's not cut off
            }
            .navigationTitle("Lumin")
            .listStyle(.sidebar)
        } detail: {
            // Default to DashboardView when no selection is made
            DashboardView()
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// Navigation item enum
enum NavigationItem: String, CaseIterable, Hashable {
    case dashboard = "Dashboard"
    case statistics = "Statistics"
    case general = "General"
    case breakSchedule = "Break Schedule"
    case customBreaks = "Custom Breaks"
    case appearance = "Appearance"
    case shortcuts = "Shortcuts"
    case about = "About"
    case help = "Help"
}
