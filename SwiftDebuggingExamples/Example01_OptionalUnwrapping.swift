// =============================================================================
// EXAMPLE 1: Optional Unwrapping Bug
// Topic: Force-unwrapping a nil optional causes a runtime crash
// Difficulty: Beginner
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

func findUser(byID id: Int) -> String? {
    let users = [1: "Alice", 2: "Bob", 3: "Charlie"]
    return users[id]
}

func greetUser(id: Int) {
    // BUG: Force-unwrapping with '!' — crashes if user not found
    let name = findUser(byID: id)!
    print("Hello, \(name)! Welcome back.")
}

// This works fine:
greetUser(id: 1)  // prints "Hello, Alice! Welcome back."

// This CRASHES:
greetUser(id: 99) // Fatal error: Unexpectedly found nil while unwrapping

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// The function findUser(byID:) returns an Optional String (String?).
// When we look up a user ID that does NOT exist in the dictionary,
// it returns nil.
//
// Using the force-unwrap operator (!) on a nil value causes an
// immediate runtime crash:
//   "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
//
// This is one of the most common Swift bugs and a favorite interview question.
//

// =============================================================================
// FIXED CODE - Three different safe approaches
// =============================================================================

func findUser(byID id: Int) -> String? {
    let users = [1: "Alice", 2: "Bob", 3: "Charlie"]
    return users[id]
}

// --- Fix 1: if-let (Optional Binding) ---
// This is the most common and recommended approach.
func greetUserFix1(id: Int) {
    if let name = findUser(byID: id) {
        print("Hello, \(name)! Welcome back.")
    } else {
        print("User with ID \(id) not found.")
    }
}

// --- Fix 2: guard-let (Early Exit) ---
// Preferred when you want to exit the function early if nil.
func greetUserFix2(id: Int) {
    guard let name = findUser(byID: id) else {
        print("User with ID \(id) not found.")
        return
    }
    // 'name' is now safely available as a non-optional String
    print("Hello, \(name)! Welcome back.")
}

// --- Fix 3: Nil-Coalescing Operator (??) ---
// Provides a default value when the optional is nil.
func greetUserFix3(id: Int) {
    let name = findUser(byID: id) ?? "Guest"
    print("Hello, \(name)! Welcome back.")
}

// --- Test the fixes ---
print("=== Fix 1: if-let ===")
greetUserFix1(id: 1)   // Hello, Alice! Welcome back.
greetUserFix1(id: 99)  // User with ID 99 not found.

print("\n=== Fix 2: guard-let ===")
greetUserFix2(id: 2)   // Hello, Bob! Welcome back.
greetUserFix2(id: 99)  // User with ID 99 not found.

print("\n=== Fix 3: Nil-Coalescing ===")
greetUserFix3(id: 3)   // Hello, Charlie! Welcome back.
greetUserFix3(id: 99)  // Hello, Guest! Welcome back.

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// NEVER force-unwrap (!) an optional unless you are 100% certain it is not nil.
//
// In interviews, Apple engineers look for:
//   1. Knowledge of Optional types (String? vs String)
//   2. Safe unwrapping with if-let, guard-let, or ??
//   3. Understanding that ! is dangerous and should be avoided
//
// Quick Reference:
//   let x: String? = nil
//   x!              // CRASH - force unwrap
//   if let x = x    // SAFE  - optional binding
//   guard let x = x // SAFE  - early exit
//   x ?? "default"  // SAFE  - nil coalescing
//   x?.count         // SAFE  - optional chaining (returns nil if x is nil)
// =============================================================================
