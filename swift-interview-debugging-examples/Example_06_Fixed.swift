// Example 6 FIXED: Proper Self return with required init
// Use required init and type(of:) for correct Self return

import Foundation

protocol Clonable {
    func clone() -> Self
}

class Animal: Clonable {
    var name: String
    
    required init(name: String) {  // required for subclassing
        self.name = name
    }
    
    func clone() -> Self {
        return type(of: self).init(name: name)  // ✅ Correct type
    }
}

class Dog: Animal { }
let dog = Dog(name: "Rex")
let cloned = dog.clone()  // Returns Dog, not Animal - correct!
