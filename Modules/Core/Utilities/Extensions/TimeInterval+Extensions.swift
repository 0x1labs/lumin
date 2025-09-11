import Foundation

extension TimeInterval {
    /// Returns a formatted string representation of the time interval
    func formattedTimeString() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Returns a human-readable string representation
    func humanReadableString() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        if minutes > 0 {
            return "\(minutes) min \(seconds) sec"
        } else {
            return "\(seconds) sec"
        }
    }
}