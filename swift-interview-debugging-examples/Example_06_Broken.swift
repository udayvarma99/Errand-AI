// Example 6: Protocol with Self Requirement
// BUG: Protocol that returns Self - tricky with type erasure
// Apple loves protocols; they test if you understand them

import Foundation

protocol Clonable {
    func clone() -> Self  // Returns the concrete type
}

class Animal: Clonable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func clone() -> Self {  // 💥 Error: Cannot convert return type
        return Animal(name: name) as! Self  // Risky cast!
    }
}
