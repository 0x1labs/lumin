
import SwiftUI

struct StatisticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("View your break history, productivity statistics, and trends over time.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Add statistics content here
            Spacer()
        }
        .padding()
    }
}
