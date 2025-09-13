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
                
                Text("Lumin helps you take regular breaks to reduce eye strain and stay productive. Configure your break schedule in the Break Schedule section.")
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Common Issues")
                    .font(.headline)
                Text("If something isn't working as expected, please let us know.")
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Contact Support")
                    .font(.headline)
                Text("Create an issue on GitHub with steps to reproduce and screenshots if possible.")
                Link("Open GitHub Issues", destination: URL(string: "https://github.com/0x1labs/lumin/issues/new")!)
            }
            .padding()
            .background(.quaternary.opacity(0.2))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}
