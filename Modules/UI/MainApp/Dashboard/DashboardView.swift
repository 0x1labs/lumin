import SwiftUI

struct DashboardView: View {
    @Environment(BreakManager.self) private var breakManager

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date
            let upcomingBreaks = breakManager.scheduledBreaks(after: now)
            let nextBreak = upcomingBreaks.first

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Quick actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            Button(action: {
                                if breakManager.isEnabled && !breakManager.isOnBreak {
                                    breakManager.startBreak()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Break")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .disabled(!breakManager.isEnabled || breakManager.isOnBreak)
                            .buttonStyle(.borderedProminent)

                            Button(action: {
                                breakManager.skipNextBreak()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right")
                                    Text("Skip Next")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .disabled(!breakManager.isEnabled)
                            .buttonStyle(.bordered)

                            Button(action: {
                                breakManager.toggleEnabled()
                            }) {
                                HStack {
                                    Image(systemName: breakManager.isEnabled ? "pause.fill" : "play.fill")
                                    Text(breakManager.isEnabled ? "Pause" : "Resume")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(8)

                    // Status card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "eye")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Current Status")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(breakManager.isEnabled ? (breakManager.isOnBreak ? "On Break" : "Active") : "Paused")
                                .font(.headline)
                                .foregroundColor(breakManager.isEnabled ? (breakManager.isOnBreak ? .green : .blue) : .orange)
                        }

                        if breakManager.isEnabled {
                            Text("Breaks are currently enabled. You'll receive notifications when it's time for a break.")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else {
                            Text("Breaks are currently paused. Enable breaks in the settings to start receiving notifications.")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(8)

                    // Countdown section
                    if breakManager.isEnabled, !breakManager.isOnBreak, let nextBreak {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Next Break")
                                .font(.headline)
                                .fontWeight(.semibold)

                            HStack {
                                Image(systemName: systemImage(for: nextBreak))
                                    .foregroundColor(iconColor(for: nextBreak))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nextBreak.title)
                                        .font(.headline)
                                    Text("In \(formattedTimeRemaining(until: nextBreak.fireDate, relativeTo: now))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    }

                    // Timeline section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Breaks")
                            .font(.headline)
                            .fontWeight(.semibold)

                        if breakManager.isEnabled {
                            if upcomingBreaks.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 10) {
                                        Image(systemName: "clock")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("No upcoming breaks scheduled")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                            } else {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(upcomingBreaks) { entry in
                                        HStack {
                                            Image(systemName: systemImage(for: entry))
                                                .foregroundColor(iconColor(for: entry))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.title)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                Text("Next in \(formattedTimeRemaining(until: entry.fireDate, relativeTo: now))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }

                                        if entry.id != upcomingBreaks.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "pause.circle")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    Text("Breaks are paused")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Enable breaks to see upcoming break schedule")
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .font(.caption)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding()
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(8)

                    Text("Welcome to Lumin! This is your dashboard where you can see an overview of your break statistics and upcoming breaks.")
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Spacer()
                }
                .padding()
            }
        }
    }

    private func formattedTimeRemaining(until date: Date, relativeTo reference: Date) -> String {
        let interval = max(0, date.timeIntervalSince(reference))
        return formatInterval(interval)
    }

    private func formatInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private func systemImage(for entry: BreakScheduleEntry) -> String {
        entry.iconSystemName ?? "clock"
    }

    private func iconColor(for entry: BreakScheduleEntry) -> Color {
        switch entry.kind {
        case .regular:
            return .blue
        case .micro:
            return .orange
        case .water:
            return .teal
        case .custom:
            return .accentColor
        }
    }
}
