// BUGGY: UI update from background thread - Crashes on device!
import UIKit

class ProfileViewController: UIViewController {
    var label: UILabel!
    
    func loadUserData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let name = self.fetchUserNameFromNetwork()  // Background thread
            
            // 💥 CRASH: UI must be updated on main thread only!
            self.label.text = name
        }
    }
    
    func fetchUserNameFromNetwork() -> String {
        return "John"  // Simulated network call
    }
}
