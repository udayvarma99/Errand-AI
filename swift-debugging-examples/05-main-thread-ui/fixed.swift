// FIXED: Always update UI on main thread
import UIKit

class ProfileViewController: UIViewController {
    var label: UILabel!
    
    func loadUserData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let name = self.fetchUserNameFromNetwork()  // Background: OK
            
            // ✅ Switch to main thread for UI updates
            DispatchQueue.main.async {
                self.label.text = name
            }
        }
    }
    
    // Or use @MainActor (Swift 5.5+)
    @MainActor
    func updateLabel(with text: String) {
        label.text = text
    }
    
    func fetchUserNameFromNetwork() -> String {
        return "John"
    }
}
