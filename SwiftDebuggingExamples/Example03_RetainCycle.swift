// =============================================================================
// EXAMPLE 3: Strong Reference Cycle (Retain Cycle) / Memory Leak
// Topic: Two objects holding strong references to each other → memory leak
// Difficulty: Intermediate
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

class Person {
    let name: String
    var apartment: Apartment?  // Strong reference to Apartment

    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    var tenant: Person?  // BUG: Strong reference back to Person

    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }

    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}

// Create instances
var john: Person? = Person(name: "John")
var unit4A: Apartment? = Apartment(unit: "4A")

// Link them together — this creates a RETAIN CYCLE
john?.apartment = unit4A
unit4A?.tenant = john

// Set both to nil — but deinit is NEVER called!
john = nil       // "John is being deinitialized" — NEVER PRINTED
unit4A = nil     // "Apartment 4A is being deinitialized" — NEVER PRINTED

// MEMORY LEAK: Both objects stay in memory forever!

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// When john?.apartment = unit4A and unit4A?.tenant = john are both set,
// the two objects point to each other with STRONG references:
//
//   Person --strong--> Apartment
//   Apartment --strong--> Person
//
// When we set john = nil and unit4A = nil, the local variables no longer
// reference the objects. But the objects still reference EACH OTHER.
//
// ARC (Automatic Reference Counting) cannot free them because each object's
// reference count never reaches 0. This is called a RETAIN CYCLE.
//
// The deinit methods are never called = MEMORY LEAK.
//
// This is one of the MOST important topics in Apple interviews.
//

// =============================================================================
// FIXED CODE - Using 'weak' to break the cycle
// =============================================================================

class Person {
    let name: String
    var apartment: Apartment?  // Strong reference (Person "owns" apartment)

    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    weak var tenant: Person?  // FIX: 'weak' breaks the retain cycle!

    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }

    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}

// --- Test: Create and link ---
print("=== Creating objects ===")
var john: Person? = Person(name: "John")          // "John is being initialized"
var unit4A: Apartment? = Apartment(unit: "4A")     // "Apartment 4A is being initialized"

john?.apartment = unit4A
unit4A?.tenant = john

// --- Test: Release ---
print("\n=== Setting to nil ===")
john = nil       // "John is being deinitialized" — NOW it prints!
unit4A = nil     // "Apartment 4A is being deinitialized" — NOW it prints!

// The reference diagram is now:
//   Person --strong--> Apartment
//   Apartment --weak--> Person        (weak does NOT increase reference count)
//
// When john = nil, Person's count drops to 0 → deinitialized
// This also removes the strong ref to Apartment → Apartment count drops to 0

// =============================================================================
// BONUS: 'unowned' vs 'weak'
// =============================================================================

// Use 'weak' when the reference can become nil during the object's lifetime.
//   - weak var delegate: SomeDelegate?
//   - Always optional (?)

// Use 'unowned' when the reference should NEVER be nil during the object's lifetime.
//   - unowned let owner: Owner
//   - Non-optional, but crashes if accessed after the owner is deallocated

class Customer {
    let name: String
    var card: CreditCard?

    init(name: String) { self.name = name }
    deinit { print("Customer \(name) deinitialized") }
}

class CreditCard {
    let number: Int
    unowned let customer: Customer  // Card can't exist without a customer

    init(number: Int, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) deinitialized") }
}

print("\n=== unowned example ===")
var customer: Customer? = Customer(name: "Alice")
customer?.card = CreditCard(number: 1234, customer: customer!)
customer = nil  // Both Customer and CreditCard are deinitialized

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// A RETAIN CYCLE occurs when two objects hold strong references to each other.
// ARC can never free them → memory leak.
//
// Break the cycle with:
//   weak    — when the reference can become nil (always Optional)
//   unowned — when the reference should never become nil (non-Optional)
//
// In interviews, Apple engineers look for:
//   1. Understanding of ARC and reference counting
//   2. Ability to identify retain cycles in code
//   3. Knowing when to use weak vs unowned
//   4. Knowledge of how to detect leaks (Instruments → Leaks tool)
//
// Rules of thumb:
//   - Parent → Child: strong
//   - Child → Parent: weak or unowned
//   - Delegates: almost always weak
//   - Closures capturing self: use [weak self] or [unowned self]
// =============================================================================
