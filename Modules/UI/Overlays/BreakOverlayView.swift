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
    
    var body: some View {
        ZStack {
            // Darkened background with blur
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            // Semi-transparent overlay
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 40) {
                // Break type icon and message
                VStack(spacing: 25) {
                    Group {
                        switch breakType {
                        case .regular:
                            Image(systemName: "eye")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        case .micro:
                            Image(systemName: "eye")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        case .water:
                            Image(systemName: "drop")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        case .custom:
                            Image(systemName: customIconSystemName ?? "star")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 160, height: 160)
                    .background(
                        Group {
                            switch breakType {
                            case .regular:
                                Color.blue
                            case .micro:
                                Color.orange
                            case .water:
                                Color.teal
                            case .custom:
                                Color.pink
                            }
                        }
                    )
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    
                    Text(customTitle ?? message)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
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
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.cancelAction)
            }
            .padding(60)
        }
        .onAppear { }
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
