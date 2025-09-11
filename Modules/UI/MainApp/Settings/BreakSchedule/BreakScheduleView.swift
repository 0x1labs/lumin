
import SwiftUI

struct BreakScheduleView: View {
    @State private var isEnabled = BreakManager.shared.isEnabled
    @State private var workInterval = BreakManager.shared.workInterval
    @State private var breakDuration = BreakManager.shared.breakDuration
    @State private var microBreaksEnabled = BreakManager.shared.areMicroBreaksEnabled
    @State private var microBreakInterval = BreakManager.shared.microBreakInterval
    @State private var microBreakDuration = BreakManager.shared.microBreakDuration
    @State private var waterBreaksEnabled = BreakManager.shared.areWaterBreaksEnabled
    @State private var waterBreakInterval = BreakManager.shared.waterBreakInterval
    @State private var waterBreakDuration = BreakManager.shared.waterBreakDuration
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Break Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Main breaks section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Enable Breaks", isOn: $isEnabled)
                        .onChange(of: isEnabled) { _, newValue in
                            BreakManager.shared.isEnabled = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                    
                    if isEnabled {
                        VStack(alignment: .leading, spacing: 25) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("Work Interval")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(workInterval))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $workInterval,
                                    in: 60...3600,
                                    step: 60
                                ) {
                                    Text("Work Interval")
                                } minimumValueLabel: {
                                    Text("1 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("60 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: workInterval) { _, newValue in
                                    BreakManager.shared.workInterval = newValue
                                }
                            }
                            
                            HStack {
                                Image(systemName: "cup.and.saucer")
                                    .foregroundColor(.green)
                                Text("Break Duration")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(breakDuration))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $breakDuration,
                                    in: 10...300,
                                    step: 10
                                ) {
                                    Text("Break Duration")
                                } minimumValueLabel: {
                                    Text("10 sec")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("5 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: breakDuration) { _, newValue in
                                    BreakManager.shared.breakDuration = newValue
                                }
                            }
                        }
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .center, spacing: 15) {
                            Image(systemName: "pause.circle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Breaks are currently disabled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Enable breaks to start taking regular rest periods")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                // Micro-breaks section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Enable Micro-breaks", isOn: $microBreaksEnabled)
                        .onChange(of: microBreaksEnabled) { _, newValue in
                            BreakManager.shared.areMicroBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                    
                    if microBreaksEnabled {
                        VStack(alignment: .leading, spacing: 25) {
                            HStack {
                                Image(systemName: "eye")
                                    .foregroundColor(.orange)
                                Text("Micro-break Interval")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(microBreakInterval))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $microBreakInterval,
                                    in: 60...1200,
                                    step: 60
                                ) {
                                    Text("Micro-break Interval")
                                } minimumValueLabel: {
                                    Text("1 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("20 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: microBreakInterval) { _, newValue in
                                    BreakManager.shared.microBreakInterval = newValue
                                }
                            }
                            
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.red)
                                Text("Micro-break Duration")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(microBreakDuration))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $microBreakDuration,
                                    in: 1...60,
                                    step: 1
                                ) {
                                    Text("Micro-break Duration")
                                } minimumValueLabel: {
                                    Text("1 sec")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("1 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: microBreakDuration) { _, newValue in
                                    BreakManager.shared.microBreakDuration = newValue
                                }
                            }
                        }
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .center, spacing: 15) {
                            Image(systemName: "pause.circle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Micro-breaks are currently disabled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Enable micro-breaks for frequent short rest periods")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                // Water breaks section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Enable Water Breaks", isOn: $waterBreaksEnabled)
                        .onChange(of: waterBreaksEnabled) { _, newValue in
                            BreakManager.shared.areWaterBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                    
                    if waterBreaksEnabled {
                        VStack(alignment: .leading, spacing: 25) {
                            HStack {
                                Image(systemName: "drop")
                                    .foregroundColor(.blue)
                                Text("Water Break Interval")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(waterBreakInterval))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $waterBreakInterval,
                                    in: 60...3600,
                                    step: 60
                                ) {
                                    Text("Water Break Interval")
                                } minimumValueLabel: {
                                    Text("1 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("60 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: waterBreakInterval) { _, newValue in
                                    BreakManager.shared.waterBreakInterval = newValue
                                }
                            }
                            
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.teal)
                                Text("Water Break Duration")
                                    .font(.headline)
                                Spacer()
                                Text(formatTime(waterBreakDuration))
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Slider(
                                    value: $waterBreakDuration,
                                    in: 1...120,
                                    step: 1
                                ) {
                                    Text("Water Break Duration")
                                } minimumValueLabel: {
                                    Text("1 sec")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } maximumValueLabel: {
                                    Text("2 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onChange(of: waterBreakDuration) { _, newValue in
                                    BreakManager.shared.waterBreakDuration = newValue
                                }
                            }
                        }
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .center, spacing: 15) {
                            Image(systemName: "pause.circle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Water breaks are currently disabled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Enable water breaks to stay hydrated throughout the day")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                
                Text("Customize your break intervals, durations, and types of breaks.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            isEnabled = BreakManager.shared.isEnabled
            workInterval = BreakManager.shared.workInterval
            breakDuration = BreakManager.shared.breakDuration
            microBreaksEnabled = BreakManager.shared.areMicroBreaksEnabled
            microBreakInterval = BreakManager.shared.microBreakInterval
            microBreakDuration = BreakManager.shared.microBreakDuration
            waterBreaksEnabled = BreakManager.shared.areWaterBreaksEnabled
            waterBreakInterval = BreakManager.shared.waterBreakInterval
            waterBreakDuration = BreakManager.shared.waterBreakDuration
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes) min \(seconds) sec"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(seconds) sec"
        }
    }
}
