/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 3: MEMORY LEAKS WITH RETAIN CYCLES
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Strong reference cycles and memory management
 Common Interview Question: "Explain ARC and how to prevent retain cycles"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

class PersonBuggy {
    let name: String
    var apartment: ApartmentBuggy?
    
    init(name: String) {
        self.name = name
        print("✅ \(name) is being initialized")
    }
    
    deinit {
        print("❌ \(name) is being deinitialized")
    }
}

class ApartmentBuggy {
    let unit: String
    var tenant: PersonBuggy?  // 🐛 Strong reference to PersonBuggy
    
    init(unit: String) {
        self.unit = unit
        print("✅ Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("❌ Apartment \(unit) is being deinitialized")
    }
}

// BUG: This creates a retain cycle!
func createRetainCycleBuggy() {
    let john = PersonBuggy(name: "John")
    let unit4A = ApartmentBuggy(unit: "4A")
    
    john.apartment = unit4A   // Person → Apartment (strong)
    unit4A.tenant = john      // Apartment → Person (strong)
    
    // Both objects keep each other alive!
    // When this function returns, NEITHER object is deallocated
    // 💥 MEMORY LEAK: deinit will never be called!
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 A retain cycle (or strong reference cycle) occurs when two objects
 hold strong references to each other, preventing both from being
 deallocated. This causes memory leaks.
 
 In this example:
 - Person has a strong reference to Apartment
 - Apartment has a strong reference to Person
 - When both go out of scope, their reference count is still 1
 - Neither can be deallocated → MEMORY LEAK
 
 Swift uses ARC (Automatic Reference Counting):
 - Each object has a reference count
 - Strong references increase the count
 - Object is deallocated when count reaches 0
 - Retain cycles prevent count from reaching 0
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Look for two-way relationships between classes
 2. Use Xcode's Memory Graph Debugger (Debug Navigator → Memory)
 3. Check if deinit is called when objects should be released
 4. Use Instruments → Leaks tool
 5. Look for closures capturing self strongly
 
 Xcode Memory Graph:
 - Run app and navigate to the screen
 - Click Debug Memory Graph button (⚙️ icon)
 - Look for purple ! symbols indicating leaks
 - View the reference graph
 
 Instruments:
 - Product → Profile → Leaks
 - Exercise the app
 - Look for red leak indicators
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

class PersonFixed {
    let name: String
    var apartment: ApartmentFixed?
    
    init(name: String) {
        self.name = name
        print("✅ \(name) is being initialized")
    }
    
    deinit {
        print("✨ \(name) is being deinitialized (no leak!)")
    }
}

class ApartmentFixed {
    let unit: String
    weak var tenant: PersonFixed?  // ✅ SOLUTION: Use 'weak' reference
    
    init(unit: String) {
        self.unit = unit
        print("✅ Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("✨ Apartment \(unit) is being deinitialized (no leak!)")
    }
}

// Now no retain cycle!
func createNoRetainCycle() {
    let john = PersonFixed(name: "John")
    let unit4A = ApartmentFixed(unit: "4A")
    
    john.apartment = unit4A   // Person → Apartment (strong)
    unit4A.tenant = john      // Apartment → Person (weak) ✅
    
    // When function returns:
    // - john's reference count: 0 (only weak reference from apartment)
    // - john is deallocated
    // - john.apartment becomes nil
    // - unit4A's reference count: 0
    // - unit4A is deallocated
    // Both deinit methods are called! ✨
}


// 📋 WEAK vs UNOWNED
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 2: Using 'unowned' (when reference will never be nil)

class CustomerFixed {
    let name: String
    var card: CreditCardFixed?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("✨ Customer \(name) deinitialized")
    }
}

class CreditCardFixed {
    let number: UInt64
    unowned let customer: CustomerFixed  // ✅ Use 'unowned' - customer always exists
    
    init(number: UInt64, customer: CustomerFixed) {
        self.number = number
        self.customer = customer
    }
    
    deinit {
        print("✨ Card \(number) deinitialized")
    }
}

/*
 weak vs unowned:
 
 weak:
 - Makes the reference Optional (Type?)
 - Automatically becomes nil when object is deallocated
 - Use when reference CAN be nil during lifetime
 - Safe: accessing nil weak reference won't crash
 
 unowned:
 - Not Optional (Type)
 - Assumes reference always exists
 - Use when reference should NEVER be nil
 - Unsafe: accessing deallocated unowned reference = CRASH
 
 Rule of thumb:
 - Use weak when lifetime is independent
 - Use unowned when lifetime is dependent (child can't outlive parent)
*/


// 🚨 CLOSURE RETAIN CYCLES
// ═══════════════════════════════════════════════════════════════════

class ViewControllerBuggy {
    var name: String = "HomeVC"
    var completionHandler: (() -> Void)?
    
    func setupBuggy() {
        // 🐛 Closure captures self strongly
        completionHandler = {
            print("Completed in \(self.name)")  // Strong capture of self
        }
        // ViewController → Closure (strong)
        // Closure → ViewController (strong)
        // RETAIN CYCLE! 💥
    }
    
    deinit {
        print("ViewControllerBuggy deinitialized")  // Never called!
    }
}

class ViewControllerFixed {
    var name: String = "HomeVC"
    var completionHandler: (() -> Void)?
    
    // SOLUTION 1: Weak capture list
    func setupWithWeak() {
        completionHandler = { [weak self] in
            guard let self = self else { return }
            print("Completed in \(self.name)")
        }
    }
    
    // SOLUTION 2: Unowned capture (if you're sure self won't be nil)
    func setupWithUnowned() {
        completionHandler = { [unowned self] in
            print("Completed in \(self.name)")
        }
    }
    
    deinit {
        print("✨ ViewControllerFixed deinitialized")  // Now called!
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample03() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 3: MEMORY LEAKS WITH RETAIN CYCLES")
    print("═══════════════════════════════════════════════════════\n")
    
    print("Test Case 1: Buggy Version (Retain Cycle)")
    print("Creating objects...")
    createRetainCycleBuggy()
    print("⚠️  Objects still in memory (deinit not called)\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    print("Test Case 2: Fixed Version (No Retain Cycle)")
    print("Creating objects...")
    createNoRetainCycle()
    print("✅ Objects properly deallocated!\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    print("Test Case 3: Customer-Card (unowned example)")
    var customer: CustomerFixed? = CustomerFixed(name: "Alice")
    customer?.card = CreditCardFixed(number: 1234_5678_9012_3456, customer: customer!)
    print("Setting customer to nil...")
    customer = nil
    print("✅ Both deallocated!\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Retain cycles are MEMORY LEAKS - objects never get deallocated
 
 2. Common scenarios causing retain cycles:
    - Two-way relationships between classes
    - Closures capturing self
    - Delegate patterns with strong references
    - Parent-child relationships
 
 3. Solutions:
    - Use 'weak' for optional references
    - Use 'unowned' for non-optional references that won't outlive
    - Use capture lists in closures: [weak self] or [unowned self]
 
 4. When to use each:
    - weak: Reference can be nil (most common)
    - unowned: Reference never nil (parent-child)
    - strong: Default, no cycle risk
 
 5. Delegate pattern (iOS standard):
    - Always mark delegates as weak
    - protocol SomeDelegate: AnyObject { }
    - weak var delegate: SomeDelegate?
 
 6. Testing for leaks:
    - Add deinit methods with print statements
    - Use Memory Graph Debugger
    - Use Instruments Leaks tool
    - Watch for growing memory usage
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "Explain how ARC works in Swift"
 A1: ARC automatically tracks and manages memory by keeping count of
     how many strong references exist to each class instance. When
     count reaches zero, the instance is deallocated.
 
 Q2: "What's the difference between weak and unowned?"
 A2: weak is Optional and becomes nil when deallocated. unowned is
     non-Optional and assumes the reference always exists. Use weak
     when unsure, unowned for guaranteed parent-child relationships.
 
 Q3: "Why don't structs have retain cycles?"
 A3: Structs are value types, not reference types. They're copied,
     not referenced, so there's no reference counting involved.
 
 Q4: "How do you break a retain cycle in a closure?"
 A4: Use a capture list: [weak self] or [unowned self] in the closure
     definition before the parameter list.
 
 Q5: "What's the delegate pattern memory management best practice?"
 A5: Always declare delegates as weak to avoid retain cycles:
     weak var delegate: SomeDelegate?
     And the protocol must be AnyObject (class-only).
*/


// 💡 ADVANCED: Closure Capture List Details
// ═══════════════════════════════════════════════════════════════════

class AdvancedCaptureExample {
    var value: Int = 42
    
    func demonstrateCaptures() {
        // Multiple captures in list
        let anotherObject = PersonFixed(name: "Test")
        
        let closure = { [weak self, weak anotherObject] in
            guard let self = self else { return }
            print("Value: \(self.value)")
            print("Person: \(anotherObject?.name ?? "gone")")
        }
        
        closure()
    }
    
    // Capturing specific properties (creates a copy)
    func captureValue() {
        let closure = { [value] in  // Captures the VALUE, not self
            print("Captured value: \(value)")
        }
        
        self.value = 100
        closure()  // Prints: "Captured value: 42" (original value)
    }
}


// Uncomment to run:
// runExample03()
