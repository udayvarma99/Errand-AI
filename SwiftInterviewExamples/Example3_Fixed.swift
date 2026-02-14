// EXAMPLE 3: Force Unwrap Crash (FIXED)
// Use regular optional and safe unwrapping

class User {
    var name: String?
    
    func greet() -> String {
        guard let name = name else {
            return "Hello, Guest"
        }
        return "Hello, \(name)"
    }
}
