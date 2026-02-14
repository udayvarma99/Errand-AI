// EXAMPLE 3: Force Unwrap Crash (Beginner)
// BUG: Implicitly unwrapped optional used after it's been set to nil
// Expected: Safe optional handling

class User {
    var name: String!
    
    func greet() -> String {
        return "Hello, \(name!)"
    }
}

// This crashes:
// let user = User()
// user.name = "Alice"
// user.name = nil  // Oops, someone cleared it
// print(user.greet())  // 💥 Crashes: unexpectedly found nil
