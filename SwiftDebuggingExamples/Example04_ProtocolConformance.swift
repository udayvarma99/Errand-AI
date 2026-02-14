// =============================================================================
// EXAMPLE 4: Protocol Conformance Bug
// Topic: Missing required methods, incorrect signatures, class-only protocols
// Difficulty: Intermediate
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

protocol Printable {
    var description: String { get }
    func printFormatted()
}

// BUG 1: Missing the required 'printFormatted()' method
struct Book: Printable {
    let title: String
    let author: String

    var description: String {
        return "\(title) by \(author)"
    }
    // ERROR: Type 'Book' does not conform to protocol 'Printable'
    // Missing: func printFormatted()
}

// ---

protocol Equatable2 {
    func isEqual(to other: Self) -> Bool
}

// BUG 2: Wrong parameter type in the method signature
struct Point: Equatable2 {
    let x: Double
    let y: Double

    // ERROR: The method signature must match exactly
    func isEqual(to other: Point) -> Bool {   // This actually works for struct
        return self.x == other.x && self.y == other.y
    }
}

// BUG 3: Trying to use a mutating method in a protocol without 'mutating'
protocol Resettable {
    func reset()  // Missing 'mutating' keyword
}

struct Counter: Resettable {
    var count: Int = 0

    // ERROR: Cannot assign to property: 'self' is immutable
    func reset() {
        count = 0  // Structs need 'mutating' to change properties!
    }
}

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: When a type claims to conform to a protocol, it MUST implement ALL
//         required properties and methods. Missing even one causes a compile error.
//
// Bug 2: Method signatures must match the protocol exactly. The parameter names,
//         types, and return type must all match.
//
// Bug 3: Structs are value types. To modify their properties inside a method,
//         the method must be marked 'mutating'. The protocol must ALSO declare
//         the method as 'mutating' to allow struct conformance.
//

// =============================================================================
// FIXED CODE
// =============================================================================

// --- Fix 1: Implement ALL required protocol members ---

protocol Printable {
    var description: String { get }
    func printFormatted()
}

struct Book: Printable {
    let title: String
    let author: String

    var description: String {
        return "\(title) by \(author)"
    }

    // FIX: Now we implement the required method
    func printFormatted() {
        print("=== Book ===")
        print("  Title:  \(title)")
        print("  Author: \(author)")
        print("=============")
    }
}

// --- Fix 2: Match the protocol signature exactly ---

protocol Equatable2 {
    func isEqual(to other: Self) -> Bool
}

struct Point: Equatable2 {
    let x: Double
    let y: Double

    // FIX: Signature matches the protocol (Self resolves to Point for this struct)
    func isEqual(to other: Point) -> Bool {
        return self.x == other.x && self.y == other.y
    }
}

// --- Fix 3: Mark protocol method as 'mutating' ---

protocol Resettable {
    mutating func reset()  // FIX: Added 'mutating' keyword
}

struct Counter: Resettable {
    var count: Int = 0

    mutating func reset() {  // FIX: Now the struct can mutate itself
        count = 0
    }
}

// --- Test all fixes ---
print("=== Fix 1: Full protocol conformance ===")
let book = Book(title: "Swift Programming", author: "Apple")
book.printFormatted()
print("Description: \(book.description)")

print("\n=== Fix 2: Correct method signature ===")
let p1 = Point(x: 3.0, y: 4.0)
let p2 = Point(x: 3.0, y: 4.0)
let p3 = Point(x: 1.0, y: 2.0)
print("p1 == p2: \(p1.isEqual(to: p2))")  // true
print("p1 == p3: \(p1.isEqual(to: p3))")  // false

print("\n=== Fix 3: Mutating protocol method ===")
var counter = Counter(count: 42)
print("Before reset: \(counter.count)")  // 42
counter.reset()
print("After reset: \(counter.count)")   // 0

// =============================================================================
// BONUS: Protocol Extensions with Default Implementations
// =============================================================================

protocol Greetable {
    var name: String { get }
    func greet() -> String
}

// Provide a default implementation — conforming types get it for free
extension Greetable {
    func greet() -> String {
        return "Hello, I'm \(name)!"
    }
}

struct Employee: Greetable {
    let name: String
    // No need to implement greet() — uses the default from the extension!
}

struct Manager: Greetable {
    let name: String

    // Can override the default if needed
    func greet() -> String {
        return "Hi, I'm \(name), your manager."
    }
}

print("\n=== Bonus: Protocol default implementations ===")
let emp = Employee(name: "Alice")
let mgr = Manager(name: "Bob")
print(emp.greet())  // "Hello, I'm Alice!"
print(mgr.greet())  // "Hi, I'm Bob, your manager."

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Protocol conformance requires implementing ALL required members.
//
// In interviews, Apple engineers look for:
//   1. Understanding that protocols define a "contract" types must fulfill
//   2. Knowing about 'mutating' for value type (struct/enum) protocol methods
//   3. Protocol extensions and default implementations
//   4. Protocol-oriented programming (POP) — Swift's preferred paradigm
//   5. The difference between protocol requirements and extension methods
//      (hint: extension methods use static dispatch, not dynamic dispatch)
//
// Common interview question:
//   "What happens if you define a method in a protocol extension but NOT
//    in the protocol requirement? How does dispatch work?"
//   Answer: It uses STATIC dispatch — the method called depends on the
//           declared type, not the runtime type.
// =============================================================================
