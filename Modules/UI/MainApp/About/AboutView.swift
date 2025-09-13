
import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Learn more about Lumin, check for updates, and get support.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                // App description
                VStack(alignment: .leading, spacing: 15) {
                    Text("What is Lumin?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Lumin is a macOS application designed to help you maintain healthy computer usage habits by reminding you to take regular breaks. In our digital age, we often spend hours staring at screens without realizing the strain it puts on our eyes, neck, and overall well-being.")
                        .foregroundColor(.primary)
                    
                    Text("The app helps reduce eye strain, prevent fatigue, and promote better posture by scheduling customizable break reminders throughout your workday.")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Benefits section
                VStack(alignment: .leading, spacing: 15) {
                    Text("How Lumin Helps You")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: "eye")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("**Reduces Eye Strain:** Regular breaks help prevent digital eye strain, dry eyes, and blurred vision caused by prolonged screen time.")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text("**Promotes Movement:** Encourages you to stand up, stretch, and move around, improving circulation and reducing stiffness.")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "drop")
                                .foregroundColor(.teal)
                                .frame(width: 20)
                            Text("**Encourages Hydration:** Water break reminders help you stay hydrated throughout the day.")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "brain")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            Text("**Boosts Productivity:** Short breaks can actually improve focus and productivity by preventing mental fatigue.")
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Features section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Key Features")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text("**Customizable Breaks:** Set different intervals and durations for regular breaks, micro-breaks, and water breaks.")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "pills")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            Text("**Personalized Reminders:** Create custom break types for medication, posture checks, or any other reminders you need.")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "gear")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            Text("**Flexible Settings:** Configure the app to match your work schedule and preferences.")
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Footer
                VStack(alignment: .leading, spacing: 15) {
                    Text("Open Source")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Lumin is open source software. You can view the source code, contribute, or report issues on GitHub.")
                        .foregroundColor(.primary)
                    
                    Link("View on GitHub", destination: URL(string: "https://github.com/0x1labs/lumin")!)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
