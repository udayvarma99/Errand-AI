// =============================================================================
// EXAMPLE 4: UI Updates Must Be on Main Thread
// =============================================================================
// INTERVIEW TIP: UIKit/AppKit are NOT thread-safe. UI = main thread only!
// =============================================================================

import UIKit  // Or import AppKit for macOS

// -----------------------------------------------------------------------------
// 🐛 BUG: Updating UI from background thread = Undefined behavior / crash
// -----------------------------------------------------------------------------

class ProfileViewController_BUG {
    func loadUser() {
        DispatchQueue.global().async {
            let user = self.fetchUserFromNetwork()
            self.label.text = user.name  // ❌ UI update on background thread!
            self.imageView.image = user.avatar  // ❌ Crash or glitch!
        }
    }
    
    var label: UILabel!
    var imageView: UIImageView!
    
    func fetchUserFromNetwork() -> (name: String, avatar: UIImage) {
        return ("Alice", UIImage())
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX 1: Dispatch to main for UI updates
// -----------------------------------------------------------------------------

class ProfileViewController_FIX {
    func loadUser() {
        DispatchQueue.global().async {
            let user = self.fetchUserFromNetwork()
            DispatchQueue.main.async {
                self.label.text = user.name      // ✅ Main thread
                self.imageView.image = user.avatar
            }
        }
    }
    
    var label: UILabel!
    var imageView: UIImageView!
    
    func fetchUserFromNetwork() -> (name: String, avatar: UIImage) {
        return ("Alice", UIImage())
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX 2: Using async/await (Swift 5.5+)
// -----------------------------------------------------------------------------

class ProfileViewController_FIX2 {
    func loadUser() async {
        let user = await fetchUserFromNetworkAsync()
        await MainActor.run {
            self.label.text = user.name
            self.imageView.image = user.avatar
        }
    }
    
    var label: UILabel!
    var imageView: UIImageView!
    
    func fetchUserFromNetworkAsync() async -> (name: String, avatar: UIImage) {
        return ("Alice", UIImage())
    }
}

// 📌 KEY LESSON: Any UI change (label.text, imageView.image, etc.) must
//    run on the main thread. Use DispatchQueue.main.async or @MainActor.
