
import SwiftUI

struct ShortcutsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Shortcuts")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Configure keyboard shortcuts for quick access to Lumin features.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Add shortcuts content here
            Spacer()
        }
        .padding()
    }
}
