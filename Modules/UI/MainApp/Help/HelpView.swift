import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Find answers to common questions and get support for Lumin.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                // Getting Started
                VStack(alignment: .leading, spacing: 15) {
                    Text("Getting Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Lumin helps you take regular breaks to reduce eye strain and stay productive. To get started:")
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text("1.")
                                .fontWeight(.semibold)
                                .frame(width: 20)
                            Text("Go to the Break Schedule section in the sidebar")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Text("2.")
                                .fontWeight(.semibold)
                                .frame(width: 20)
                            Text("Enable the types of breaks you want (Regular, Micro, Water)")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Text("3.")
                                .fontWeight(.semibold)
                                .frame(width: 20)
                            Text("Adjust the interval and duration settings for each break type")
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Text("4.")
                                .fontWeight(.semibold)
                                .frame(width: 20)
                            Text("Create custom breaks for personalized reminders")
                            Spacer()
                        }
                    }
                    
                    Text("Breaks will automatically start based on your schedule. You can also manually start a break using the Dashboard.")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Break Types
                VStack(alignment: .leading, spacing: 15) {
                    Text("Understanding Break Types")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: "cup.and.saucer")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**Regular Breaks:** Longer breaks (typically 5-10 minutes) to rest your eyes and body.")
                                Text("Recommended interval: 20-40 minutes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "eye")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**Micro-breaks:** Short breaks (a few seconds) to blink and refocus.")
                                Text("Recommended interval: 5-10 minutes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "drop")
                                .foregroundColor(.teal)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**Water Breaks:** Reminders to stay hydrated.")
                                Text("Recommended interval: 30-60 minutes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Common Issues
                VStack(alignment: .leading, spacing: 15) {
                    Text("Common Issues")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**Break notifications not appearing:**")
                                Text("Check that breaks are enabled in both the Dashboard and Break Schedule. Also ensure macOS notifications are enabled for Lumin.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "playpause")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**Breaks keep getting rescheduled:**")
                                Text("This happens when you're actively using your computer. Lumin uses natural break detection to avoid interrupting your work.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "power")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("**App not starting at login:**")
                                Text("Ensure 'Launch at Login' is enabled in General settings and check macOS Login Items in System Preferences.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.2))
                .cornerRadius(8)
                
                // Contact Support
                VStack(alignment: .leading, spacing: 15) {
                    Text("Contact Support")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("If you're experiencing issues not covered here, or have suggestions for improvement:")
                        .foregroundColor(.primary)
                    
                    Link("Open GitHub Issues", destination: URL(string: "https://github.com/0x1labs/lumin/issues/new")!)
                        .foregroundColor(.blue)
                    
                    Text("When reporting an issue, please include:")
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("• Steps to reproduce the issue")
                        Text("• macOS version")
                        Text("• Lumin version")
                        Text("• Screenshots if applicable")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
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
