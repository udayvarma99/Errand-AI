/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 8: TYPE CASTING ERRORS
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Safe downcasting and type checking
 Common Interview Question: "Explain type casting in Swift with as, as?, as!"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Force casting that can fail

class Animal {
    var name: String
    init(name: String) { self.name = name }
}

class Dog: Animal {
    func bark() { print("Woof!") }
}

class Cat: Animal {
    func meow() { print("Meow!") }
}

func demonstrateForceDowncastBug() {
    let animals: [Animal] = [
        Dog(name: "Buddy"),
        Cat(name: "Whiskers"),
        Dog(name: "Max")
    ]
    
    for animal in animals {
        // 🐛 BUG: Force cast will crash on Cat!
        let dog = animal as! Dog  // 💥 CRASH when animal is Cat
        dog.bark()
    }
}


// Scenario 2: Type checking before cast (inefficient)

func demonstrateRedundantTypeCheck(animal: Animal) {
    // 🐛 INEFFICIENT: Checking type twice
    if animal is Dog {
        let dog = animal as! Dog  // Still force casting!
        dog.bark()
    }
}


// Scenario 3: Mixing Any and AnyObject

func demonstrateAnyVsAnyObjectBug() {
    let items: [Any] = [
        1,
        "Hello",
        Dog(name: "Buddy"),
        3.14
    ]
    
    for item in items {
        // 🐛 BUG: Force casting to String fails for non-strings
        let text = item as! String  // 💥 CRASH on numbers and Dog
        print(text)
    }
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Type casting in Swift allows you to check and convert types:
 
 1. as: Upcasting (always succeeds) - compile time
 2. as?: Optional downcast - runtime, returns nil if fails
 3. as!: Force downcast - runtime, crashes if fails
 
 Common issues:
 - Using as! when type is uncertain → CRASH
 - Not using optional binding with as?
 - Confusing Any vs AnyObject
 - Type checking without pattern matching
 - Forgetting that casting doesn't change the object
 
 Type hierarchy:
 - Any: Can represent any type (value or reference)
 - AnyObject: Only class instances
 - Specific protocol or class
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Never use as! unless you're 100% certain of the type
 2. Use 'is' to check type before casting
 3. Prefer 'as?' with optional binding
 4. Use switch with pattern matching for multiple types
 5. Check Xcode warnings about forced casts
 
 Debugging:
 - type(of:) to check actual type
 - Mirror for runtime inspection
 - String(describing:) for type name
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Safe optional downcast with if let

func demonstrateSafeDowncast() {
    let animals: [Animal] = [
        Dog(name: "Buddy"),
        Cat(name: "Whiskers"),
        Dog(name: "Max")
    ]
    
    for animal in animals {
        // ✅ Safe optional downcast
        if let dog = animal as? Dog {
            dog.bark()
        } else if let cat = animal as? Cat {
            cat.meow()
        }
    }
}


// SOLUTION 2: Type checking with 'is'

func handleAnimal(_ animal: Animal) {
    // ✅ Type checking
    if animal is Dog {
        print("\(animal.name) is a dog")
    } else if animal is Cat {
        print("\(animal.name) is a cat")
    }
}


// SOLUTION 3: Switch with pattern matching (BEST for multiple types)

func demonstratePatternMatching() {
    let animals: [Animal] = [
        Dog(name: "Buddy"),
        Cat(name: "Whiskers"),
        Dog(name: "Max")
    ]
    
    for animal in animals {
        // ✅ BEST: Pattern matching with switch
        switch animal {
        case let dog as Dog:
            dog.bark()
        case let cat as Cat:
            cat.meow()
        default:
            print("Unknown animal: \(animal.name)")
        }
    }
}


// SOLUTION 4: Handling Any type safely

func demonstrateAnySafely() {
    let items: [Any] = [
        42,
        "Hello",
        Dog(name: "Buddy"),
        3.14,
        [1, 2, 3]
    ]
    
    for item in items {
        // ✅ Pattern matching with Any
        switch item {
        case let number as Int:
            print("Integer: \(number)")
        case let text as String:
            print("String: \(text)")
        case let dog as Dog:
            print("Dog: \(dog.name)")
            dog.bark()
        case let decimal as Double:
            print("Double: \(decimal)")
        case let array as [Int]:
            print("Array: \(array)")
        default:
            print("Unknown type: \(type(of: item))")
        }
    }
}


// SOLUTION 5: Type erasure and casting back

protocol Identifiable {
    var id: String { get }
}

struct User: Identifiable {
    var id: String
    var name: String
}

struct Product: Identifiable {
    var id: String
    var price: Double
}

func demonstrateProtocolCasting() {
    let items: [Identifiable] = [
        User(id: "1", name: "Alice"),
        Product(id: "2", price: 99.99),
        User(id: "3", name: "Bob")
    ]
    
    for item in items {
        print("ID: \(item.id)")
        
        // ✅ Cast back to concrete type when needed
        if let user = item as? User {
            print("User name: \(user.name)")
        } else if let product = item as? Product {
            print("Product price: $\(product.price)")
        }
    }
}


// SOLUTION 6: Upcasting (always safe)

func demonstrateUpcasting() {
    let dog = Dog(name: "Buddy")
    
    // ✅ Upcasting to superclass (always succeeds)
    let animal: Animal = dog as Animal  // or just: let animal: Animal = dog
    
    // ✅ Upcasting to protocol
    // let identifiable: Identifiable = user as Identifiable
}


// SOLUTION 7: Conditional casting in guard

func processAnimal(_ animal: Animal) {
    // ✅ Guard with conditional cast
    guard let dog = animal as? Dog else {
        print("Not a dog")
        return
    }
    
    dog.bark()
    // dog is available for rest of function
}


// SOLUTION 8: Checking type at runtime

func describeType(_ value: Any) {
    print("Type: \(type(of: value))")
    print("Description: \(String(describing: type(of: value)))")
    
    // Check if value is an instance of a type
    if value is String {
        print("It's a String!")
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample08() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 8: TYPE CASTING")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Safe downcast
    print("Test Case 1: Safe Downcast with if let")
    demonstrateSafeDowncast()
    print("✅ All animals handled safely\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Pattern matching
    print("Test Case 2: Pattern Matching with Switch")
    demonstratePatternMatching()
    print("✅ Pattern matching is clean and safe\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Handling Any
    print("Test Case 3: Handling Any Type")
    demonstrateAnySafely()
    print("✅ All types handled correctly\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Protocol casting
    print("Test Case 4: Protocol to Concrete Type")
    demonstrateProtocolCasting()
    print("✅ Cast from protocol to concrete type\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 5: Type checking
    print("Test Case 5: Runtime Type Checking")
    describeType(42)
    describeType("Hello")
    describeType(Dog(name: "Buddy"))
    print("✅ Runtime type information\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Type casting operators:
    - as: Upcasting (compile time, always succeeds)
    - as?: Optional downcast (runtime, returns nil if fails)
    - as!: Force downcast (runtime, crashes if fails)
 
 2. When to use each:
    - as: Converting to superclass or protocol
    - as?: When you're not sure of the type (most common)
    - as!: When you're 100% certain (avoid when possible)
 
 3. Type checking:
    - is: Check if value is of a type (returns Bool)
    - type(of:): Get the actual type at runtime
    - switch case: Pattern matching (best for multiple types)
 
 4. Best practices:
    - Prefer as? with if let or guard let
    - Use switch for multiple type checks
    - Avoid as! except in controlled scenarios
    - Use pattern matching for elegance
 
 5. Any vs AnyObject:
    - Any: Can hold any type (struct, class, enum, etc.)
    - AnyObject: Only class instances
    - Prefer specific types over Any when possible
 
 6. Common patterns:
    - Heterogeneous arrays: [Any]
    - JSON parsing: Any and casting
    - Polymorphism: Base class array with downcasting
    - Protocol existentials: [SomeProtocol]
 
 7. Performance:
    - Type casting has runtime cost
    - Minimize casting in hot paths
    - Consider generic constraints instead
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between as, as?, and as!?"
 A1: 'as' is for upcasting (compile time, safe). 'as?' is optional
     downcast (returns nil if fails). 'as!' force downcast (crashes
     if fails). Always prefer as? unless you're certain.
 
 Q2: "When would you use Any vs AnyObject?"
 A2: Use Any when you need to store any type including value types
     (structs, enums). Use AnyObject when you only need to store
     class instances. AnyObject is less common in Swift.
 
 Q3: "How do you safely check and cast types?"
 A3: Use 'is' to check type, then 'as?' with if let to cast. Or use
     switch with pattern matching for cleaner code with multiple types.
 
 Q4: "What's the difference between type(of:) and is?"
 A4: 'is' checks if a value is an instance of a type (includes
     subclasses). type(of:) returns the exact runtime type. Use 'is'
     for type checking, type(of:) for debugging.
 
 Q5: "Can you cast between unrelated types?"
 A5: No, casting only works within a type hierarchy (class inheritance)
     or protocol conformance. For conversions between unrelated types,
     use initializers or conversion methods.
 
 Q6: "What happens when you force cast the wrong type?"
 A6: The app crashes with "Could not cast value of type X to Y". This
     is why as! should be avoided unless you're absolutely certain.
*/


// 💡 ADVANCED: Type Casting Patterns
// ═══════════════════════════════════════════════════════════════════

// Pattern 1: Compactly map with casting
func demonstrateCompactMapCast() {
    let items: [Any] = [1, "two", 3, "four", 5]
    
    // ✅ Get only integers
    let integers = items.compactMap { $0 as? Int }
    print("Integers: \(integers)")  // [1, 3, 5]
    
    // ✅ Get only strings
    let strings = items.compactMap { $0 as? String }
    print("Strings: \(strings)")  // ["two", "four"]
}


// Pattern 2: Type-safe heterogeneous data
enum DataItem {
    case integer(Int)
    case text(String)
    case flag(Bool)
    
    // Better than using Any!
}

func processDataItems(_ items: [DataItem]) {
    for item in items {
        switch item {
        case .integer(let value):
            print("Int: \(value)")
        case .text(let value):
            print("String: \(value)")
        case .flag(let value):
            print("Bool: \(value)")
        }
    }
}


// Pattern 3: Generic constraints instead of casting
func processAnimals<T: Animal>(_ animals: [T]) {
    // No casting needed!
    for animal in animals {
        print(animal.name)
    }
}


// Pattern 4: Protocol with associated type (better than Any)
protocol Container {
    associatedtype Item
    var items: [Item] { get }
}

struct IntContainer: Container {
    var items: [Int]
}


// Pattern 5: Mirror for deep inspection
func inspectType(_ value: Any) {
    let mirror = Mirror(reflecting: value)
    print("Type: \(mirror.subjectType)")
    
    for child in mirror.children {
        print("\(child.label ?? "unnamed"): \(child.value)")
    }
}


// Uncomment to run:
// runExample08()
