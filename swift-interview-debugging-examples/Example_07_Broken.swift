// Example 7: Escaping vs Non-Escaping Closure
// BUG: Storing a closure that outlives the function = must be @escaping
// "Why doesn't this compile?" - escaping closure capture rules

import Foundation

class NetworkManager {
    var completion: ((String) -> Void)?  // Stored - outlives function
    
    func fetch(url: String, completion: (String) -> Void) {  // 💥 Missing @escaping
        self.completion = completion  // Error: Assigning non-escaping to escaping
        // Simulate async work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion("Data")
        }
    }
}
