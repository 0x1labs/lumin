
import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("About")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Learn more about Lumin, check for updates, and get support.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Add about content here
            Spacer()
        }
        .padding()
    }
}
