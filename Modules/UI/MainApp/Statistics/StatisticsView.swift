
import SwiftUI

struct StatisticsView: View {
    @State private var statisticsManager = StatisticsManager.shared
    @State private var selectedPeriod = StatisticsPeriod.week
    @State private var refreshToken = UUID()
    @State private var showingResetConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Button(role: .destructive) {
                            showingResetConfirmation = true
                        } label: {
                            Label("Reset", systemImage: "arrow.uturn.backward")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.bordered)
                    }
                
                Text("View your break history, productivity statistics, and trends over time.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                // Period selector
                HStack {
                    Text("Period:")
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue.capitalized).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    Spacer()
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Summary cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    SummaryCard(
                        title: "Total Breaks",
                        value: formatNumber(statisticsManager.getDailyStats(for: Date()).totalBreaks),
                        subtitle: "Today",
                        icon: "clock",
                        color: .blue
                    )
                    
                    SummaryCard(
                        title: "Completion Rate",
                        value: String(format: "%.1f%%", statisticsManager.getCompletionRate()),
                        subtitle: "Overall",
                        icon: "checkmark.circle",
                        color: .green
                    )
                    
                    SummaryCard(
                        title: "Regular Breaks",
                        value: formatNumber(statisticsManager.getTotalBreaks(by: .regular)),
                        subtitle: "Total taken",
                        icon: "cup.and.saucer",
                        color: .orange
                    )
                    
                    SummaryCard(
                        title: "Custom Breaks",
                        value: formatNumber(getTotalCustomBreaks()),
                        subtitle: "Total taken",
                        icon: "star",
                        color: .purple
                    )
                }
                
                // Break type distribution
                VStack(alignment: .leading, spacing: 15) {
                    Text("Break Type Distribution")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    BreakTypeChart()
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Recent activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if statisticsManager.getDailyStats(for: Date()).totalBreaks == 0 {
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                Image(systemName: "chart.bar")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No break data yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Take some breaks to see statistics here")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .padding()
                    } else {
                        WeeklyStatsView()
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .id(refreshToken)
        .alert("Reset Statistics?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                statisticsManager.resetStatistics()
                refreshToken = UUID()
            }
        } message: {
            Text("This clears all recorded break history so tracking restarts from now.")
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: number), number: .none)
    }
    
    private func getTotalCustomBreaks() -> Int {
        let weeklyStats = statisticsManager.getWeeklyStats()
        return weeklyStats.reduce(0) { total, day in
            total + day.customBreaks.values.reduce(0, +)
        }
    }
}

// MARK: - Supporting Views

enum StatisticsPeriod: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.background)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct BreakTypeChart: View {
    @State private var statisticsManager = StatisticsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Regular breaks
            HStack {
                Image(systemName: "cup.and.saucer")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                Text("Regular Breaks")
                Spacer()
                Text("\(statisticsManager.getTotalBreaks(by: .regular))")
                    .fontWeight(.semibold)
            }
            
            // Micro breaks
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text("Micro Breaks")
                Spacer()
                Text("\(statisticsManager.getTotalBreaks(by: .micro))")
                    .fontWeight(.semibold)
            }
            
            // Water breaks
            HStack {
                Image(systemName: "drop")
                    .foregroundColor(.teal)
                    .frame(width: 20)
                Text("Water Breaks")
                Spacer()
                Text("\(statisticsManager.getTotalBreaks(by: .water))")
                    .fontWeight(.semibold)
            }
            
            // Custom breaks
            HStack {
                Image(systemName: "star")
                    .foregroundColor(.purple)
                    .frame(width: 20)
                Text("Custom Breaks")
                Spacer()
                Text("\(getTotalCustomBreaks())")
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func getTotalCustomBreaks() -> Int {
        let weeklyStats = statisticsManager.getWeeklyStats()
        return weeklyStats.reduce(0) { total, day in
            total + day.customBreaks.values.reduce(0, +)
        }
    }
}

struct WeeklyStatsView: View {
    @State private var statisticsManager = StatisticsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(statisticsManager.getWeeklyStats().reversed(), id: \.date) { dayStats in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatDate(dayStats.date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(dayStats.completedBreaks)/\(dayStats.totalBreaks) breaks completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(dayStats.completionRate))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(dayStats.completionRate > 80 ? .green : dayStats.completionRate > 50 ? .orange : .red)
                }
                .padding(.vertical, 4)
                
                if dayStats.date != Calendar.current.startOfDay(for: Date()) {
                    Divider()
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        }
    }
}
