import SwiftUI

struct AppearanceView: View {
    @AppStorage("overlayOpacity") private var overlayOpacity = 0.9
    @AppStorage("overlayTheme") private var overlayTheme = "dark"
    @AppStorage("overlayBackgroundColor") private var overlayBackgroundColor = "blue"
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Appearance")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Customize how break notifications and overlays look.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Theme Settings Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.blue)
                        Text("Theme Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Overlay Theme", systemImage: "circle.righthalf.filled")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Picker("Theme", selection: $overlayTheme) {
                                ForEach(["auto", "light", "dark"], id: \.self) { theme in
                                    Text(theme.capitalized).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            if overlayTheme == "auto" {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.secondary)
                                    Text("Uses your system's current appearance setting (\(systemColorScheme == .dark ? "Dark" : "Light"))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Overlay Opacity", systemImage: "slider.horizontal.3")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Slider(value: $overlayOpacity, in: 0.5...1.0, step: 0.05)
                                HStack {
                                    Text("0%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(overlayOpacity * 100))%")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("100%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Background Settings Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "square.fill")
                            .foregroundColor(.purple)
                        Text("Background Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Overlay Background", systemImage: "paintpalette")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("Background style for break overlay windows")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        GradientPickerView(selectedGradient: $overlayBackgroundColor)
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Preview Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.orange)
                        Text("Preview")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    Text("Example of how break overlays will appear")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    OverlayPreview(
                        theme: overlayTheme,
                        systemColorScheme: systemColorScheme,
                        opacity: overlayOpacity,
                        backgroundColor: overlayBackgroundColor
                    )
                    .frame(height: 250)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                // Information Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("About These Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    Text("These settings control the appearance of break notifications and overlays that appear during your break reminders.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("Overlay background affects the main background of break overlays")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("Accent color affects break type icons and interface elements")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("Overlay theme and opacity affect the semi-transparent overlay effect")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Appearance")
    }

// MARK: - Gradient Picker

struct GradientPickerView: View {
    @Binding var selectedGradient: String
    
    private let gradients: [(name: String, colors: [Color])] = [
        ("Blue", [.blue, .purple]),
        ("Green", [.green, .blue]),
        ("Orange", [.orange, .pink]),
        ("Purple", [.purple, .pink]),
        ("Red", [.red, .orange]),
        ("Pastel 1", [.pink.opacity(0.7), .blue.opacity(0.7)]),
        ("Pastel 2", [.yellow.opacity(0.7), .green.opacity(0.7)]),
        ("Pastel 3", [.purple.opacity(0.7), .pink.opacity(0.7)]),
        ("Aurora", [.mint, .blue, .purple.opacity(0.8)]),
        ("Lava", [.red, .orange, .yellow]),
        ("Forest", [.green, .teal, Color(hue: 0.38, saturation: 0.6, brightness: 0.4)]),
        ("Midnight", [Color(hue: 0.65, saturation: 0.6, brightness: 0.2), .black]),
        ("Rose", [Color(red: 0.98, green: 0.74, blue: 0.8), Color(red: 0.86, green: 0.38, blue: 0.54)]),
        ("Frosted Glass", [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
        ("Frosted Glass Black", [Color.black.opacity(0.3), Color.black.opacity(0.1)]),
        ("Sunset", [Color.orange, Color.pink, Color.purple]),
        ("Ocean", [Color.blue.opacity(0.8), Color.teal.opacity(0.8)]),
        ("Galaxy", [Color.black, Color.purple.opacity(0.8), Color.blue.opacity(0.6)])
    ]
    
    private func gradientForName(_ name: String) -> Gradient {
        switch name.lowercased() {
        case "blue": return Gradient(colors: [.blue, .purple])
        case "green": return Gradient(colors: [.green, .blue])
        case "orange": return Gradient(colors: [.orange, .pink])
        case "purple": return Gradient(colors: [.purple, .pink])
        case "red": return Gradient(colors: [.red, .orange])
        case "pastel 1": return Gradient(colors: [.pink.opacity(0.7), .blue.opacity(0.7)])
        case "pastel 2": return Gradient(colors: [.yellow.opacity(0.7), .green.opacity(0.7)])
        case "pastel 3": return Gradient(colors: [.purple.opacity(0.7), .pink.opacity(0.7)])
        case "aurora": return Gradient(colors: [.mint, .blue, .purple.opacity(0.8)])
        case "lava": return Gradient(colors: [.red, .orange, .yellow])
        case "forest": return Gradient(colors: [.green, .teal, Color(hue: 0.38, saturation: 0.6, brightness: 0.4)])
        case "midnight": return Gradient(colors: [Color(hue: 0.65, saturation: 0.6, brightness: 0.2), .black])
        case "rose": return Gradient(colors: [Color(red: 0.98, green: 0.74, blue: 0.8), Color(red: 0.86, green: 0.38, blue: 0.54)])
        case "frosted glass": return Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)])
        case "frosted glass black": return Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.1)])
        case "sunset": return Gradient(colors: [Color.orange, Color.pink, Color.purple])
        case "ocean": return Gradient(colors: [Color.blue.opacity(0.8), Color.teal.opacity(0.8)])
        case "galaxy": return Gradient(colors: [Color.black, Color.purple.opacity(0.8), Color.blue.opacity(0.6)])
        default: return Gradient(colors: [.blue, .purple])
        }
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(gradients, id: \.name) { gradientItem in
                Button(action: {
                    selectedGradient = gradientItem.name.lowercased()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                gradient: gradientForName(gradientItem.name),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 40)
                        
                        if selectedGradient == gradientItem.name.lowercased() {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3)
                                .frame(height: 48)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("\(gradientItem.name) gradient")
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Improved Preview Component

struct OverlayPreview: View {
    let theme: String
    let systemColorScheme: ColorScheme
    let opacity: Double
    let backgroundColor: String
    
    var body: some View {
        ZStack {
            // Background overlay
            overlayBackground
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 25) {
                // Message
                VStack(spacing: 15) {
                    Text("Regular Break")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                // Countdown
                VStack(spacing: 6) {
                    Text("Time remaining")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("00:20")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Skip button
                Button("Skip Break") {
                    // Preview action
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var overlayBackground: AnyView {
        let baseOpacity = opacity
        
        let backgroundView: AnyView
        // Gradient background
        switch backgroundColor {
        case "blue": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "green": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(baseOpacity), Color.blue.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "orange": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(baseOpacity), Color.pink.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "purple": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(baseOpacity), Color.pink.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "red": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(baseOpacity), Color.orange.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 1": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(baseOpacity * 0.7), Color.blue.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 2": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(baseOpacity * 0.7), Color.green.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 3": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(baseOpacity * 0.7), Color.pink.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "aurora": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(baseOpacity), Color.blue.opacity(baseOpacity * 0.9), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "lava": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(baseOpacity), Color.orange.opacity(baseOpacity), Color.yellow.opacity(baseOpacity * 0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "forest": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(baseOpacity), Color.teal.opacity(baseOpacity), Color(hue: 0.38, saturation: 0.6, brightness: 0.4).opacity(baseOpacity)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "midnight": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color(hue: 0.65, saturation: 0.6, brightness: 0.2).opacity(baseOpacity), Color.black.opacity(baseOpacity)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "rose": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.74, blue: 0.8).opacity(baseOpacity), Color(red: 0.86, green: 0.38, blue: 0.54).opacity(baseOpacity)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "frosted glass": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(baseOpacity * 0.3), Color.white.opacity(baseOpacity * 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "frosted glass black": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(baseOpacity * 0.3), Color.black.opacity(baseOpacity * 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "sunset": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(baseOpacity), Color.pink.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "ocean": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity * 0.8), Color.teal.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "galaxy": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.85), Color.blue.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        default: backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        
        return backgroundView
    }
}
}
