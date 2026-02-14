// =============================================================================
// EXAMPLE 1: Force Unwrap Crash (The #1 Cause of Swift Crashes)
// =============================================================================
// INTERVIEW TIP: Apple interviewers LOVE to see you avoid force unwrap (!)
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Force unwrapping an optional that can be nil = CRASH
// -----------------------------------------------------------------------------

func getUserName_BUG(id: Int) -> String {
    let users = [1: "Alice", 2: "Bob"]
    let name = users[id]!  // ❌ CRASH if id is 3 (key doesn't exist)
    return name
}
// getUserName_BUG(id: 3)  // FATAL ERROR: Unexpectedly found nil

// -----------------------------------------------------------------------------
// ✅ FIX 1: Use optional binding (if let)
// -----------------------------------------------------------------------------

func getUserName_FIX1(id: Int) -> String? {
    let users = [1: "Alice", 2: "Bob"]
    if let name = users[id] {
        return name
    }
    return nil
}
// getUserName_FIX1(id: 3)  // Returns nil safely

// -----------------------------------------------------------------------------
// ✅ FIX 2: Use nil-coalescing for defaults
// -----------------------------------------------------------------------------

func getUserName_FIX2(id: Int) -> String {
    let users = [1: "Alice", 2: "Bob"]
    return users[id] ?? "Unknown"
}
// getUserName_FIX2(id: 3)  // Returns "Unknown"

// -----------------------------------------------------------------------------
// ✅ FIX 3: Use guard for early exit
// -----------------------------------------------------------------------------

func greetUser_BUG(id: Int) {
    let users = [1: "Alice", 2: "Bob"]
    let name = users[id]!  // ❌ Same crash
    print("Hello, \(name)!")
}

func greetUser_FIX(id: Int) {
    let users = [1: "Alice", 2: "Bob"]
    guard let name = users[id] else {
        print("User not found")
        return
    }
    print("Hello, \(name)!")
}

// 📌 KEY LESSON: Never use ! unless you're 100% sure it won't be nil.
//    Prefer: if let, guard let, ??, optional chaining (?.)
