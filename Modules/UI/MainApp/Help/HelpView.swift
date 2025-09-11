import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Help & Support")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Find answers to common questions and get support for Lumin.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Getting Started")
                    .font(.headline)
                
                Text("Lumin helps you take regular breaks to reduce eye strain and stay productive. Configure your break schedule in the Break Schedule section, and customize notifications in General settings.")
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Common Issues")
                    .font(.headline)
                
                Text("If you're not receiving notifications, check that Lumin has permission to send notifications in System Settings > Notifications.")
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Contact Support")
                    .font(.headline)
                
                Text("For additional help, contact our support team at support@luminapp.com")
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}
