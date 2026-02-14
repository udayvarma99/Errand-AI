// EXAMPLE 8: Dictionary Key Handling (FIXED)
// Dictionary subscript returns Optional - handle it!

var userCounts: [String: Int] = ["alice": 5, "bob": 3]

func incrementCount(for user: String) {
    let current = userCounts[user] ?? 0  // Default to 0 if key missing
    userCounts[user] = current + 1
}

// Or use updateValue:
// userCounts[user] = (userCounts[user] ?? 0) + 1

// incrementCount(for: "charlie")  // Now works: creates entry with 1
