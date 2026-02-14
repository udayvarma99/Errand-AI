// Example 7 FIXED: Mark @escaping when closure outlives function
// Use @escaping when: storing, passing to async, or using in DispatchQueue

import Foundation

class NetworkManager {
    var completion: ((String) -> Void)?
    
    func fetch(url: String, completion: @escaping (String) -> Void) {  // ✅ @escaping
        self.completion = completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion("Data")
        }
    }
}

// Remember: @escaping closures need [weak self] if capturing self to avoid retain cycles!
