
import SwiftUI

struct GeneralSettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("General")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Startup section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Startup")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Toggle("Launch at Login", isOn: $viewModel.startAtLogin)
                        .onChange(of: viewModel.startAtLogin) { _, newValue in
                            if newValue {
                                _ = LoginItemManager.shared.addToLoginItems()
                            } else {
                                _ = LoginItemManager.shared.removeFromLoginItems()
                            }
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                    
                    Toggle("Start Breaks Automatically", isOn: $viewModel.isEnabled)
                        .onChange(of: viewModel.isEnabled) { _, newValue in
                            BreakManager.shared.isEnabled = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Notifications section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Notifications")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Notification Style", selection: $viewModel.notificationStyle) {
                        ForEach(NotificationStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.notificationStyle) { _, newValue in
                        SettingsManager.shared.notificationStyle = newValue
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // System Integration section
                VStack(alignment: .leading, spacing: 20) {
                    Text("System Integration")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Toggle("Natural Break Detection", isOn: $viewModel.naturalBreakDetection)
                        .onChange(of: viewModel.naturalBreakDetection) { _, newValue in
                            SettingsManager.shared.naturalBreakDetection = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Advanced section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Advanced")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                        // Also update the actual settings manager
                        SettingsManager.shared.resetToDefaults()
                        // Reload settings to reflect changes
                        viewModel.loadSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                Text("Configure general application settings like startup behavior and notifications.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.loadSettings()
        }
    }
}
