// =============================================================================
// EXAMPLE 1: Force Unwrapping a Nil Optional
// =============================================================================
// Difficulty: Beginner
// Topic:      Optionals, Safe Unwrapping
//
// SCENARIO:
// You are building a user profile screen. The app fetches a user's middle name
// from a database. Not every user has a middle name, so it can be nil.
// The buggy code crashes at runtime because it force-unwraps a nil optional.
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

struct UserProfileBuggy {
    var firstName: String
    var middleName: String?   // Optional — not every user has a middle name
    var lastName: String

    func fullName() -> String {
        // BUG: Force-unwrapping middleName with '!' will crash if it is nil.
        return firstName + " " + middleName! + " " + lastName
    }
}

func demoBuggy() {
    let user = UserProfileBuggy(firstName: "John", middleName: nil, lastName: "Doe")

    // This line will CRASH at runtime with:
    // "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
    print(user.fullName())
}

// Uncomment the line below to see the crash:
// demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// The '!' operator (force unwrap) tells Swift: "I am SURE this optional has a
// value — just give it to me." But if the optional is nil, your app crashes.
//
// In interviews, Apple engineers look for candidates who NEVER force-unwrap
// unless they have an absolute guarantee the value exists.
//
// RULE OF THUMB: If you see '!' in Swift code, ask yourself — "Can this
// ever be nil?" If yes, use safe unwrapping instead.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Three different safe approaches
// ─────────────────────────────────────────────────────────────────────────────

struct UserProfileFixed {
    var firstName: String
    var middleName: String?
    var lastName: String

    // FIX APPROACH 1: Using 'if let' (Optional Binding)
    // This is the most common and readable approach.
    func fullNameWithIfLet() -> String {
        if let middle = middleName {
            return firstName + " " + middle + " " + lastName
        } else {
            return firstName + " " + lastName
        }
    }

    // FIX APPROACH 2: Using the nil-coalescing operator '??'
    // Provides a default value when the optional is nil.
    func fullNameWithNilCoalescing() -> String {
        let middle = middleName ?? ""
        if middle.isEmpty {
            return firstName + " " + lastName
        }
        return firstName + " " + middle + " " + lastName
    }

    // FIX APPROACH 3: Using 'guard let' (Early Exit)
    // Great for functions where nil means "stop early."
    func fullNameWithGuard() -> String {
        guard let middle = middleName else {
            return firstName + " " + lastName
        }
        return firstName + " " + middle + " " + lastName
    }
}

func demoFixed() {
    let userWithMiddle = UserProfileFixed(
        firstName: "John",
        middleName: "Michael",
        lastName: "Doe"
    )
    let userWithoutMiddle = UserProfileFixed(
        firstName: "Jane",
        middleName: nil,
        lastName: "Smith"
    )

    print("--- if let ---")
    print(userWithMiddle.fullNameWithIfLet())       // "John Michael Doe"
    print(userWithoutMiddle.fullNameWithIfLet())     // "Jane Smith"

    print("\n--- nil coalescing ---")
    print(userWithMiddle.fullNameWithNilCoalescing())    // "John Michael Doe"
    print(userWithoutMiddle.fullNameWithNilCoalescing()) // "Jane Smith"

    print("\n--- guard let ---")
    print(userWithMiddle.fullNameWithGuard())        // "John Michael Doe"
    print(userWithoutMiddle.fullNameWithGuard())     // "Jane Smith"
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. NEVER force-unwrap (!) unless you have a compile-time guarantee.
//    Example of safe force-unwrap: let url = URL(string: "https://apple.com")!
//    (This is a constant literal — it will never fail.)
//
// 2. Use 'if let' when you need to do something with the unwrapped value.
//
// 3. Use 'guard let' when nil means the function should return early.
//
// 4. Use '??' (nil coalescing) when you have a sensible default value.
//
// 5. In an interview, always EXPLAIN why force-unwrapping is dangerous
//    and show that you know the safe alternatives.
// ─────────────────────────────────────────────────────────────────────────────
