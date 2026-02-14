// =============================================================================
// EXAMPLE 1: Optional Unwrapping — Force Unwrapping a nil Value
// =============================================================================
//
// DIFFICULTY: Beginner
// TOPIC: Optionals, Force Unwrapping, Safe Unwrapping
// APPLE INTERVIEW TIP: Apple engineers LOVE asking about optionals. Understanding
//   when and why force-unwrapping is dangerous is fundamental to writing safe Swift.
//
// WHAT YOU WILL LEARN:
//   - Why force-unwrapping (!) can crash your app
//   - How to use if-let, guard-let, and nil-coalescing to safely unwrap
//   - Best practices for handling optional values
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

func fetchUsername(from dictionary: [String: String]) -> String {
    // BUG: Force-unwrapping a dictionary lookup that may return nil
    let username = dictionary["username"]!
    return "Hello, \(username)!"
}

// This works fine:
let data1 = ["username": "SwiftDev", "email": "dev@apple.com"]
print(fetchUsername(from: data1))  // prints: Hello, SwiftDev!

// This CRASHES at runtime! 💥
let data2 = ["email": "dev@apple.com"]
print(fetchUsername(from: data2))  // Fatal error: unexpectedly found nil while unwrapping

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// In Swift, dictionary subscript (dictionary["key"]) returns an Optional — it
// returns nil if the key doesn't exist. Using the force-unwrap operator (!)
// tells the compiler "I guarantee this is not nil." If it IS nil, your app
// crashes with:
//
//   "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
//
// This is one of the most common crashes in Swift apps and a RED FLAG in any
// Apple interview. Never force-unwrap unless you are 100% certain the value
// exists (and even then, prefer safe alternatives).
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE — Three different safe approaches
// ---------------------------------------------------------------------------

// APPROACH 1: if-let (Conditional Binding)
// Best when you need to do something specific when the value is nil.
func fetchUsernameV1(from dictionary: [String: String]) -> String {
    if let username = dictionary["username"] {
        return "Hello, \(username)!"
    } else {
        return "Hello, Guest!"
    }
}

// APPROACH 2: guard-let (Early Exit)
// Best inside functions where you want to exit early if value is missing.
func fetchUsernameV2(from dictionary: [String: String]) -> String {
    guard let username = dictionary["username"] else {
        return "Hello, Guest!"
    }
    // 'username' is now safely available as a non-optional String
    return "Hello, \(username)!"
}

// APPROACH 3: Nil-Coalescing Operator (??)
// Best when you have a simple default value.
func fetchUsernameV3(from dictionary: [String: String]) -> String {
    let username = dictionary["username"] ?? "Guest"
    return "Hello, \(username)!"
}


// ---------------------------------------------------------------------------
// TEST — Verify all approaches work correctly
// ---------------------------------------------------------------------------

let data1 = ["username": "SwiftDev", "email": "dev@apple.com"]
let data2 = ["email": "dev@apple.com"]  // No "username" key

print("=== Approach 1: if-let ===")
print(fetchUsernameV1(from: data1))  // Hello, SwiftDev!
print(fetchUsernameV1(from: data2))  // Hello, Guest!

print("\n=== Approach 2: guard-let ===")
print(fetchUsernameV2(from: data1))  // Hello, SwiftDev!
print(fetchUsernameV2(from: data2))  // Hello, Guest!

print("\n=== Approach 3: Nil-Coalescing ===")
print(fetchUsernameV3(from: data1))  // Hello, SwiftDev!
print(fetchUsernameV3(from: data2))  // Hello, Guest!


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "When is it acceptable to use force-unwrapping in Swift?"
//
// A: Force-unwrapping is acceptable in very limited cases:
//    1. IBOutlets (connected in Interface Builder, guaranteed to exist after load)
//    2. When you've JUST assigned a value and immediately unwrap it (rare)
//    3. In unit tests where a crash is the desired failure mode
//    4. With fatalError() to intentionally crash on programmer error
//
//    In production code, prefer if-let, guard-let, optional chaining (?.)
//    or nil-coalescing (??) — these make your code safer and more readable.
// ---------------------------------------------------------------------------
