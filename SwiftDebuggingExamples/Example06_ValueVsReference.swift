// =============================================================================
// EXAMPLE 6: Value Type vs Reference Type Bug
// Topic: Unexpected behavior when confusing struct (value) and class (reference)
// Difficulty: Intermediate
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

// BUG 1: Expecting a struct copy to affect the original

struct Settings {
    var fontSize: Int
    var darkMode: Bool
}

var originalSettings = Settings(fontSize: 14, darkMode: false)
var copiedSettings = originalSettings  // This creates a COPY (value type)

copiedSettings.fontSize = 20
copiedSettings.darkMode = true

// WRONG expectation: "I changed copiedSettings, so originalSettings should change too"
print(originalSettings.fontSize)  // Still 14 — NOT 20!
print(originalSettings.darkMode)  // Still false — NOT true!


// BUG 2: Not realizing class instances are shared references

class UserProfile {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

var profile1 = UserProfile(name: "Alice", age: 25)
var profile2 = profile1  // This does NOT copy — both point to SAME object!

profile2.name = "Bob"
profile2.age = 30

// SURPRISE: profile1 was also changed!
print(profile1.name)  // "Bob" — NOT "Alice"!
print(profile1.age)   // 30   — NOT 25!

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: Structs are VALUE TYPES. Assigning a struct to a new variable creates
//         an independent COPY. Changing the copy does NOT affect the original.
//         The bug is the programmer's wrong expectation, not the code itself.
//
// Bug 2: Classes are REFERENCE TYPES. Assigning a class instance to a new
//         variable does NOT create a copy. Both variables point to the SAME
//         object in memory. Changing one affects the other.
//
// This is one of the most fundamental Swift concepts and a guaranteed
// interview question at Apple.
//

// =============================================================================
// FIXED CODE — Understanding and using the correct type
// =============================================================================

// --- Fix for Bug 1: If you WANT shared mutation, use a class ---

class SharedSettings {
    var fontSize: Int
    var darkMode: Bool

    init(fontSize: Int, darkMode: Bool) {
        self.fontSize = fontSize
        self.darkMode = darkMode
    }
}

print("=== Using class for shared settings ===")
var settings1 = SharedSettings(fontSize: 14, darkMode: false)
var settings2 = settings1  // Both point to the same object

settings2.fontSize = 20
settings2.darkMode = true

print("settings1.fontSize: \(settings1.fontSize)")  // 20 — shared!
print("settings1.darkMode: \(settings1.darkMode)")  // true — shared!

// --- Fix for Bug 2: If you WANT independent copies, use a struct ---

struct IndependentProfile {
    var name: String
    var age: Int
}

print("\n=== Using struct for independent copies ===")
var profileA = IndependentProfile(name: "Alice", age: 25)
var profileB = profileA  // Creates an independent copy

profileB.name = "Bob"
profileB.age = 30

print("profileA: \(profileA.name), \(profileA.age)")  // "Alice", 25 — unchanged!
print("profileB: \(profileB.name), \(profileB.age)")  // "Bob", 30

// --- Fix for Bug 2 (alternative): Deep copy a class manually ---

class UserProfile {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    // Create a true copy method
    func copy() -> UserProfile {
        return UserProfile(name: self.name, age: self.age)
    }
}

print("\n=== Deep copying a class ===")
var original = UserProfile(name: "Alice", age: 25)
var duplicate = original.copy()  // Now it's a separate object

duplicate.name = "Bob"
print("original: \(original.name)")   // "Alice" — not affected
print("duplicate: \(duplicate.name)") // "Bob"

// =============================================================================
// VISUAL GUIDE: Value Types vs Reference Types
// =============================================================================
//
//  VALUE TYPES (Struct, Enum, Tuple):
//  ┌──────────┐    ┌──────────┐
//  │ var a     │    │ var b    │     a and b are INDEPENDENT copies
//  │ name: Hi │    │ name: Hi │     changing b does NOT change a
//  └──────────┘    └──────────┘
//
//  REFERENCE TYPES (Class):
//  ┌──────────┐
//  │ var a ────┼──┐
//  └──────────┘  │  ┌──────────┐
//                ├──│ name: Hi │    a and b point to the SAME object
//  ┌──────────┐  │  └──────────┘   changing b ALSO changes a
//  │ var b ────┼──┘
//  └──────────┘
//

// =============================================================================
// BONUS: Mutation in functions
// =============================================================================

print("\n=== Bonus: Passing to functions ===")

struct Point {
    var x: Double
    var y: Double
}

// Value types are copied when passed to functions
func movePoint(_ point: Point, byX dx: Double, byY dy: Double) -> Point {
    var movedPoint = point  // Must create a mutable copy
    movedPoint.x += dx
    movedPoint.y += dy
    return movedPoint
}

// With 'inout', you can modify the original value type
func movePointInPlace(_ point: inout Point, byX dx: Double, byY dy: Double) {
    point.x += dx
    point.y += dy
}

var point = Point(x: 0, y: 0)

let movedPoint = movePoint(point, byX: 5, byY: 10)
print("Original after movePoint: (\(point.x), \(point.y))")        // (0, 0)
print("Returned moved point: (\(movedPoint.x), \(movedPoint.y))")  // (5, 10)

movePointInPlace(&point, byX: 5, byY: 10)
print("After movePointInPlace: (\(point.x), \(point.y))")          // (5, 10)

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Structs = Value Types (copy on assignment)
// Classes = Reference Types (share on assignment)
//
// In interviews, Apple engineers look for:
//   1. Clear understanding of value vs reference semantics
//   2. Knowing which Swift types are value types:
//      - Struct, Enum, Tuple, Int, String, Array, Dictionary, Set
//   3. Knowing which are reference types:
//      - Class, Closure, Function
//   4. Understanding copy-on-write optimization (for Array, String, etc.)
//   5. When to choose struct vs class:
//      - Prefer struct (default) — safer, no retain cycles, thread-safe
//      - Use class when you need: identity, inheritance, or shared mutable state
//
// Apple's own guideline: "Start with a struct. Use a class only when you need
// reference semantics or inheritance."
// =============================================================================
