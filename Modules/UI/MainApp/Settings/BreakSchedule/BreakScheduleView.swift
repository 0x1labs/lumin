import SwiftUI

struct BreakScheduleView: View {
    @State private var isEnabled = BreakManager.shared.isEnabled
    @State private var regularBreaksEnabled = BreakManager.shared.areRegularBreaksEnabled
    @State private var workInterval = BreakManager.shared.breakInterval
    @State private var breakDuration = BreakManager.shared.breakDuration
    @State private var microBreaksEnabled = BreakManager.shared.areMicroBreaksEnabled
    @State private var microBreakInterval = BreakManager.shared.microBreakInterval
    @State private var microBreakDuration = BreakManager.shared.microBreakDuration
    @State private var waterBreaksEnabled = BreakManager.shared.areWaterBreaksEnabled
    @State private var waterBreakInterval = BreakManager.shared.waterBreakInterval
    @State private var waterBreakDuration = BreakManager.shared.waterBreakDuration
    // Custom breaks state
    @State private var customBreaks: [CustomBreak] = SettingsManager.shared.customBreaks
    @State private var customBreaksEnabled: Bool = BreakManager.shared.areCustomBreaksEnabled
    @State private var isPresentingAddCustom = false
    @State private var editingCustom: CustomBreak? = nil
    @State private var newCustomName: String = ""
    @State private var newCustomIcon: String = "pills"
    @State private var newCustomInterval: TimeInterval = 3600
    @State private var newCustomDuration: TimeInterval = 20
    @State private var newCustomColor: Color = .accentColor
    @State private var newUseGradient: Bool = false
    @State private var newGradientStart: Color = .accentColor
    @State private var newGradientEnd: Color = .blue
    @State private var newGradientAngle: Double = 90
    @State private var toastMessage: String? = nil
    @AppStorage("addCustomSheetWidth") private var sheetWidth: Double = 920
    @AppStorage("addCustomSheetHeight") private var sheetHeight: Double = 640

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Break Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Regular breaks section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Enable Regular Breaks", isOn: $regularBreaksEnabled)
                        .onChange(of: regularBreaksEnabled) { _, newValue in
                            BreakManager.shared.areRegularBreaksEnabled = newValue
                        }
                        .toggleStyle(.switch)
                        .controlSize(.large)

                    if regularBreaksEnabled {
                        VStack(alignment: .leading, spacing: 18) {
                            TimeInputSlider(
                                title: "Interval", systemImage: "clock", accent: .blue,
                                unit: .minutes, units: [.minutes, .hours], value: $workInterval,
                                rangeSeconds: 60...43200, stepSeconds: 60,
                                onChange: {
                                    BreakManager.shared.breakInterval = workInterval
                                }, sliderWidth: 460)
                            TimeInputSlider(
                                title: "Duration", systemImage: "cup.and.saucer", accent: .green,
                                unit: .seconds, units: [.seconds, .minutes], value: $breakDuration,
                                rangeSeconds: 10...300, stepSeconds: 10,
                                onChange: {
                                    BreakManager.shared.breakDuration = breakDuration
                                }, sliderWidth: 460)
                        }
                        .padding()
                        .background(.quaternary.opacity(0.2))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .center, spacing: 15) {
                            Image(systemName: "pause.circle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Regular breaks are currently disabled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Enable regular breaks to schedule longer rest periods")
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
                        VStack(alignment: .leading, spacing: 18) {
                            TimeInputSlider(
                                title: "Interval", systemImage: "eye", accent: .orange,
                                unit: .minutes, units: [.minutes], value: $microBreakInterval,
                                rangeSeconds: 60...1200, stepSeconds: 60,
                                onChange: {
                                    BreakManager.shared.microBreakInterval = microBreakInterval
                                }, sliderWidth: 460)
                            TimeInputSlider(
                                title: "Duration", systemImage: "timer", accent: .red,
                                unit: .seconds, units: [.seconds, .minutes],
                                value: $microBreakDuration, rangeSeconds: 1...60, stepSeconds: 1,
                                onChange: {
                                    BreakManager.shared.microBreakDuration = microBreakDuration
                                }, sliderWidth: 460)
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
                        VStack(alignment: .leading, spacing: 18) {
                            TimeInputSlider(
                                title: "Interval", systemImage: "drop", accent: .blue,
                                unit: .minutes, units: [.minutes], value: $waterBreakInterval,
                                rangeSeconds: 60...3600, stepSeconds: 60,
                                onChange: {
                                    BreakManager.shared.waterBreakInterval = waterBreakInterval
                                }, sliderWidth: 460)
                            TimeInputSlider(
                                title: "Duration", systemImage: "timer", accent: .teal,
                                unit: .seconds, units: [.seconds, .minutes],
                                value: $waterBreakDuration, rangeSeconds: 1...120, stepSeconds: 1,
                                onChange: {
                                    BreakManager.shared.waterBreakDuration = waterBreakDuration
                                }, sliderWidth: 460)
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

                // Custom Breaks entry removed from this page per request

                Text("Customize your break intervals, durations, and types of breaks.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            isEnabled = BreakManager.shared.isEnabled
            regularBreaksEnabled = BreakManager.shared.areRegularBreaksEnabled
            workInterval = BreakManager.shared.breakInterval
            breakDuration = BreakManager.shared.breakDuration
            microBreaksEnabled = BreakManager.shared.areMicroBreaksEnabled
            microBreakInterval = BreakManager.shared.microBreakInterval
            microBreakDuration = BreakManager.shared.microBreakDuration
            waterBreaksEnabled = BreakManager.shared.areWaterBreaksEnabled
            waterBreakInterval = BreakManager.shared.waterBreakInterval
            waterBreakDuration = BreakManager.shared.waterBreakDuration
            customBreaks = SettingsManager.shared.customBreaks
            customBreaksEnabled = BreakManager.shared.areCustomBreaksEnabled
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
                        let (norm, adjusted) = BreakManager.shared.normalizeCustomBreak(editing)
                        BreakManager.shared.updateCustomBreak(norm)
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
                        let (norm, adjusted) = BreakManager.shared.normalizeCustomBreak(newItem)
                        BreakManager.shared.addCustomBreak(norm)
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
    // Energy / focus
    "bolt", "bolt.fill", "flame", "flame.fill",
]
#if false  // Legacy sheet kept for reference; excluded from build
    private struct AddCustomBreakSheet: View {
        @Binding var name: String
        @Binding var icon: String
        @Binding var interval: TimeInterval
        @Binding var duration: TimeInterval
        @Binding var color: Color
        @Binding var useGradient: Bool
        @Binding var gradientStart: Color
        @Binding var gradientEnd: Color
        @Binding var gradientAngle: Double
        var onCancel: () -> Void
        var onSave: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("New Custom Break")
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack {
                    Text("Name")
                        .frame(width: 120, alignment: .leading)
                    TextField("e.g. Medicines", text: $name)
                }

                HStack(alignment: .top) {
                    Text("Icon")
                        .frame(width: 120, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 12) {
                            ForEach(customIconOptions, id: \.self) { option in
                                Button(action: { icon = option }) {
                                    Image(systemName: option)
                                        .frame(width: 32, height: 32)
                                        .padding(8)
                                        .background(
                                            icon == option
                                                ? Color.accentColor.opacity(0.2) : Color.clear
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(height: 56)
                }

                HStack {
                    Text("Interval")
                        .frame(width: 120, alignment: .leading)
                    Slider(value: $interval, in: 300...14400, step: 60) { Text("Interval") }
                    Text(formatTimeLocal(interval))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                        .frame(width: 120, alignment: .trailing)
                }

                HStack {
                    Text("Duration")
                        .frame(width: 120, alignment: .leading)
                    Slider(value: $duration, in: 10...900, step: 5) { Text("Duration") }
                    Text(formatTimeLocal(duration))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                        .frame(width: 120, alignment: .trailing)
                }

                HStack {
                    Text("Color")
                        .frame(width: 120, alignment: .leading)
                    ColorPicker("Color", selection: $color)
                        .labelsHidden()
                    Spacer()
                }

                Toggle("Use Gradient", isOn: $useGradient)

                if useGradient {
                    HStack(spacing: 16) {
                        HStack {
                            Text("Start")
                                .frame(width: 120, alignment: .leading)
                            ColorPicker("Start", selection: $gradientStart).labelsHidden()
                        }
                        HStack {
                            Text("End")
                                .frame(width: 60, alignment: .leading)
                            ColorPicker("End", selection: $gradientEnd).labelsHidden()
                        }
                        Spacer()
                    }
                    HStack {
                        Text("Angle")
                            .frame(width: 120, alignment: .leading)
                        Slider(value: $gradientAngle, in: 0...360, step: 1)
                        Text("\(Int(gradientAngle))°").monospacedDigit().foregroundColor(.secondary)
                    }
                }

                HStack {
                    Spacer()
                    Button("Cancel", role: .cancel, action: onCancel)
                    Button("Save", action: onSave).buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .onAppear {
                if name.isEmpty { name = "" }
            }
        }
    }

    private func formatTimeLocal(_ interval: TimeInterval) -> String {
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
#endif

extension BreakScheduleView {
    fileprivate func resetNewCustomFields() {
        newCustomName = ""
        newCustomIcon = customIconOptions.first ?? "pills"
        newCustomInterval = 3600
        newCustomDuration = 20
        newCustomColor = .accentColor
        newUseGradient = false
        newGradientStart = .accentColor
        newGradientEnd = .blue
        newGradientAngle = 90
    }

    fileprivate func applyCustomUpdate(_ updated: CustomBreak) {
        let (norm, adjusted) = BreakManager.shared.normalizeCustomBreak(updated)
        BreakManager.shared.updateCustomBreak(norm)
        customBreaks = SettingsManager.shared.customBreaks
        if adjusted { showToast("Adjusted to valid range (1–720 min, 1–60 min)") }
    }

    fileprivate func removeCustom(_ item: CustomBreak) {
        BreakManager.shared.removeCustomBreak(id: item.id)
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

struct TimeInputSlider: View {
    let title: String
    let systemImage: String
    let accent: Color
    let unit: TimeUnit
    var units: [TimeUnit] = []  // include to show unit dropdown when multiple provided
    @Binding var value: TimeInterval  // stored in seconds
    let rangeSeconds: ClosedRange<Double>
    let stepSeconds: Double
    var onChange: () -> Void = {}
    var sliderWidth: CGFloat = 340
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
                                value = min(
                                    max(seconds, rangeSeconds.lowerBound), rangeSeconds.upperBound)
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
            Slider(
                value: Binding(
                    get: { value / factor },
                    set: { v in
                        value = (v * factor).rounded()
                        scheduleDebouncedChange()
                    }), in: (rangeSeconds.lowerBound / factor)...(rangeSeconds.upperBound / factor),
                step: stepSeconds / factor
            ) {
                EmptyView()
            } minimumValueLabel: {
                Text(minLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Text(maxLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: sliderWidth, alignment: .leading)
            if let hint {
                Text(hint)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear { currentUnit = (effectiveUnits.contains(unit) ? unit : effectiveUnits.first!) }
    }

    private var minLabel: String {
        switch currentUnit {
        case .seconds: return "\(Int(rangeSeconds.lowerBound)) sec"
        case .minutes: return "\(Int(rangeSeconds.lowerBound / 60)) min"
        case .hours: return "\(Int(rangeSeconds.lowerBound / 3600)) h"
        }
    }
    private var maxLabel: String {
        switch currentUnit {
        case .seconds:
            return Int(rangeSeconds.upperBound) % 60 == 0
                ? "\(Int(rangeSeconds.upperBound/60)) min" : "\(Int(rangeSeconds.upperBound)) sec"
        case .minutes:
            return "\(Int(rangeSeconds.upperBound / 60)) min"
        case .hours:
            return "\(Int(rangeSeconds.upperBound / 3600)) hr"
        }
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

func colorFromHex(_ hex: String?) -> Color {
    guard let hex = hex?.trimmingCharacters(in: .whitespacesAndNewlines), !hex.isEmpty else {
        return .accentColor
    }
    var cleaned = hex
    if cleaned.hasPrefix("#") { cleaned.removeFirst() }
    var int: UInt64 = 0
    guard Scanner(string: cleaned).scanHexInt64(&int) else { return .accentColor }
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch cleaned.count {
    case 8:
        a = (int & 0xff00_0000) >> 24
        r = (int & 0x00ff_0000) >> 16
        g = (int & 0x0000_ff00) >> 8
        b = (int & 0x0000_00ff)
    case 6:
        a = 255
        r = (int & 0x00ff_0000) >> 16
        g = (int & 0x0000_ff00) >> 8
        b = (int & 0x0000_00ff)
    default:
        return .accentColor
    }
    return Color(
        .sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0,
        opacity: Double(a) / 255.0)
}

// MARK: - Add Custom Break V2 (Option 3 layout)
struct AddCustomBreakSheetV2: View {
    @Binding var name: String
    @Binding var icon: String
    @Binding var interval: TimeInterval
    @Binding var duration: TimeInterval
    @Binding var color: Color
    @Binding var useGradient: Bool
    @Binding var gradientStart: Color
    @Binding var gradientEnd: Color
    @Binding var gradientAngle: Double
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
        self._color = .constant(.accentColor)
        self._useGradient = .constant(false)
        self._gradientStart = .constant(.accentColor)
        self._gradientEnd = .constant(.blue)
        self._gradientAngle = .constant(90)
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
                        TimeInputSlider(
                            title: "", systemImage: "clock", accent: .blue, unit: .minutes,
                            units: [.minutes, .hours], value: $interval, rangeSeconds: 60...43200,
                            stepSeconds: 60, sliderWidth: 420, titleAbove: "Interval")
                        TimeInputSlider(
                            title: "", systemImage: "timer", accent: .teal, unit: .seconds,
                            units: [.seconds, .minutes], value: $duration, rangeSeconds: 5...900,
                            stepSeconds: 5, sliderWidth: 420, titleAbove: "Duration")
                    }
                }

                // Right column - Color / Gradient
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Color / Gradient").font(.subheadline)
                        Spacer()
                        Toggle("Gradient", isOn: $useGradient).labelsHidden().toggleStyle(.switch)
                    }
                    ZStack(alignment: .topLeading) {
                        // Gradient panel
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("Start").font(.caption).foregroundColor(.secondary)
                                    ColorPicker("Start", selection: $gradientStart).labelsHidden()
                                }
                                VStack(alignment: .leading) {
                                    Text("End").font(.caption).foregroundColor(.secondary)
                                    ColorPicker("End", selection: $gradientEnd).labelsHidden()
                                }
                            }
                            HStack(spacing: 10) {
                                Text("Angle").font(.caption).foregroundColor(.secondary)
                                Slider(value: $gradientAngle, in: 0...360, step: 1)
                                Text("\(Int(gradientAngle))°").monospacedDigit().foregroundColor(
                                    .secondary)
                            }
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [gradientStart, gradientEnd]),
                                        startPoint: startPointForAngle(gradientAngle),
                                        endPoint: endPointForAngle(gradientAngle))
                                )
                                .frame(width: 240, height: 140)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Presets").font(.caption).foregroundColor(.secondary)
                                LazyVGrid(
                                    columns: [
                                        GridItem(.fixed(44)), GridItem(.fixed(44)),
                                        GridItem(.fixed(44)), GridItem(.fixed(44)),
                                        GridItem(.fixed(44)),
                                    ], spacing: 8
                                ) {
                                    ForEach(Self.gradientPresets.indices, id: \.self) { i in
                                        let p = Self.gradientPresets[i]
                                        Button(action: {
                                            useGradient = true
                                            gradientStart = p.start
                                            gradientEnd = p.end
                                            gradientAngle = p.angle
                                        }) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [p.start, p.end]
                                                        ), startPoint: startPointForAngle(p.angle),
                                                        endPoint: endPointForAngle(p.angle))
                                                )
                                                .frame(width: 44, height: 28)
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .opacity(useGradient ? 1 : 0)
                        .allowsHitTesting(useGradient)

                        // Solid color panel
                        // Solid color panel removed
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
    static let quickSwatches: [Color] = [
        Color.yellow, Color.blue, Color.green, Color.red, Color.purple, Color.orange,
    ]
    struct GradientPreset {
        let start: Color
        let end: Color
        let angle: Double
    }
    static let gradientPresets: [GradientPreset] = [
        GradientPreset(
            start: Color(red: 0.99, green: 0.56, blue: 0.56),
            end: Color(red: 0.99, green: 0.35, blue: 0.65), angle: 135),
        GradientPreset(
            start: Color(red: 0.60, green: 0.90, blue: 0.72),
            end: Color(red: 0.18, green: 0.80, blue: 0.44), angle: 135),
        GradientPreset(
            start: Color(red: 0.54, green: 0.63, blue: 1.00),
            end: Color(red: 0.29, green: 0.27, blue: 0.92), angle: 135),
        GradientPreset(
            start: Color(red: 0.89, green: 0.70, blue: 1.00),
            end: Color(red: 0.89, green: 0.40, blue: 0.87), angle: 135),
        GradientPreset(
            start: Color(red: 0.51, green: 0.86, blue: 0.99),
            end: Color(red: 0.24, green: 0.63, blue: 0.96), angle: 135),
        GradientPreset(
            start: Color(red: 0.98, green: 0.55, blue: 0.47),
            end: Color(red: 0.89, green: 0.22, blue: 0.46), angle: 135),
    ]
}

// Quick color swatches and gradient presets
private let quickSwatches: [Color] = [
    Color.yellow, Color.blue, Color.green, Color.red, Color.purple, Color.orange,
]

private struct GradientPreset {
    let start: Color
    let end: Color
    let angle: Double
}
private let gradientPresets: [GradientPreset] = [
    GradientPreset(
        start: Color(red: 0.99, green: 0.56, blue: 0.56),
        end: Color(red: 0.99, green: 0.35, blue: 0.65), angle: 135),
    GradientPreset(
        start: Color(red: 0.60, green: 0.90, blue: 0.72),
        end: Color(red: 0.18, green: 0.80, blue: 0.44), angle: 135),
    GradientPreset(
        start: Color(red: 0.54, green: 0.63, blue: 1.00),
        end: Color(red: 0.29, green: 0.27, blue: 0.92), angle: 135),
    GradientPreset(
        start: Color(red: 0.89, green: 0.70, blue: 1.00),
        end: Color(red: 0.89, green: 0.40, blue: 0.87), angle: 135),
    GradientPreset(
        start: Color(red: 0.51, green: 0.86, blue: 0.99),
        end: Color(red: 0.24, green: 0.63, blue: 0.96), angle: 135),
    GradientPreset(
        start: Color(red: 0.98, green: 0.55, blue: 0.47),
        end: Color(red: 0.89, green: 0.22, blue: 0.46), angle: 135),
]

// Angle helpers for preview
private func startPointForAngle(_ angle: Double) -> UnitPoint {
    let radians = angle * .pi / 180
    let dx = cos(radians)
    let dy = sin(radians)
    let sx = (1 - dx) / 2
    let sy = (1 - dy) / 2
    return UnitPoint(x: sx, y: sy)
}
private func endPointForAngle(_ angle: Double) -> UnitPoint {
    let radians = angle * .pi / 180
    let dx = cos(radians)
    let dy = sin(radians)
    let ex = (1 + dx) / 2
    let ey = (1 + dy) / 2
    return UnitPoint(x: ex, y: ey)
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
