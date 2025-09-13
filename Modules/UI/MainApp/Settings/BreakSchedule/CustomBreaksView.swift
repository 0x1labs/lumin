import SwiftUI

struct CustomBreaksView: View {
    @State private var customBreaks: [CustomBreak] = SettingsManager.shared.customBreaks
    @State private var isPresentingAdd = false
    @State private var editing: CustomBreak? = nil

    @State private var name: String = ""
    @State private var icon: String = "pills"
    @State private var interval: TimeInterval = 3600
    @State private var duration: TimeInterval = 20
    @State private var toast: String? = nil
    @State private var color: Color = .accentColor
    @State private var useGradient: Bool = false
    @State private var gradientStart: Color = .accentColor
    @State private var gradientEnd: Color = .blue
    @State private var gradientAngle: Double = 90

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Custom Breaks").font(.largeTitle).fontWeight(.bold)
                HStack { Spacer(); Button { resetForm(); isPresentingAdd = true } label: { Label("Add Custom Break", systemImage: "plus") } }

                if isPresentingAdd || editing != nil {
                    VStack(alignment: .leading, spacing: 0) {
                        AddCustomBreakSheetV2(
                            name: $name,
                            icon: $icon,
                            interval: $interval,
                            duration: $duration,
                            onCancel: { isPresentingAdd = false; editing = nil },
                            onSave: {
                                if var e = editing {
                                    e.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom Break" : name
                                    e.iconSystemName = icon
                                    e.interval = interval
                                    e.duration = duration
                                    let (norm, adjusted) = BreakManager.shared.normalizeCustomBreak(e)
                                    BreakManager.shared.updateCustomBreak(norm)
                                    if adjusted { toastMsg("Adjusted to valid range (1–720 min, 1–60 min)") }
                                } else {
                                    let newItem = CustomBreak(name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Custom Break" : name, iconSystemName: icon, interval: interval, duration: duration, isEnabled: true)
                                    let (norm, adjusted) = BreakManager.shared.normalizeCustomBreak(newItem)
                                    BreakManager.shared.addCustomBreak(norm)
                                    if adjusted { toastMsg("Adjusted to valid range (1–720 min, 1–60 min)") }
                                }
                                refresh()
                                isPresentingAdd = false
                                editing = nil
                            }
                        )
                        .padding()
                    }
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(12)
                }
                if customBreaks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up.slash").font(.largeTitle).foregroundColor(.secondary)
                        Text("No custom breaks yet").font(.headline).foregroundColor(.secondary)
                        Text("Create reminders like medicines, posture checks, and more.").foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.quaternary.opacity(0.2))
                    .cornerRadius(12)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach($customBreaks) { $item in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: item.iconSystemName)
                                    Text(item.name).font(.headline)
                                    Spacer()
                                    Toggle("Enabled", isOn: $item.isEnabled).labelsHidden().onChange(of: item.isEnabled) { _, _ in commit(item) }
                                    Button { startEditing(item) } label: { Image(systemName: "pencil") }
                                    Button(role: .destructive) { remove(item) } label: { Image(systemName: "trash") }
                                }
                                VStack(alignment: .leading, spacing: 12) {
                                    TimeInputSlider(title: "Interval", systemImage: "clock", accent: .blue, unit: .minutes, units: [.minutes, .hours], value: $item.interval, rangeSeconds: 60...43200, stepSeconds: 60, onChange: { commit(item) }, sliderWidth: 420)
                                    TimeInputSlider(title: "Duration", systemImage: "timer", accent: .teal, unit: .seconds, units: [.seconds, .minutes], value: $item.duration, rangeSeconds: 1...3600, stepSeconds: 5, onChange: { commit(item) }, sliderWidth: 420)
                                }
                            }
                            .padding(12)
                            .background(.quaternary.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .overlay(alignment: .top) {
            if let toast {
                Text(toast)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    .padding(.top, 8)
            }
        }
        // Inline editor replaces sheet; no popup
    }

    private func refresh() { customBreaks = SettingsManager.shared.customBreaks }
    private func commit(_ item: CustomBreak) {
        let result = BreakManager.shared.normalizeCustomBreak(item)
        let normalized = result.0
        let adjusted = result.1
        BreakManager.shared.updateCustomBreak(normalized)
        refresh()
        if adjusted { toastMsg("Adjusted to valid range (1–720 min, 1–60 min)") }
    }

    private func remove(_ item: CustomBreak) {
        BreakManager.shared.removeCustomBreak(id: item.id)
        refresh()
    }

    private func startEditing(_ item: CustomBreak) {
        editing = item
        name = item.name
        icon = item.iconSystemName
        interval = item.interval
        duration = item.duration
        isPresentingAdd = true
    }

    private func resetForm() {
        name = ""
        icon = "pills"
        interval = 3600
        duration = 20
    }

    private func toastMsg(_ s: String) {
        toast = s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { toast = nil }
    }
}
