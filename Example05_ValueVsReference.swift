/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 5: VALUE VS REFERENCE TYPES
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Struct vs Class behavior and unexpected mutations
 Common Interview Question: "When should you use struct vs class?"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Unexpected copying behavior with classes

struct PointStruct {
    var x: Double
    var y: Double
}

class PointClass {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

func demonstrateValueVsReferenceBug() {
    // Using struct (value type)
    var point1 = PointStruct(x: 0, y: 0)
    var point2 = point1  // Creates a COPY
    point2.x = 10
    
    print("Struct - point1.x: \(point1.x)")  // 0 (unchanged)
    print("Struct - point2.x: \(point2.x)")  // 10
    
    // Using class (reference type)
    let pointA = PointClass(x: 0, y: 0)
    let pointB = pointA  // 🐛 Shares the SAME instance!
    pointB.x = 10
    
    print("Class - pointA.x: \(pointA.x)")  // 10 (changed! 💥)
    print("Class - pointB.x: \(pointB.x)")  // 10
    
    // BUG: Developer expected pointA to be unchanged, but it was!
}


// Scenario 2: Mutating array of structs vs classes

struct PersonStruct {
    var name: String
    var age: Int
}

class PersonClass {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

func demonstrateArrayMutationBug() {
    // Array of structs
    var people1 = [
        PersonStruct(name: "Alice", age: 25),
        PersonStruct(name: "Bob", age: 30)
    ]
    
    var firstPerson = people1[0]  // Creates a COPY
    firstPerson.age = 26
    print("Struct Array - Original: \(people1[0].age)")  // 25 (unchanged)
    
    // Array of classes
    var people2 = [
        PersonClass(name: "Alice", age: 25),
        PersonClass(name: "Bob", age: 30)
    ]
    
    var firstPersonClass = people2[0]  // 🐛 Reference to SAME object
    firstPersonClass.age = 26
    print("Class Array - Original: \(people2[0].age)")  // 26 (changed! 💥)
    
    // BUG: Developer didn't realize modifying local variable affects array!
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Value types (struct, enum) are COPIED when assigned or passed.
 Reference types (class) are SHARED when assigned or passed.
 
 This leads to subtle bugs when:
 1. You expect a copy but get a reference (using class)
 2. You expect a reference but get a copy (using struct)
 3. Performance issues from unexpected copying
 4. Unexpected mutations from shared references
 
 Value Types (Struct, Enum):
 - Copied on assignment
 - Each copy is independent
 - Mutations don't affect other copies
 - Stored on stack (usually faster)
 
 Reference Types (Class):
 - Shared on assignment
 - All references point to same instance
 - Mutations affect all references
 - Stored on heap (slower allocation)
 - Support inheritance
 - Need to manage retain cycles
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Check if type is struct or class
 2. Trace where values are assigned/passed
 3. Add print statements showing memory addresses (for classes)
 4. Use === operator to check if two references are identical
 5. Look for unexpected mutations
 
 Memory address checking:
 let obj1 = MyClass()
 let obj2 = obj1
 print(ObjectIdentifier(obj1))
 print(ObjectIdentifier(obj2))
 // Same address = same instance
 
 Identity checking:
 if obj1 === obj2 { print("Same instance") }
 if obj1 !== obj2 { print("Different instances") }
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Choose the right type based on semantics

// Use STRUCT when:
// - Modeling simple data
// - Want value semantics (copies)
// - Comparing with == should compare values
// - Thread safety is important
struct Point {
    var x: Double
    var y: Double
    
    // Equatable for value comparison
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// Use CLASS when:
// - Need reference semantics (sharing)
// - Need inheritance
// - Need deinit
// - Modeling identity (each instance is unique)
class Window {
    var title: String
    var isVisible: Bool
    
    init(title: String, isVisible: Bool = false) {
        self.title = title
        self.isVisible = isVisible
    }
    
    // Reference comparison with ===
    // Window instances are unique even if properties match
}


// SOLUTION 2: Explicit copying for classes when needed

class PersonFixed {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // ✅ Implement copy method when you need a true copy
    func copy() -> PersonFixed {
        return PersonFixed(name: self.name, age: self.age)
    }
}


// SOLUTION 3: Using Copy-on-Write (COW) for performance

struct LargeDataStructure {
    // Private class wrapper for data
    private class Storage {
        var data: [Int]
        
        init(data: [Int]) {
            self.data = data
        }
        
        func copy() -> Storage {
            return Storage(data: self.data)
        }
    }
    
    private var storage: Storage
    
    init(data: [Int]) {
        self.storage = Storage(data: data)
    }
    
    // Copy-on-write: only copy when mutating
    private mutating func ensureUniqueStorage() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
    }
    
    var data: [Int] {
        get {
            return storage.data
        }
        set {
            ensureUniqueStorage()
            storage.data = newValue
        }
    }
}


// SOLUTION 4: Understanding mutability

class MutableContainer {
    var items: [String] = []  // Can mutate even if instance is 'let'
}

struct ImmutableContainer {
    var items: [String] = []  // Cannot mutate if instance is 'let'
}

func demonstrateMutability() {
    // Class: 'let' doesn't prevent property mutations
    let container1 = MutableContainer()
    container1.items.append("A")  // ✅ Allowed
    // container1 = MutableContainer()  // ❌ Not allowed
    
    // Struct: 'let' prevents ALL mutations
    let container2 = ImmutableContainer()
    // container2.items.append("A")  // ❌ Not allowed
    
    // Use 'var' for mutable struct
    var container3 = ImmutableContainer()
    container3.items.append("A")  // ✅ Allowed
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample05() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 5: VALUE VS REFERENCE TYPES")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Value semantics (struct)
    print("Test Case 1: Struct (Value Type)")
    var p1 = Point(x: 0, y: 0)
    var p2 = p1  // Copy
    p2.x = 10
    print("p1.x = \(p1.x)")  // 0
    print("p2.x = \(p2.x)")  // 10
    print("✅ Independent copies\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Reference semantics (class)
    print("Test Case 2: Class (Reference Type)")
    let w1 = Window(title: "Main")
    let w2 = w1  // Reference
    w2.title = "Secondary"
    print("w1.title = \(w1.title)")  // Secondary
    print("w2.title = \(w2.title)")  // Secondary
    print("w1 === w2: \(w1 === w2)")  // true
    print("✅ Shared instance\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Explicit copying
    print("Test Case 3: Explicit Copy for Class")
    let person1 = PersonFixed(name: "Alice", age: 25)
    let person2 = person1.copy()  // Explicit copy
    person2.age = 26
    print("person1.age = \(person1.age)")  // 25
    print("person2.age = \(person2.age)")  // 26
    print("✅ Explicit copy creates independent instance\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Identity vs Equality
    print("Test Case 4: Identity vs Equality")
    let w3 = Window(title: "Main")
    let w4 = Window(title: "Main")
    print("w3 === w4: \(w3 === w4)")  // false (different instances)
    print("w3.title == w4.title: \(w3.title == w4.title)")  // true (same values)
    print("✅ Identity checks references, equality checks values\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Fundamental difference:
    - Struct/Enum: Value types (copied)
    - Class: Reference type (shared)
 
 2. When to use STRUCT:
    - Simple data models
    - Want value semantics
    - No need for inheritance
    - Thread safety matters
    - Examples: Point, Size, Rect, User profile data
 
 3. When to use CLASS:
    - Need identity (unique instances)
    - Need inheritance
    - Need to share state
    - Large objects (avoid copy overhead with COW)
    - Examples: ViewController, Network manager, Database
 
 4. Important operators:
    - == : Value equality (Equatable)
    - === : Reference identity (only for classes)
    - !== : Reference non-identity
 
 5. Mutability rules:
    - Class with 'let': Can mutate properties
    - Struct with 'let': Cannot mutate anything
    - Struct with 'var': Can mutate properties
 
 6. Performance considerations:
    - Structs: Stack allocation (fast), copying overhead
    - Classes: Heap allocation (slower), reference counting
    - Large structs: Use Copy-on-Write
    - Swift's Array, String, Dictionary use COW
 
 7. Apple's guidelines (from API Design Guidelines):
    - Prefer structs by default
    - Use classes when you need reference semantics or inheritance
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between struct and class in Swift?"
 A1: Structs are value types (copied), classes are reference types
     (shared). Structs don't support inheritance. Classes need
     memory management. 'let' struct is fully immutable.
 
 Q2: "When would you choose a class over a struct?"
 A2: When you need inheritance, reference semantics (shared state),
     deinit, or Objective-C interoperability. For example,
     ViewControllers must be classes.
 
 Q3: "What is Copy-on-Write and why is it important?"
 A3: COW delays copying until the data is modified. Swift's Array,
     Dictionary, and String use it for performance - you get value
     semantics without the cost of copying until mutation.
 
 Q4: "What's the difference between == and === ?"
 A4: == checks value equality (Equatable protocol). === checks
     reference identity (same instance). === only works with classes.
 
 Q5: "Why does 'let' work differently for structs vs classes?"
 A5: For structs, 'let' makes the entire value immutable. For classes,
     'let' only makes the reference constant, but you can still mutate
     properties.
 
 Q6: "Are closures value types or reference types?"
 A6: Closures are reference types. When you assign a closure to
     multiple variables, they all reference the same closure instance.
*/


// 💡 ADVANCED: Mixing Value and Reference Types
// ═══════════════════════════════════════════════════════════════════

// Struct containing class reference
struct Config {
    var name: String  // Value type
    var logger: Logger  // Reference type - SHARED!
}

class Logger {
    var enabled: Bool = true
}

func demonstrateMixedTypes() {
    let logger = Logger()
    
    var config1 = Config(name: "Debug", logger: logger)
    var config2 = config1  // config2 is a copy
    
    config2.name = "Release"  // Independent (value)
    config2.logger.enabled = false  // SHARED (reference)
    
    print(config1.name)  // "Debug"
    print(config1.logger.enabled)  // false (shared!)
    
    // The struct is copied, but the class inside is referenced!
}


// Class containing struct
class ViewModel {
    var data: Point  // Value type - COPIED on assignment
    
    init(data: Point) {
        self.data = data
    }
}

func demonstrateClassWithStruct() {
    let point = Point(x: 5, y: 10)
    let vm = ViewModel(data: point)
    
    // point is copied into vm.data
    // Modifying point doesn't affect vm.data
}


// Uncomment to run:
// runExample05()
