// EXAMPLE 1: Optional Unwrapping (FIXED)
// Use optional binding to safely unwrap

func getUserAge(from input: String?) -> Int? {
    guard let input = input,
          let age = Int(input) else {
        return nil
    }
    return age
}

// Safe usage:
// getUserAge(from: nil)           // Returns nil
// getUserAge(from: "invalid")     // Returns nil
// getUserAge(from: "25")          // Returns Optional(25)
