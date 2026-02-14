// =============================================================================
// EXAMPLE 4: Value Type vs Reference Type Mutation
// =============================================================================
//
// DIFFICULTY: Beginner-Intermediate
// TOPIC: Structs vs Classes, Value Semantics, Copy-on-Write
// APPLE INTERVIEW TIP: Understanding the difference between value types
//   (structs, enums) and reference types (classes) is CRITICAL. Apple's own
//   Swift guidelines recommend using structs by default. You WILL be asked
//   about this.
//
// WHAT YOU WILL LEARN:
//   - How structs (value types) and classes (reference types) behave differently
//   - Why mutating a copy of a struct doesn't change the original
//   - The 'mutating' keyword for struct methods
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

struct ShoppingCart {
    var items: [String] = []
    var total: Double = 0.0
    
    // BUG 1: Trying to mutate a struct without 'mutating' keyword
    func addItem(_ item: String, price: Double) {
        items.append(item)      // ERROR: Cannot use mutating member on immutable value
        total += price           // ERROR: Left side of mutating operator isn't mutable
    }
}

// BUG 2: Expecting reference semantics from a value type
var cart1 = ShoppingCart()
var cart2 = cart1           // This creates a COPY, not a reference!

cart1.items.append("MacBook Pro")
cart1.total = 2499.0

print(cart2.items)   // [] — Empty! cart2 is a separate copy
print(cart2.total)   // 0.0 — Still zero! Changes to cart1 don't affect cart2

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// BUG 1: MUTATING KEYWORD
// Structs are value types. By default, a struct's properties cannot be modified
// inside its own methods. You must mark the method as 'mutating' to allow this.
// This is Swift's way of being explicit about side effects.
//
// BUG 2: VALUE SEMANTICS
// When you assign a struct to another variable (cart2 = cart1), Swift creates
// an independent COPY. They are completely separate values in memory.
// Modifying one does NOT affect the other.
//
// This is DIFFERENT from classes, where assignment creates a shared reference:
//   var obj1 = MyClass()
//   var obj2 = obj1       // Both point to the SAME object in memory
//   obj1.name = "Changed" // obj2.name is also "Changed"!
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE
// ---------------------------------------------------------------------------

// FIX 1: Use 'mutating' for struct methods that modify properties
struct ShoppingCart {
    var items: [String] = []
    var total: Double = 0.0
    
    // Added 'mutating' keyword — now this method can modify the struct
    mutating func addItem(_ item: String, price: Double) {
        items.append(item)
        total += price
    }
    
    mutating func removeAll() {
        items.removeAll()
        total = 0.0
    }
    
    // Non-mutating methods don't need the keyword (they only read)
    func summary() -> String {
        if items.isEmpty {
            return "Cart is empty"
        }
        return "Items: \(items.joined(separator: ", ")) — Total: $\(String(format: "%.2f", total))"
    }
}


// ---------------------------------------------------------------------------
// TEST — Demonstrating value vs reference semantics
// ---------------------------------------------------------------------------

print("=== Value Type (Struct) Behavior ===")

var cart1 = ShoppingCart()
cart1.addItem("MacBook Pro", price: 2499.0)
cart1.addItem("AirPods Pro", price: 249.0)

// Assigning creates an INDEPENDENT COPY
var cart2 = cart1

// Modifying cart1 does NOT affect cart2
cart1.addItem("iPad Air", price: 599.0)

print("Cart 1: \(cart1.summary())")
// Cart 1: Items: MacBook Pro, AirPods Pro, iPad Air — Total: $3347.00

print("Cart 2: \(cart2.summary())")
// Cart 2: Items: MacBook Pro, AirPods Pro — Total: $2748.00
// (cart2 still has the original items — it's a separate copy!)


// FIX 2: If you NEED shared/reference behavior, use a class instead
print("\n=== Reference Type (Class) Behavior ===")

class SharedShoppingCart {
    var items: [String] = []
    var total: Double = 0.0
    
    // No 'mutating' needed — classes are reference types
    func addItem(_ item: String, price: Double) {
        items.append(item)
        total += price
    }
    
    func summary() -> String {
        if items.isEmpty {
            return "Cart is empty"
        }
        return "Items: \(items.joined(separator: ", ")) — Total: $\(String(format: "%.2f", total))"
    }
}

let sharedCart1 = SharedShoppingCart()
let sharedCart2 = sharedCart1  // Both point to the SAME object

sharedCart1.addItem("Mac Studio", price: 1999.0)

print("Shared Cart 1: \(sharedCart1.summary())")
print("Shared Cart 2: \(sharedCart2.summary())")
// Both print the same thing — they're the same object!

// Note: Even though sharedCart1 and sharedCart2 are 'let' constants,
// we can still modify the object's PROPERTIES. 'let' only prevents
// reassigning the variable itself, not mutating the object it points to.


// ---------------------------------------------------------------------------
// CHEAT SHEET: When to use Struct vs Class
// ---------------------------------------------------------------------------
//
// USE STRUCT (Value Type) when:
//   ✓ The data is simple and self-contained
//   ✓ You want independent copies (no shared state)
//   ✓ Properties are mostly value types themselves
//   ✓ You don't need inheritance
//   ✓ Thread safety matters (copies are inherently thread-safe)
//   Examples: CGPoint, CGRect, Date, URL, most model types
//
// USE CLASS (Reference Type) when:
//   ✓ You need shared mutable state
//   ✓ You need inheritance
//   ✓ You need identity (=== operator)
//   ✓ You need deinit for cleanup
//   ✓ You're wrapping an Objective-C type
//   Examples: UIViewController, UIView, NSObject subclasses
//
// APPLE'S GUIDELINE: "Start with a struct. Use a class only when you need to."
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "Explain Copy-on-Write (COW) in Swift. Which types use it?"
//
// A: Copy-on-Write is an optimization for value types. When you copy a
//    value type (like an Array), Swift doesn't actually duplicate the data
//    immediately. Both copies share the same underlying storage. Only when
//    one of them is MODIFIED does Swift create an actual copy.
//
//    var array1 = [1, 2, 3, 4, 5]  // Allocates memory
//    var array2 = array1             // No copy yet! Shares storage
//    array2.append(6)                // NOW Swift copies the data
//
//    Built-in types with COW: Array, Dictionary, Set, String
//
//    Custom structs do NOT get COW automatically. If your struct contains
//    large data, you can implement COW manually using isKnownUniquelyReferenced().
// ---------------------------------------------------------------------------
