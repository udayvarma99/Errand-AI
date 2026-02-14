// =============================================================================
// EXAMPLE 3: Strong Reference Cycle (Memory Leak)
// =============================================================================
//
// DIFFICULTY: Intermediate
// TOPIC: ARC, Memory Management, weak/unowned references
// APPLE INTERVIEW TIP: Memory management questions are a STAPLE of Apple
//   interviews. Understanding ARC (Automatic Reference Counting) and how to
//   break retain cycles is essential knowledge.
//
// WHAT YOU WILL LEARN:
//   - How strong reference cycles cause memory leaks
//   - The difference between weak and unowned
//   - How to use deinit to verify objects are being deallocated
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

class Person {
    let name: String
    var apartment: Apartment?  // Person owns an Apartment (strong reference)
    
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
    var tenant: Person?  // BUG: Apartment also strongly references Person
    
    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}

// Create instances
var john: Person? = Person(name: "John")           // John: refcount = 1
var apt: Apartment? = Apartment(unit: "4A")         // Apt: refcount = 1

// Link them together
john?.apartment = apt    // Apt: refcount = 2
apt?.tenant = john       // John: refcount = 2

// Try to deallocate
john = nil   // John: refcount goes from 2 to 1 (NOT zero — not deallocated!)
apt = nil    // Apt: refcount goes from 2 to 1 (NOT zero — not deallocated!)

// NEITHER deinit is called! Both objects leak memory forever. 💥

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// Swift uses ARC (Automatic Reference Counting) to manage memory. Every time
// you create a strong reference to an object, its reference count goes up by 1.
// When the count reaches 0, the object is deallocated.
//
// A STRONG REFERENCE CYCLE happens when two objects reference each other:
//
//   Person ---strong---> Apartment
//   Person <---strong--- Apartment
//
// Even when you set both variables to nil, each object still has a reference
// count of 1 (from the other object), so neither can be freed. This is a
// MEMORY LEAK — the memory is permanently lost until the app is terminated.
//
// In a real app, this can lead to:
//   - Increasing memory usage over time
//   - App getting killed by the system (memory pressure)
//   - Subtle bugs where deinit cleanup code never runs
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE — Use 'weak' to break the cycle
// ---------------------------------------------------------------------------

class Person {
    let name: String
    var apartment: Apartment?  // Strong reference (Person "owns" the apartment)
    
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
    // FIX: Use 'weak' — the apartment does NOT own the tenant
    // 'weak' references do not increase the reference count
    // 'weak' references must be optional (var) because they become nil
    // when the referenced object is deallocated
    weak var tenant: Person?
    
    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify objects are properly deallocated
// ---------------------------------------------------------------------------

print("=== Creating objects ===")
var john: Person? = Person(name: "John")       // John: refcount = 1
var apt: Apartment? = Apartment(unit: "4A")     // Apt: refcount = 1

print("\n=== Linking objects ===")
john?.apartment = apt    // Apt: refcount = 2 (john + apt variable)
apt?.tenant = john       // John: refcount = 1 (weak doesn't increase!)

print("\n=== Setting john to nil ===")
john = nil
// John: refcount goes from 1 to 0 → DEALLOCATED!
// apt.tenant automatically becomes nil (because it's weak)
// Apt: refcount goes from 2 to 1 (John's reference is gone)

print("\n=== Setting apt to nil ===")
apt = nil
// Apt: refcount goes from 1 to 0 → DEALLOCATED!

// OUTPUT:
// John is being initialized
// Apartment 4A is being initialized
// John is being deinitialized       ← Properly cleaned up!
// Apartment 4A is being deinitialized  ← Properly cleaned up!


// ---------------------------------------------------------------------------
// BONUS: weak vs unowned — When to use each
// ---------------------------------------------------------------------------
//
// WEAK:
//   - The referenced object CAN become nil during the lifetime
//   - Must be declared as 'var' and Optional (?)
//   - Automatically set to nil when the object is deallocated
//   - Use when the reference might outlive the referenced object
//   - Example: delegate patterns, parent-child where child can exist alone
//
// UNOWNED:
//   - The referenced object should NEVER become nil during the lifetime
//   - Does NOT need to be Optional
//   - Accessing an unowned reference after deallocation CRASHES (like force unwrap)
//   - Use when you're sure the referenced object will always be alive
//   - Example: A credit card always has an owner
//
//   class CreditCard {
//       unowned let owner: Person   // The card cannot exist without an owner
//       let number: String
//       init(number: String, owner: Person) {
//           self.number = number
//           self.owner = owner
//       }
//   }


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "You notice your iOS app's memory keeps growing as users navigate
//     between screens. How would you diagnose and fix this?"
//
// A: Step-by-step approach:
//    1. Use Xcode's Memory Graph Debugger (Debug > Debug Memory Graph)
//       to visualize object relationships and find retain cycles
//    2. Use Instruments (Leaks template) to identify leaked objects
//    3. Check deinit methods — add print statements to verify view controllers
//       are being deallocated when dismissed
//    4. Common culprits:
//       - Closures capturing 'self' strongly (see Example 5)
//       - Delegate properties not marked as 'weak'
//       - NotificationCenter observers not removed
//       - Timer references not invalidated
//    5. Fix by using 'weak' or 'unowned' references where appropriate
// ---------------------------------------------------------------------------
