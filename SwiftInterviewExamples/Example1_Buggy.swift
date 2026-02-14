// EXAMPLE 1: Optional Unwrapping (Beginner)
// BUG: Force unwrapping an optional that might be nil
// Expected: Parse user age safely

func getUserAge(from input: String?) -> Int {
    return Int(input!)!  // 💥 Crashes if input is nil OR if input can't be parsed
}

// Test cases that will crash:
// getUserAge(from: nil)
// getUserAge(from: "not-a-number")
// getUserAge(from: "25")  // Only this works
