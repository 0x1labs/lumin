
import SwiftUI

struct GeneralSettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Startup & Behavior
            VStack(alignment: .leading, spacing: 12) {
                Text("Startup & Behavior")
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
                
                Toggle("Enable Breaks Automatically", isOn: $viewModel.isEnabled)
                    .onChange(of: viewModel.isEnabled) { _, newValue in
                        BreakManager.shared.isEnabled = newValue
                    }
                    .toggleStyle(.switch)
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(8)
            
            // Advanced
            VStack(alignment: .leading, spacing: 12) {
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
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            Text("Configure general application settings like startup behavior.")
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            viewModel.loadSettings()
        }
    }
}
