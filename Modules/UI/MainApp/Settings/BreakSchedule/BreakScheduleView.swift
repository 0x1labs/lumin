import SwiftUI

struct BreakScheduleView: View {
    @Environment(BreakManager.self) private var breakManager
    @State private var regularBreaksEnabled = false
    @State private var workInterval: TimeInterval = 0
    @State private var breakDuration: TimeInterval = 0
    @State private var microBreaksEnabled = false
    @State private var microBreakInterval: TimeInterval = 0
    @State private var microBreakDuration: TimeInterval = 0
    @State private var waterBreaksEnabled = false
    @State private var waterBreakInterval: TimeInterval = 0
    @State private var waterBreakDuration: TimeInterval = 0
    // Custom breaks state
    @State private var customBreaks: [CustomBreak] = []
    @State private var isPresentingAddCustom = false
    @State private var editingCustom: CustomBreak? = nil
    @State private var newCustomName: String = ""
    @State private var newCustomIcon: String = "pills"
    @State private var newCustomInterval: TimeInterval = 3600
    @State private var newCustomDuration: TimeInterval = 20
    @State private var toastMessage: String? = nil
    @AppStorage("addCustomSheetWidth") private var sheetWidth: Double = 920
    @AppStorage("addCustomSheetHeight") private var sheetHeight: Double = 640

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Break Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Regular breaks section
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Regular Breaks", isOn: $regularBreaksEnabled)
                        .onChange(of: regularBreaksEnabled) { _, newValue in
                            breakManager.areRegularBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)

                    if regularBreaksEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            TimeInputView(
                                title: "Interval", systemImage: "clock", accent: .blue,
                                unit: .minutes, units: [.minutes, .hours], value: $workInterval,
                                rangeSeconds: 60...43200, stepSeconds: 60,
                                onChange: {
                                    breakManager.breakInterval = workInterval
                                })
                            TimeInputView(
                                title: "Duration", systemImage: "cup.and.saucer", accent: .green,
                                unit: .seconds, units: [.seconds, .minutes], value: $breakDuration,
                                rangeSeconds: 10...300, stepSeconds: 10,
                                onChange: {
                                    breakManager.breakDuration = breakDuration
                                })
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pause.circle")
                                    .foregroundColor(.secondary)
                                Text("Regular breaks are currently disabled")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            Text("Enable regular breaks to schedule longer rest periods")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    }
                }

                // Micro-breaks section
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Micro-breaks", isOn: $microBreaksEnabled)
                        .onChange(of: microBreaksEnabled) { _, newValue in
                            breakManager.areMicroBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)

                    if microBreaksEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            TimeInputView(
                                title: "Interval", systemImage: "eye", accent: .orange,
                                unit: .minutes, units: [.minutes, .hours], value: $microBreakInterval,
                                rangeSeconds: 60...1200, stepSeconds: 60,
                                onChange: {
                                    breakManager.microBreakInterval = microBreakInterval
                                })
                            TimeInputView(
                                title: "Duration", systemImage: "timer", accent: .red,
                                unit: .seconds, units: [.seconds, .minutes],
                                value: $microBreakDuration, rangeSeconds: 1...60, stepSeconds: 1,
                                onChange: {
                                    breakManager.microBreakDuration = microBreakDuration
                                })
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pause.circle")
                                    .foregroundColor(.secondary)
                                Text("Micro-breaks are currently disabled")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            Text("Enable micro-breaks for frequent short rest periods")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    }
                }

                // Water breaks section
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Water Breaks", isOn: $waterBreaksEnabled)
                        .onChange(of: waterBreaksEnabled) { _, newValue in
                            breakManager.areWaterBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)

                    if waterBreaksEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            TimeInputView(
                                title: "Interval", systemImage: "drop", accent: .blue,
                                unit: .minutes, units: [.minutes, .hours], value: $waterBreakInterval,
                                rangeSeconds: 60...3600, stepSeconds: 60,
                                onChange: {
                                    breakManager.waterBreakInterval = waterBreakInterval
                                })
                            TimeInputView(
                                title: "Duration", systemImage: "timer", accent: .teal,
                                unit: .seconds, units: [.seconds, .minutes],
                                value: $waterBreakDuration, rangeSeconds: 1...120, stepSeconds: 1,
                                onChange: {
                                    breakManager.waterBreakDuration = waterBreakDuration
                                })
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "pause.circle")
                                    .foregroundColor(.secondary)
                                Text("Water breaks are currently disabled")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            Text("Enable water breaks to stay hydrated throughout the day")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(8)
                    }
                }

                // Custom Breaks entry removed from this page per request

                Text("Customize your break intervals, durations, and types of breaks.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .font(.caption)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            regularBreaksEnabled = breakManager.areRegularBreaksEnabled
            workInterval = breakManager.breakInterval
            breakDuration = breakManager.breakDuration
            microBreaksEnabled = breakManager.areMicroBreaksEnabled
            microBreakInterval = breakManager.microBreakInterval
            microBreakDuration = breakManager.microBreakDuration
            waterBreaksEnabled = breakManager.areWaterBreaksEnabled
            waterBreakInterval = breakManager.waterBreakInterval
            waterBreakDuration = breakManager.waterBreakDuration
            customBreaks = SettingsManager.shared.customBreaks
        }
        .overlay(alignment: .top) {
            if let toastMessage {
                Text(toastMessage)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    .padding(.top, 8)
            }
        }
        .sheet(isPresented: $isPresentingAddCustom) {
            AddCustomBreakSheetV2(
                name: $newCustomName,
                icon: $newCustomIcon,
                interval: $newCustomInterval,
                duration: $newCustomDuration,

                onCancel: {
                    isPresentingAddCustom = false
                    editingCustom = nil
                },
                onSave: {
                    if var editing = editingCustom {
                        editing.name =
                            newCustomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? "Custom Break" : newCustomName
                        editing.iconSystemName = newCustomIcon
                        editing.interval = newCustomInterval
                        editing.duration = newCustomDuration
                        let (norm, adjusted) = breakManager.normalizeCustomBreak(editing)
                        breakManager.updateCustomBreak(norm)
                        if adjusted { showToast("Adjusted to valid range (1–720 min, 1–60 min)") }
                    } else {
                        let newItem = CustomBreak(
                            name: newCustomName.trimmingCharacters(in: .whitespacesAndNewlines)
                                .isEmpty ? "Custom Break" : newCustomName,
                            iconSystemName: newCustomIcon,
                            interval: newCustomInterval,
                            duration: newCustomDuration,
                            isEnabled: true
                        )
                        let (norm, adjusted) = breakManager.normalizeCustomBreak(newItem)
                        breakManager.addCustomBreak(norm)
                        if adjusted { showToast("Adjusted to valid range (1–720 min, 1–60 min)") }
                    }
                    customBreaks = SettingsManager.shared.customBreaks
                    isPresentingAddCustom = false
                    editingCustom = nil
                }
            )
            .frame(
                minWidth: 720, idealWidth: sheetWidth, maxWidth: .infinity,
                minHeight: 520, idealHeight: sheetHeight, maxHeight: .infinity
            )
            .onSizeChange { size in
                sheetWidth = size.width
                sheetHeight = size.height
            }
        }
    }

}

private let customIconOptions: [String] = [
    // Health & wellness
    "pills", "pills.fill", "bandage", "bandage.fill", "cross.case", "cross.case.fill", "heart",
    "heart.fill", "bolt.heart", "bolt.heart.fill", "lungs", "stethoscope", "figure.mind.and.body",
    "figure.cooldown", "bed.double", "bed.double.fill",
    // Hydration / breaks
    "drop", "drop.fill", "cup.and.saucer", "cup.and.saucer.fill", "glass.and.water", "timer",
    "hourglass", "hourglass.circle", "hourglass.badge.plus",
    // Activity
    "figure.walk", "figure.walk.circle", "figure.run", "bicycle", "dumbbell", "sportscourt",
    "figure.yoga",
    // Nature / mood
    "leaf", "leaf.fill", "sun.max", "sun.max.fill", "sunrise", "moon", "moon.fill", "moon.stars",
    "cloud.sun", "cloud.sun.fill",
    // Work & study
    "book", "book.fill", "graduationcap", "graduationcap.fill", "laptopcomputer", "keyboard",
    "desktopcomputer", "brain.head.profile", "brain",
    // Communication
    "phone", "phone.fill", "message", "message.fill", "envelope", "envelope.fill",
    // Planning
    "calendar", "calendar.circle", "clock", "alarm", "bell", "bell.fill", "bell.badge",
    // Misc productivity
    "doc.text", "doc.text.fill", "briefcase", "briefcase.fill", "globe", "house", "house.fill",
    "bookmark", "bookmark.fill",
    // Food
    "fork.knife", "fork.knife.circle", "takeoutbag.and.cup.and.straw",
    "takeoutbag.and.cup.and.straw.fill",
    // Beauty & self-care
    "sparkles", "sparkles.rectangle", "camera", "camera.fill", "camera.circle", "camera.circle.fill",
    "wand.and.rays", "wand.and.rays.inverse", "wand.and.stars", "wand.and.stars.inverse",
    // Energy / focus
    "bolt", "bolt.fill", "flame", "flame.fill",
]


extension BreakScheduleView {
    fileprivate func resetNewCustomFields() {
        newCustomName = ""
        newCustomIcon = customIconOptions.first ?? "pills"
        newCustomInterval = 3600
        newCustomDuration = 20
    }

    fileprivate func applyCustomUpdate(_ updated: CustomBreak) {
        let (norm, adjusted) = breakManager.normalizeCustomBreak(updated)
        breakManager.updateCustomBreak(norm)
        customBreaks = SettingsManager.shared.customBreaks
        if adjusted { showToast("Adjusted to valid range (1–720 min, 1–60 min)") }
    }

    fileprivate func removeCustom(_ item: CustomBreak) {
        breakManager.removeCustomBreak(id: item.id)
        customBreaks = SettingsManager.shared.customBreaks
    }

    fileprivate func startEditing(_ item: CustomBreak) {
        editingCustom = item
        newCustomName = item.name
        newCustomIcon = item.iconSystemName
        newCustomInterval = item.interval
        newCustomDuration = item.duration
        isPresentingAddCustom = true
    }

    fileprivate func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { toastMessage = nil }
    }
}

// MARK: - Color <-> Hex helpers
func hexFromColor(_ color: Color) -> String {
    #if canImport(AppKit)
        let ns = NSColor(color)
        let srgb = ns.usingColorSpace(.sRGB) ?? ns
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        let ai = Int(round(a * 255))
        return String(format: "#%02X%02X%02X%02X", ai, ri, gi, bi)
    #else
        return ""
    #endif
}

// MARK: - Preset pickers
enum TimeUnit { case seconds, minutes, hours }

struct TimeInputView: View {
    let title: String
    let systemImage: String
    let accent: Color
    let unit: TimeUnit
    var units: [TimeUnit] = []  // include to show unit dropdown when multiple provided
    @Binding var value: TimeInterval  // stored in seconds
    let rangeSeconds: ClosedRange<Double>
    let stepSeconds: Double
    var onChange: () -> Void = {}
    var hint: String? = nil
    var debounceMs: Int = 200
    var titleAbove: String? = nil

    @State private var currentUnit: TimeUnit = .seconds
    @State private var pendingChange: DispatchWorkItem? = nil

    private var effectiveUnits: [TimeUnit] { units.isEmpty ? [unit] : units }
    private var factor: Double {
        switch currentUnit {
        case .seconds: return 1
        case .minutes: return 60
        case .hours: return 3600
        }
    }
    private var unitLabel: String {
        switch currentUnit {
        case .seconds: return "sec"
        case .minutes: return "min"
        case .hours: return "hr"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let titleAbove {
                Text(titleAbove)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            HStack(spacing: 12) {
                Image(systemName: systemImage).foregroundColor(accent)
                Text(title).font(.headline).lineLimit(1)
                Spacer()
                HStack(spacing: 6) {
                    TextField(
                        "0",
                        value: Binding(
                            get: { value / factor },
                            set: { newVal in
                                let seconds = (newVal * factor).rounded()
                                // Ensure minimum value is at least 1 second
                                let minValue = max(1, rangeSeconds.lowerBound)
                                value = min(
                                    max(seconds, minValue), rangeSeconds.upperBound)
                                scheduleDebouncedChange()
                            }), formatter: integerFormatter
                    )
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .onSubmit { onChange() }
                    if effectiveUnits.count > 1 {
                        Picker(
                            "",
                            selection: Binding(
                                get: { currentUnit },
                                set: { newUnit in
                                    // keep value in seconds; only UI changes
                                    currentUnit = newUnit
                                })
                        ) {
                            ForEach(effectiveUnits, id: \.self) { u in
                                Text(label(for: u)).tag(u)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                    } else {
                        Text(unitLabel).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.gray.opacity(0.3))
                )
            }
            if let hint {
                Text(hint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear { currentUnit = (effectiveUnits.contains(unit) ? unit : effectiveUnits.first!) }
    }

    private func label(for u: TimeUnit) -> String {
        u == .seconds ? "sec" : (u == .minutes ? "min" : "hr")
    }

    private func scheduleDebouncedChange() {
        pendingChange?.cancel()
        let work = DispatchWorkItem(block: { onChange() })
        pendingChange = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(debounceMs), execute: work)
    }
}

private let integerFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    f.minimum = 0
    f.maximum = 999999
    return f
}()




// MARK: - Add Custom Break V2 (Option 3 layout)
struct AddCustomBreakSheetV2: View {
    @Binding var name: String
    @Binding var icon: String
    @Binding var interval: TimeInterval
    @Binding var duration: TimeInterval
    var onCancel: () -> Void
    var onSave: () -> Void

    // Convenience init for callers that don't use color/gradient
    init(
        name: Binding<String>, icon: Binding<String>, interval: Binding<TimeInterval>,
        duration: Binding<TimeInterval>, onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self._name = name
        self._icon = icon
        self._interval = interval
        self._duration = duration
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Custom Break").font(.title2).fontWeight(.semibold)
            Text("Create a new personalized break schedule.").foregroundColor(.secondary)
            HStack(alignment: .top, spacing: 28) {
                // Left column
                VStack(alignment: .leading, spacing: 14) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Icon").font(.subheadline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(customIconOptions, id: \.self) { option in
                                    Button(action: { icon = option }) {
                                        Image(systemName: option)
                                            .frame(width: 22, height: 22)
                                            .padding(6)
                                            .background(
                                                icon == option
                                                    ? Color.accentColor.opacity(0.15) : Color.clear
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8).stroke(
                                                    icon == option
                                                        ? Color.accentColor
                                                        : Color.gray.opacity(0.2))
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        TimeInputView(
                            title: "", systemImage: "clock", accent: .blue, unit: .minutes,
                            units: [.minutes, .hours], value: $interval, rangeSeconds: 60...43200,
                            stepSeconds: 60, titleAbove: "Interval")
                        TimeInputView(
                            title: "", systemImage: "timer", accent: .teal, unit: .seconds,
                            units: [.seconds, .minutes], value: $duration, rangeSeconds: 5...900,
                            stepSeconds: 5, titleAbove: "Duration")
                    }
                }
            }
            HStack {
                Spacer()
                Button("Cancel", role: .cancel, action: onCancel)
                Button("Save Break", action: onSave).buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    // Lazy preset data (instantiated only when the sheet is shown)
}



// MARK: - Size reporting for resizable sheets
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

extension View {
    fileprivate func onSizeChange(_ perform: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
}
