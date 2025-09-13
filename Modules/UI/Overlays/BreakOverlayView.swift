import SwiftUI
import AppKit

struct BreakOverlayView: View {
    let breakType: BreakType
    let duration: TimeInterval
    @ObservedObject var controller: BreakOverlayController
    let message: String
    let customIconSystemName: String?
    let customTitle: String?
    let onSkip: () -> Void
    @AppStorage("overlayBackgroundColor") private var overlayBackgroundColor = "blue"
    
    init(breakType: BreakType, duration: TimeInterval, controller: BreakOverlayController, 
         message: String, customIconSystemName: String?, customTitle: String?, 
         onSkip: @escaping () -> Void) {
        self.breakType = breakType
        self.duration = duration
        self.controller = controller
        self.message = message
        self.customIconSystemName = customIconSystemName
        self.customTitle = customTitle
        self.onSkip = onSkip
    }
    
    var body: some View {
        ZStack {
            // Darkened background with blur
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            // Semi-transparent overlay background
            overlayBackground
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 40) {
                // Break type message
                VStack(spacing: 25) {
                    Text(customTitle ?? message)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Countdown timer
                VStack(spacing: 15) {
                    Text("Time remaining")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(formatTime(controller.displayTimeRemaining))
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.default, value: controller.displayTimeRemaining)
                }
                
                // Skip button
                Button(action: onSkip) {
                    Text("Skip Break")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.cancelAction)
            }
            .padding(60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear { }
    }
    
    private var overlayBackground: AnyView {
        let baseOpacity: Double = 0.9 // Fixed opacity for overlay background
        
        let backgroundView: AnyView
        // Gradient background
        switch overlayBackgroundColor {
        case "blue": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "green": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(baseOpacity), Color.blue.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "orange": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(baseOpacity), Color.pink.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "purple": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(baseOpacity), Color.pink.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "red": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.red.opacity(baseOpacity), Color.orange.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 1": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(baseOpacity * 0.7), Color.blue.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 2": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(baseOpacity * 0.7), Color.green.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "pastel 3": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(baseOpacity * 0.7), Color.pink.opacity(baseOpacity * 0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "frosted glass": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(baseOpacity * 0.3), Color.white.opacity(baseOpacity * 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "frosted glass black": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(baseOpacity * 0.3), Color.black.opacity(baseOpacity * 0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "sunset": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(baseOpacity), Color.pink.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        case "ocean": backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity * 0.8), Color.teal.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        default: backgroundView = AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(baseOpacity), Color.purple.opacity(baseOpacity * 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        
        return backgroundView
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
}

// Helper view for visual effects
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
