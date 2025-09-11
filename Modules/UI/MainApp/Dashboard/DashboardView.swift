
import SwiftUI

// Dashboard view with timeline
struct DashboardView: View {
    @State private var breakManager = BreakManager.shared
    @State private var timeUntilNextBreak: TimeInterval = 0
    @State private var nextBreakType: String = ""
    @State private var countdownTimer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Status card
                VStack(alignment: .leading, spacing: 15) {
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
                    } else {
                        Text("Breaks are currently paused. Enable breaks in the settings to start receiving notifications.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Countdown section
                if breakManager.isEnabled && !breakManager.isOnBreak {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Next Break")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            // Icon based on break type
                            Group {
                                switch nextBreakType {
                                case "Regular Break":
                                    Image(systemName: "cup.and.saucer")
                                        .foregroundColor(.blue)
                                case "Micro Break":
                                    Image(systemName: "eye")
                                        .foregroundColor(.orange)
                                case "Water Break":
                                    Image(systemName: "drop")
                                        .foregroundColor(.teal)
                                default:
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextBreakType)
                                    .font(.headline)
                                Text("In \(formatCountdownTime(timeUntilNextBreak))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Timeline section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Upcoming Breaks")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if breakManager.isEnabled {
                        // Sort breaks by time until next break (shortest first)
                        let breakTimes = getSortedBreakTimes()
                        
                        if breakTimes.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "clock")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                    Text("No upcoming breaks scheduled")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(breakTimes.indices, id: \.self) { index in
                                    HStack {
                                        // Icon based on break type
                                        Group {
                                            switch breakTimes[index].type {
                                            case "Regular Break":
                                                Image(systemName: "cup.and.saucer")
                                                    .foregroundColor(.blue)
                                            case "Micro Break":
                                                Image(systemName: "eye")
                                                    .foregroundColor(.orange)
                                            case "Water Break":
                                                Image(systemName: "drop")
                                                    .foregroundColor(.teal)
                                            default:
                                                Image(systemName: "clock")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(breakTimes[index].type)
                                                .font(.headline)
                                            Text("Next in \(breakTimes[index].timeUntil)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    
                                    // Add divider except for the last item
                                    if index < breakTimes.count - 1 {
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
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Breaks are paused")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Enable breaks to see upcoming break schedule")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Quick actions
                VStack(alignment: .leading, spacing: 20) {
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 15) {
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
                .cornerRadius(12)
                
                Text("Welcome to Lumin! This is your dashboard where you can see an overview of your break statistics and upcoming breaks.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            updateTimeUntilNextBreak()
            // Update the countdown every second
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTimeUntilNextBreak()
            }
        }
        .onDisappear {
            countdownTimer?.invalidate()
        }
    }
    
    private func updateTimeUntilNextBreak() {
        // Get the next break times from the BreakManager
        let now = Date()
        var nextBreakDate: Date?
        var breakType = ""
        
        // Check regular work break
        if let workBreakDate = breakManager.nextWorkBreakDate, workBreakDate > now {
            nextBreakDate = workBreakDate
            breakType = "Regular Break"
        }
        
        // Check micro break if enabled
        if breakManager.areMicroBreaksEnabled,
           let microBreakDate = breakManager.nextMicroBreakDate,
           microBreakDate > now {
            if let currentNext = nextBreakDate {
                if microBreakDate < currentNext {
                    nextBreakDate = microBreakDate
                    breakType = "Micro Break"
                }
            } else {
                nextBreakDate = microBreakDate
                breakType = "Micro Break"
            }
        }
        
        // Check water break if enabled
        if breakManager.areWaterBreaksEnabled,
           let waterBreakDate = breakManager.nextWaterBreakDate,
           waterBreakDate > now {
            if let currentNext = nextBreakDate {
                if waterBreakDate < currentNext {
                    nextBreakDate = waterBreakDate
                    breakType = "Water Break"
                }
            } else {
                nextBreakDate = waterBreakDate
                breakType = "Water Break"
            }
        }
        
        // Update the UI with the time until the next break
        if let nextBreakDate = nextBreakDate {
            timeUntilNextBreak = nextBreakDate.timeIntervalSince(now)
            nextBreakType = breakType
        } else {
            timeUntilNextBreak = 0
            nextBreakType = ""
        }
    }
    
    private func formatCountdownTime(_ interval: TimeInterval) -> String {
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
    
    private func getSortedBreakTimes() -> [(type: String, timeUntil: String)] {
        let now = Date()
        var breakTimes: [(type: String, timeUntil: String)] = []
        
        // Dictionary to hold the actual time intervals for sorting
        var timeIntervals: [String: TimeInterval] = [:]
        
        // Add regular break
        if let workBreakDate = breakManager.nextWorkBreakDate, workBreakDate > now {
            let timeUntil = workBreakDate.timeIntervalSince(now)
            let timeString = formatTimeUntil(timeUntil)
            breakTimes.append((
                type: "Regular Break",
                timeUntil: timeString
            ))
            timeIntervals["Regular Break"] = timeUntil
        }
        
        // Add micro break if enabled
        if breakManager.areMicroBreaksEnabled,
           let microBreakDate = breakManager.nextMicroBreakDate,
           microBreakDate > now {
            let timeUntil = microBreakDate.timeIntervalSince(now)
            let timeString = formatTimeUntil(timeUntil)
            breakTimes.append((
                type: "Micro Break",
                timeUntil: timeString
            ))
            timeIntervals["Micro Break"] = timeUntil
        }
        
        // Add water break if enabled
        if breakManager.areWaterBreaksEnabled,
           let waterBreakDate = breakManager.nextWaterBreakDate,
           waterBreakDate > now {
            let timeUntil = waterBreakDate.timeIntervalSince(now)
            let timeString = formatTimeUntil(timeUntil)
            breakTimes.append((
                type: "Water Break",
                timeUntil: timeString
            ))
            timeIntervals["Water Break"] = timeUntil
        }
        
        // Sort by time until next break (shortest first)
        return breakTimes.sorted { timeIntervals[$0.type]! < timeIntervals[$1.type]! }
    }
    
    private func formatTimeUntil(_ interval: TimeInterval) -> String {
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
}
