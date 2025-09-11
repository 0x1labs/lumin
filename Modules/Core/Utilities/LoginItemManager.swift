import Foundation
import ServiceManagement

class LoginItemManager {
    static let shared = LoginItemManager()
    
    private init() {}
    
    /// Adds the app to login items
    func addToLoginItems() -> Bool {
        do {
            // Check if already registered
            if SMAppService.mainApp.status == .enabled {
                return true
            }
            
            try SMAppService.mainApp.register()
            return true
        } catch {
            print("Failed to add app to login items: \(error)")
            return false
        }
    }
    
    /// Removes the app from login items
    func removeFromLoginItems() -> Bool {
        do {
            // Check if already unregistered
            if SMAppService.mainApp.status == .notRegistered || SMAppService.mainApp.status == .notFound {
                return true
            }
            
            try SMAppService.mainApp.unregister()
            return true
        } catch {
            print("Failed to remove app from login items: \(error)")
            return false
        }
    }
    
    /// Checks if the app is currently in login items
    func isLoginItem() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
}
