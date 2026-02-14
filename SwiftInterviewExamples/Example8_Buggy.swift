// EXAMPLE 8: Dictionary Key Handling (Medium)
// BUG: Assuming key exists - force unwrap on optional return
// Expected: Safely get and update user count

var userCounts: [String: Int] = ["alice": 5, "bob": 3]

func incrementCount(for user: String) {
    let current = userCounts[user]!  // 💥 Crashes if "user" key doesn't exist
    userCounts[user] = current + 1
}

// incrementCount(for: "charlie")  // Crash! "charlie" not in dict
