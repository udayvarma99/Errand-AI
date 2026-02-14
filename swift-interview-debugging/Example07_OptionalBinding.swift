// =============================================================================
// EXAMPLE 7: Wrong Optional Binding & Optional Chaining
// =============================================================================
// INTERVIEW TIP: Optional chaining (?.) short-circuits to nil, doesn't crash
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Using optional where you need a non-optional
// -----------------------------------------------------------------------------

struct Person {
    var address: Address?
}

struct Address {
    var city: String
}

func getCity_BUG(person: Person?) -> String {
    return person!.address!.city  // ❌ Double force unwrap = 2 crash points
}

// -----------------------------------------------------------------------------
// ✅ FIX: Use optional chaining and nil-coalescing
// -----------------------------------------------------------------------------

func getCity_FIX(person: Person?) -> String {
    return person?.address?.city ?? "Unknown"
}
// If person is nil → nil. If address is nil → nil. Safe!

// -----------------------------------------------------------------------------
// 🐛 BUG: if let shadowing and wrong scope
// -----------------------------------------------------------------------------

var globalName: String? = "Alice"

func processName_BUG() {
    if let name = globalName {
        print(name)
    }
    print(name)  // ❌ name is out of scope! Compile error
}

// -----------------------------------------------------------------------------
// ✅ FIX: Keep variable in scope or use guard
// -----------------------------------------------------------------------------

func processName_FIX() {
    guard let name = globalName else { return }
    print(name)
    // name is in scope for rest of function
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Optional in a boolean context
// -----------------------------------------------------------------------------

func isLoggedIn_BUG() -> Bool {
    let token: String? = nil
    return token  // ❌ Optional can't be Bool. Use: token != nil
}

// -----------------------------------------------------------------------------
// ✅ FIX: Explicit nil check
// -----------------------------------------------------------------------------

func isLoggedIn_FIX() -> Bool {
    let token: String? = nil
    return token != nil
}

// 📌 KEY LESSON: Use ?. for chaining, ?? for defaults, if let/guard let
//    for unwrapping. Avoid !. Optional chaining returns optional.
