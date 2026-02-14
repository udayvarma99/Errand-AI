// ============================================================================
// EXAMPLE 2: Retain Cycles & Memory Leaks
// Difficulty: Intermediate
// Topic: ARC (Automatic Reference Counting), strong/weak/unowned references
// ============================================================================

// ============================================================================
// WHAT IS ARC (Automatic Reference Counting)?
// ============================================================================
// Swift uses ARC to manage memory. Every time you create an instance of a class,
// ARC allocates memory for it. When no one references it anymore, ARC frees
// that memory.
//
// A "retain cycle" happens when two objects hold STRONG references to each
// other. Neither can be freed because each one keeps the other alive.
// This causes a MEMORY LEAK — the memory is never released.
//
//   Object A ---strong---> Object B
//   Object B ---strong---> Object A
//   (Neither can ever be freed!)
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Two classes holding strong references to each other
class Employee {
    var name: String
    var company: Company?  // Strong reference to Company

    init(name: String) {
        self.name = name
        print("\(name) is hired (Employee allocated)")
    }

    deinit {
        print("\(name) is freed (Employee deallocated)")
    }
}

class Company {
    var companyName: String
    var ceo: Employee?  // Strong reference to Employee  <-- BUG!

    init(companyName: String) {
        self.companyName = companyName
        print("\(companyName) is created (Company allocated)")
    }

    deinit {
        print("\(companyName) is freed (Company deallocated)")
    }
}

// Create the retain cycle
var apple: Company? = Company(companyName: "Apple")
var tim: Employee? = Employee(name: "Tim Cook")

apple?.ceo = tim        // Company -> Employee (strong)
tim?.company = apple     // Employee -> Company (strong)

// Try to free them
apple = nil  // Company NOT freed! Employee still holds a strong reference.
tim = nil    // Employee NOT freed! Company still holds a strong reference.
// Neither deinit is called! MEMORY LEAK! 💥


// Bug 2: Closure capturing self strongly
class DataLoader {
    var data: String = ""
    var onComplete: (() -> Void)?

    func loadData() {
        // This closure captures 'self' strongly — retain cycle!
        onComplete = {
            self.data = "Loaded!"  // <-- BUG: strong capture of self
            print(self.data)
        }
    }

    deinit {
        print("DataLoader freed")
    }
}

var loader: DataLoader? = DataLoader()
loader?.loadData()
loader?.onComplete?()
loader = nil  // deinit is NEVER called! MEMORY LEAK! 💥

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Employee has a strong reference to Company, and Company has a strong
//         reference to Employee. When you set both variables to nil, the objects
//         still reference each other, so ARC can't free either one.
//
//         apple (nil) --> Company ---strong---> Employee <-- tim (nil)
//                         ^                      |
//                         |------strong----------|
//         (Circular reference! Neither can be freed.)
//
// Bug 2: The closure stored in `onComplete` captures `self` (the DataLoader)
//         strongly. So: DataLoader -> onComplete closure -> DataLoader.
//         This is a retain cycle through a closure.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Use `weak` to break the retain cycle between classes
class Employee {
    var name: String
    var company: Company?  // Strong reference (employee belongs to a company)

    init(name: String) {
        self.name = name
        print("\(name) is hired (Employee allocated)")
    }

    deinit {
        print("\(name) is freed (Employee deallocated)")
    }
}

class Company {
    var companyName: String
    weak var ceo: Employee?  // WEAK reference — breaks the cycle!

    init(companyName: String) {
        self.companyName = companyName
        print("\(companyName) is created (Company allocated)")
    }

    deinit {
        print("\(companyName) is freed (Company deallocated)")
    }
}

var apple: Company? = Company(companyName: "Apple")
var tim: Employee? = Employee(name: "Tim Cook")

apple?.ceo = tim
tim?.company = apple

// Now freeing works correctly!
tim = nil
// Prints: "Tim Cook is freed (Employee deallocated)"
// Because Company only has a WEAK reference, it doesn't prevent deallocation.

apple = nil
// Prints: "Apple is freed (Company deallocated)"


// Fix 2: Use [weak self] in closures to prevent retain cycles
class DataLoader {
    var data: String = ""
    var onComplete: (() -> Void)?

    func loadData() {
        // Use [weak self] to capture self weakly
        onComplete = { [weak self] in
            guard let self = self else {
                print("DataLoader was already freed")
                return
            }
            self.data = "Loaded!"
            print(self.data)
        }
    }

    deinit {
        print("DataLoader freed")
    }
}

var loader: DataLoader? = DataLoader()
loader?.loadData()
loader?.onComplete?()  // Prints: "Loaded!"
loader = nil           // Prints: "DataLoader freed" — no memory leak!


// ============================================================================
// BONUS: When to use `weak` vs `unowned`
// ============================================================================

// `weak` — The reference can become nil at any time. Always an Optional.
//           Use when the referenced object might be deallocated first.
//           Example: A delegate pattern (the delegate might go away).

// `unowned` — The reference is expected to ALWAYS have a value during its
//              lifetime. NOT optional. Crashes if accessed after deallocation.
//              Use when you're sure the referenced object outlives this one.
//              Example: A child that always has a parent.

class Customer {
    let name: String
    var card: CreditCard?

    init(name: String) { self.name = name }
    deinit { print("\(name) is freed") }
}

class CreditCard {
    let number: Int
    unowned let owner: Customer  // Card can't exist without a customer

    init(number: Int, owner: Customer) {
        self.number = number
        self.owner = owner
    }
    deinit { print("Card \(number) is freed") }
}

var john: Customer? = Customer(name: "John")
john?.card = CreditCard(number: 1234_5678, owner: john!)

john = nil
// Prints: "John is freed"
// Prints: "Card 12345678 is freed"
// Both are properly deallocated!


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. Explain ARC in simple terms: "Swift counts how many strong references
//    point to an object. When the count reaches zero, it frees the memory."
//
// 2. A retain cycle = two objects holding strong references to each other.
//
// 3. Break retain cycles with `weak` or `unowned`:
//    - `weak`: reference becomes nil when object is freed (safe)
//    - `unowned`: assumes object is always alive (crashes if not)
//
// 4. In closures, use `[weak self]` to prevent capturing self strongly.
//
// 5. Use Xcode's Memory Graph Debugger to find retain cycles in real apps.
//
// Common interview question: "How do you detect and fix a memory leak?"
// Answer: Use Instruments (Leaks tool) or Xcode's Memory Graph Debugger.
//         Look for objects that should have been deallocated but weren't.
//         Fix by making one of the references `weak` or `unowned`.
// ============================================================================
