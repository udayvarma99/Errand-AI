/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 6: PROTOCOL CONFORMANCE ERRORS
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Protocol requirements and extensions
 Common Interview Question: "Explain Protocol-Oriented Programming in Swift"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Missing required methods

protocol Drawable {
    func draw()
    func resize(by scale: Double)
}

struct CircleBuggy: Drawable {
    var radius: Double
    
    func draw() {
        print("Drawing circle with radius \(radius)")
    }
    
    // 🐛 BUG: Missing resize method!
    // Compiler error: Type 'CircleBuggy' does not conform to protocol 'Drawable'
}


// Scenario 2: Incorrect method signature

protocol Identifiable {
    var id: String { get }  // Read-only property
    func getIdentifier() -> String
}

struct UserBuggy: Identifiable {
    var id: String { return "123" }  // ✅ Correct
    
    // 🐛 BUG: Wrong return type!
    func getIdentifier() -> Int {  // Should return String
        return 123
    }
}


// Scenario 3: Protocol with Self requirement on value type

protocol Copyable {
    func copy() -> Self
}

class DocumentBuggy: Copyable {
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    // 🐛 BUG: Returns DocumentBuggy but should return Self
    func copy() -> DocumentBuggy {  // Should be -> Self
        return DocumentBuggy(content: self.content)
    }
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Protocol conformance errors occur when:
 1. Missing required methods or properties
 2. Method signature doesn't match exactly
 3. Access control is more restrictive than protocol
 4. Property has wrong getter/setter requirements
 5. Using Self incorrectly
 6. Protocol constraints not satisfied
 
 Common mistakes:
 - Forgetting to implement all requirements
 - Wrong parameter types or return types
 - Making required property read-only when it should be read-write
 - Not understanding associated types
 - Missing init requirements
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Read the compiler error carefully
 2. Check protocol definition for all requirements
 3. Compare method signatures exactly (names, parameters, return types)
 4. Check property requirements (get/set)
 5. Verify access control levels
 6. Use Xcode's Fix-it suggestions
 
 Xcode helps:
 - Red error: "Type does not conform to protocol"
 - Click error → shows missing requirements
 - Use "Add protocol stubs" Fix-it
 - Cmd+Click on protocol name to see definition
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Implement all required methods

protocol DrawableFixed {
    func draw()
    func resize(by scale: Double)
}

struct Circle: DrawableFixed {
    var radius: Double
    
    func draw() {
        print("Drawing circle with radius \(radius)")
    }
    
    func resize(by scale: Double) {  // ✅ Implemented
        print("Resizing circle by \(scale)")
    }
}


// SOLUTION 2: Match method signatures exactly

protocol IdentifiableFixed {
    var id: String { get }
    func getIdentifier() -> String
}

struct User: IdentifiableFixed {
    var id: String
    
    func getIdentifier() -> String {  // ✅ Correct return type
        return id
    }
}


// SOLUTION 3: Use Self correctly

protocol CopyableFixed {
    func copy() -> Self
}

class Document: CopyableFixed {
    var content: String
    
    required init(content: String) {  // 'required' for Self return type
        self.content = content
    }
    
    func copy() -> Self {  // ✅ Returns Self
        return type(of: self).init(content: self.content)
    }
}


// SOLUTION 4: Understanding property requirements

protocol NamedEntity {
    var name: String { get set }  // Must be mutable
    var description: String { get }  // Can be computed
}

struct Product: NamedEntity {
    var name: String  // ✅ Mutable stored property
    
    var description: String {  // ✅ Computed read-only property
        return "Product: \(name)"
    }
}


// SOLUTION 5: Protocol extensions with default implementations

protocol Loggable {
    func log()
}

extension Loggable {
    // ✅ Default implementation
    func log() {
        print("Logging: \(self)")
    }
}

struct Task: Loggable {
    var title: String
    // No need to implement log() - uses default
}

struct ImportantTask: Loggable {
    var title: String
    
    // ✅ Override default implementation
    func log() {
        print("⚠️ IMPORTANT: \(title)")
    }
}


// SOLUTION 6: Associated types

protocol Container {
    associatedtype Item
    var items: [Item] { get set }
    mutating func add(_ item: Item)
}

struct IntContainer: Container {
    typealias Item = Int  // ✅ Specify associated type (optional if inferred)
    var items: [Int] = []
    
    mutating func add(_ item: Int) {
        items.append(item)
    }
}

struct StringContainer: Container {
    // typealias Item = String - inferred from items property
    var items: [String] = []
    
    mutating func add(_ item: String) {
        items.append(item)
    }
}


// SOLUTION 7: Class-only protocols

protocol ViewControllerProtocol: AnyObject {  // ✅ class-only
    var title: String { get set }
}

// Only classes can conform
class MyViewController: ViewControllerProtocol {
    var title: String = "Home"
}

// struct MyView: ViewControllerProtocol { }  // ❌ Error: struct can't conform


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample06() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 6: PROTOCOL CONFORMANCE")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Basic protocol conformance
    print("Test Case 1: Basic Protocol Conformance")
    let circle = Circle(radius: 5.0)
    circle.draw()
    circle.resize(by: 2.0)
    print("✅ All protocol requirements met\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Property requirements
    print("Test Case 2: Property Requirements")
    var product = Product(name: "iPhone")
    print(product.description)
    product.name = "iPad"
    print(product.description)
    print("✅ Mutable and computed properties work\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Default implementations
    print("Test Case 3: Default Protocol Implementations")
    let task = Task(title: "Review code")
    task.log()  // Uses default
    
    let importantTask = ImportantTask(title: "Fix critical bug")
    importantTask.log()  // Uses custom
    print("✅ Default and custom implementations\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Associated types
    print("Test Case 4: Associated Types")
    var intContainer = IntContainer()
    intContainer.add(1)
    intContainer.add(2)
    print("Int container: \(intContainer.items)")
    
    var stringContainer = StringContainer()
    stringContainer.add("Hello")
    stringContainer.add("World")
    print("String container: \(stringContainer.items)")
    print("✅ Generic containers with associated types\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 5: Self requirement
    print("Test Case 5: Self Requirement")
    let doc1 = Document(content: "Original")
    let doc2 = doc1.copy()
    print("Original: \(doc1.content)")
    print("Copy: \(doc2.content)")
    print("Are they the same instance? \(doc1 === doc2)")
    print("✅ Self returns correct type\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Protocol conformance requires:
    - Implement ALL required methods
    - Match signatures EXACTLY
    - Satisfy property requirements (get/set)
    - Meet access control requirements
 
 2. Property requirements:
    - { get } : Read-only, can be stored or computed
    - { get set } : Must be mutable stored property
    - Can provide more access than required
 
 3. Protocol extensions:
    - Provide default implementations
    - Add methods not in protocol
    - Constrain with 'where' clauses
    - Types can override defaults
 
 4. Associated types:
    - Placeholder for actual type
    - Like generics for protocols
    - Usually inferred from implementation
    - Use 'typealias' to specify explicitly
 
 5. Protocol constraints:
    - AnyObject: class-only protocol
    - Equatable, Hashable: value comparison
    - where clauses for additional constraints
 
 6. Self requirement:
    - Returns instance of conforming type
    - Useful for method chaining
    - Requires 'required' init for classes
 
 7. Protocol composition:
    - Combine protocols: func foo(x: A & B & C)
    - 'some Protocol' for opaque types
    - 'any Protocol' for existential types
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's Protocol-Oriented Programming?"
 A1: A paradigm that uses protocols and extensions to define behavior
     and provide default implementations, favoring composition over
     inheritance. Swift's standard library heavily uses POP.
 
 Q2: "What's the difference between protocol and abstract class?"
 A2: Protocols: No implementation (except extensions), multiple
     conformance, value and reference types. Abstract classes: Can have
     implementation, single inheritance, reference types only.
     Swift has no abstract classes.
 
 Q3: "What are associated types in protocols?"
 A3: Placeholders for types that are specified by conforming types.
     They make protocols generic. Example: Array conforms to Collection
     with Element as associated type.
 
 Q4: "What's the difference between 'some' and 'any' protocol?"
 A4: 'some Protocol' is opaque (compiler knows exact type, caller
     doesn't). 'any Protocol' is existential (type-erased, can hold
     any conforming type, but loses type identity).
 
 Q5: "Can a struct conform to a class-only protocol?"
 A5: No. Protocols marked with 'AnyObject' or inheriting from class
     protocols can only be conformed to by classes.
 
 Q6: "What's the purpose of protocol extensions?"
 A6: Provide default implementations, add utility methods, constrain
     conformance, enable POP patterns, reduce boilerplate code.
*/


// 💡 ADVANCED: Protocol-Oriented Patterns
// ═══════════════════════════════════════════════════════════════════

// Pattern 1: Protocol composition
protocol Identifiable2 {
    var id: String { get }
}

protocol Timestamped {
    var timestamp: Date { get }
}

// Require both protocols
func process(item: Identifiable2 & Timestamped) {
    print("Processing \(item.id) from \(item.timestamp)")
}


// Pattern 2: Conditional conformance
protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Array: Summable where Element: Summable {
    static func +(lhs: Array<Element>, rhs: Array<Element>) -> Array<Element> {
        return lhs + rhs
    }
}


// Pattern 3: Protocol inheritance
protocol Animal {
    var name: String { get }
}

protocol Pet: Animal {  // Inherits from Animal
    var owner: String { get }
}

struct Dog: Pet {
    var name: String
    var owner: String
    // Must implement both name and owner
}


// Pattern 4: Phantom types with protocols
protocol DataState { }
struct Empty: DataState { }
struct Loaded: DataState { }

struct DataContainer<State: DataState> {
    // Type-safe state machine using phantom types
}


// Pattern 5: Type erasure
protocol Fetchable {
    associatedtype Item
    func fetch() -> Item
}

struct AnyFetchable<T>: Fetchable {
    private let _fetch: () -> T
    
    init<F: Fetchable>(_ fetchable: F) where F.Item == T {
        self._fetch = fetchable.fetch
    }
    
    func fetch() -> T {
        return _fetch()
    }
}


// Uncomment to run:
// runExample06()
