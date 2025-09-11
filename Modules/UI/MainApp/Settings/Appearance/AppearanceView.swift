
import SwiftUI

struct AppearanceView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Appearance")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Customize the look and feel of notifications and overlays.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Add appearance settings content here
            Spacer()
        }
        .padding()
    }
}
