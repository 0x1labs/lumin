import Foundation

extension Date {
    /// Returns a formatted string representation of the date
    func formattedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    
}