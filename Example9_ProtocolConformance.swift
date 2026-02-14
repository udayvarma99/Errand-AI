/*
 ============================================
 EXAMPLE 9: PROTOCOL CONFORMANCE ISSUES
 ============================================
 
 Common Issue: Incomplete protocol implementation and type mismatches
 Apple Interview Focus: Protocols, POP, associated types, generics
 */

import Foundation

// Define some protocols for examples
protocol Drawable {
    func draw()
    var color: String { get set }
    var position: (x: Int, y: Int) { get }
}

protocol Identifiable {
    var id: String { get }
}

protocol DataSource {
    associatedtype Item
    func fetchItems() -> [Item]
    func item(at index: Int) -> Item?
}

// ❌ BUGGY CODE - Protocol Conformance Issues!

// 🐛 BUG 1: Missing required protocol methods
class BuggyCircle: Drawable {
    var color: String = "red"
    var position: (x: Int, y: Int) = (0, 0)
    
    // ❌ Missing draw() method!
    // This will cause a compile error
}

// 🐛 BUG 2: Wrong property mutability
class BuggySquare: Drawable {
    var color: String = "blue"
    // ❌ BUG: position is let, but protocol requires var
    // let position: (x: Int, y: Int) = (0, 0)  // Compile error!
    
    var position: (x: Int, y: Int) = (0, 0)
    
    func draw() {
        print("Drawing square")
    }
}

// 🐛 BUG 3: Wrong associated type usage
class BuggyStringDataSource: DataSource {
    typealias Item = String
    
    func fetchItems() -> [String] {
        return ["A", "B", "C"]
    }
    
    func item(at index: Int) -> String? {
        let items = fetchItems()
        return index < items.count ? items[index] : nil
    }
}

// Using it incorrectly:
func processBuggyDataSource<T: DataSource>(_ source: T) {
    let items = source.fetchItems()
    // 🐛 BUG: Can't assume Item type without constraints
    // for item in items {
    //     print(item.uppercased())  // Compile error if Item isn't String!
    // }
}

// 🐛 BUG 4: Protocol with Self requirement issues
protocol Copyable {
    func copy() -> Self
}

class BuggyDocument: Copyable {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func copy() -> BuggyDocument {
        // ❌ BUG: Returns BuggyDocument, not Self
        // Subclasses will have issues!
        return BuggyDocument(title: title)
    }
}

class BuggyReport: BuggyDocument {
    var content: String
    
    init(title: String, content: String) {
        self.content = content
        super.init(title: title)
    }
    
    // copy() inherited from parent returns BuggyDocument, not BuggyReport!
}

// 🐛 BUG 5: Protocol composition confusion
protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

// Trying to use protocols incorrectly
func printInfoBuggy(_ object: Named) {
    print("Name: \(object.name)")
    // 🐛 BUG: Can't access age - object is only Named!
    // print("Age: \(object.age)")  // Compile error!
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Read compiler errors carefully - they tell you what's missing
 2. Cmd+Click on protocol to see requirements
 3. Use Xcode's "Add Missing Protocol Requirements" fix-it
 4. Check protocol conformance with: MyType.self is ProtocolType
 5. Use protocol extensions to provide default implementations
 6. Test with different concrete types
 */

// ✅ FIXED CODE - Proper Protocol Conformance

// FIX 1: Implement all required methods
class FixedCircle: Drawable {
    var color: String = "red"
    var position: (x: Int, y: Int) = (0, 0)
    
    // ✅ Implement required method
    func draw() {
        print("Drawing circle at (\(position.x), \(position.y)) in \(color)")
    }
}

// FIX 2: Correct property mutability
class FixedSquare: Drawable {
    var color: String = "blue"
    var position: (x: Int, y: Int) = (0, 0)  // ✅ var as required
    
    func draw() {
        print("Drawing square")
    }
}

// FIX 3: Proper generic constraints
protocol TypedDataSource {
    associatedtype Item
    func fetchItems() -> [Item]
    func item(at index: Int) -> Item?
}

class StringDataSource: TypedDataSource {
    typealias Item = String
    
    func fetchItems() -> [String] {
        return ["A", "B", "C"]
    }
    
    func item(at index: Int) -> String? {
        let items = fetchItems()
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
}

// ✅ Properly constrained function
func processDataSource<T: TypedDataSource>(_ source: T) where T.Item == String {
    let items = source.fetchItems()
    for item in items {
        print(item.uppercased())  // ✅ Now safe!
    }
}

// Alternative: Use Any but cast safely
func processAnyDataSource<T: TypedDataSource>(_ source: T) {
    let items = source.fetchItems()
    for item in items {
        if let string = item as? String {
            print(string.uppercased())
        } else {
            print("Item: \(item)")
        }
    }
}

// FIX 4: Proper Self usage
protocol ProperCopyable {
    func copy() -> Self
}

class FixedDocument: ProperCopyable {
    var title: String
    
    required init(title: String) {
        self.title = title
    }
    
    // ✅ Use 'required' init for subclassing
    func copy() -> Self {
        return type(of: self).init(title: title)
    }
}

class FixedReport: FixedDocument {
    var content: String
    
    required init(title: String) {
        self.content = ""
        super.init(title: title)
    }
    
    init(title: String, content: String) {
        self.content = content
        super.init(title: title)
    }
}

// FIX 5: Protocol composition
func printInfo(_ object: Named & Aged) {
    print("Name: \(object.name)")
    print("Age: \(object.age)")  // ✅ Now accessible!
}

// Or use a combined protocol
protocol Person: Named, Aged {}

class Employee: Person {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

// Advanced: Protocol with default implementation
protocol Loggable {
    func log(_ message: String)
}

extension Loggable {
    // Default implementation
    func log(_ message: String) {
        print("[\(type(of: self))] \(message)")
    }
}

class Logger: Loggable {
    // Inherits default implementation
    // Or can override:
    func log(_ message: String) {
        print("🔍 \(message)")
    }
}

// Protocol-oriented programming example
protocol Vehicle {
    var speed: Double { get set }
    var color: String { get }
    func accelerate(by amount: Double)
}

extension Vehicle {
    // Default implementation
    func accelerate(by amount: Double) {
        speed += amount
        print("Accelerating to \(speed) km/h")
    }
    
    // Additional functionality
    func describe() -> String {
        return "A \(color) vehicle traveling at \(speed) km/h"
    }
}

struct Car: Vehicle {
    var speed: Double = 0
    var color: String
    
    // Can use default accelerate() or override
}

struct Bicycle: Vehicle {
    var speed: Double = 0
    var color: String
    
    // Custom implementation
    func accelerate(by amount: Double) {
        speed += amount
        print("Pedaling faster! Speed: \(speed) km/h")
    }
}

// Conditional conformance
protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Summable {}
extension Double: Summable {}
extension String: Summable {}

extension Array: Summable where Element: Summable {
    static func +(lhs: Array<Element>, rhs: Array<Element>) -> Array<Element> {
        guard lhs.count == rhs.count else { return lhs }
        return zip(lhs, rhs).map { $0 + $1 }
    }
}

// Protocol inheritance
protocol Serializable {
    func serialize() -> Data?
}

protocol PersistableObject: Serializable, Identifiable {
    func save() -> Bool
    func load() -> Bool
}

class DatabaseObject: PersistableObject {
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    func serialize() -> Data? {
        return try? JSONEncoder().encode(["id": id])
    }
    
    func save() -> Bool {
        guard let data = serialize() else { return false }
        print("Saving \(data.count) bytes")
        return true
    }
    
    func load() -> Bool {
        print("Loading object \(id)")
        return true
    }
}

// Generic protocol pattern
protocol Container {
    associatedtype Item
    var count: Int { get }
    mutating func append(_ item: Item)
    subscript(index: Int) -> Item { get }
}

struct Stack<Element>: Container {
    private var items: [Element] = []
    
    var count: Int {
        return items.count
    }
    
    mutating func append(_ item: Element) {
        items.append(item)
    }
    
    subscript(index: Int) -> Element {
        return items[index]
    }
    
    mutating func push(_ item: Element) {
        append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
}

// Type-erased wrappers
class AnyDataSource<T> {
    private let _fetchItems: () -> [T]
    private let _item: (Int) -> T?
    
    init<Source: TypedDataSource>(_ source: Source) where Source.Item == T {
        _fetchItems = source.fetchItems
        _item = source.item
    }
    
    func fetchItems() -> [T] {
        return _fetchItems()
    }
    
    func item(at index: Int) -> T? {
        return _item(index)
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== PROTOCOL CONFORMANCE EXAMPLES ===\n")
    
    print("--- Basic protocol conformance ---")
    let circle = FixedCircle()
    circle.draw()
    
    let square = FixedSquare()
    square.position = (10, 20)
    square.draw()
    
    print("\n--- Data source with generics ---")
    let stringSource = StringDataSource()
    processDataSource(stringSource)
    
    print("\n--- Self-returning protocol ---")
    let doc = FixedDocument(title: "Original")
    let docCopy = doc.copy()
    print("Original: \(doc.title)")
    print("Copy: \(docCopy.title)")
    
    let report = FixedReport(title: "Report", content: "Content")
    let reportCopy = report.copy()
    print("Report type: \(type(of: reportCopy))")
    
    print("\n--- Protocol composition ---")
    let employee = Employee(name: "Alice", age: 30)
    printInfo(employee)
    
    print("\n--- Default protocol implementation ---")
    let logger = Logger()
    logger.log("Testing logging")
    
    print("\n--- Protocol-oriented programming ---")
    var car = Car(color: "red")
    car.accelerate(by: 50)
    print(car.describe())
    
    var bike = Bicycle(color: "blue")
    bike.accelerate(by: 20)
    print(bike.describe())
    
    print("\n--- Conditional conformance ---")
    let arr1 = [1, 2, 3]
    let arr2 = [4, 5, 6]
    let sum = arr1 + arr2
    print("Array sum: \(sum)")
    
    print("\n--- Generic container ---")
    var stack = Stack<String>()
    stack.push("First")
    stack.push("Second")
    stack.push("Third")
    print("Stack count: \(stack.count)")
    if let top = stack.pop() {
        print("Popped: \(top)")
    }
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. Protocols define a blueprint of methods/properties
 2. Classes/structs/enums can conform to multiple protocols
 3. Use protocol extensions for default implementations
 4. Associated types make protocols generic
 5. Protocol composition: func foo(_ obj: A & B & C)
 6. Self requirement needs proper init handling
 7. Protocols are types - you can use them as parameters
 
 🎯 PROTOCOL PATTERNS:
 
 // Basic protocol
 protocol MyProtocol {
     var property: String { get set }
     func method()
 }
 
 // Protocol with associated type
 protocol Container {
     associatedtype Item
     func add(_ item: Item)
 }
 
 // Protocol composition
 func process(_ obj: Codable & Identifiable) { }
 
 // Protocol inheritance
 protocol MyProtocol: OtherProtocol { }
 
 // Default implementation
 extension MyProtocol {
     func method() {
         // Default implementation
     }
 }
 
 ⚠️  COMMON PROTOCOL MISTAKES:
 
 1. Missing required methods/properties
 2. Wrong property mutability (get vs get set)
 3. Not handling Self requirements properly
 4. Forgetting associated type constraints
 5. Trying to instantiate a protocol
 6. Not using protocol composition when needed
 
 💡 PROTOCOL-ORIENTED PROGRAMMING (POP):
 
 - Favor composition over inheritance
 - Use protocol extensions for default behavior
 - Value types (struct) can conform to protocols
 - More flexible than class inheritance
 - Retroactive modeling (extend existing types)
 
 🛠️  PROTOCOL ADVANCED FEATURES:
 
 // Class-only protocol
 protocol MyDelegate: AnyObject {
     func didUpdate()
 }
 
 // Optional requirements (Objective-C only)
 @objc protocol DataSource {
     @objc optional func extra() -> String
 }
 
 // Generic constraints
 func process<T: Collection>(_ items: T) where T.Element == String {
     // ...
 }
 
 // Conditional conformance
 extension Array: Equatable where Element: Equatable { }
 
 ⚡ INTERVIEW TOPICS:
 
 - Protocol vs Abstract Class
 - Value types vs Reference types with protocols
 - Protocol witness tables
 - Existential types
 - Type erasure (AnySequence, AnyIterator)
 - Associated types vs generics
 - Protocol-oriented architecture
 
 🎓 ADVANCED CONCEPTS:
 
 // Opaque return types (Swift 5.1+)
 func makeCollection() -> some Collection {
     return [1, 2, 3]
 }
 
 // Primary associated types (Swift 5.7+)
 protocol Collection<Element> {
     associatedtype Element
 }
 
 // Same-type requirements
 func process<C1, C2>(_ c1: C1, _ c2: C2) 
     where C1: Collection, C2: Collection,
           C1.Element == C2.Element { }
 
 🏗️  DESIGN PATTERNS WITH PROTOCOLS:
 
 1. Delegation: weak var delegate: MyDelegate?
 2. Strategy: protocol Strategy { func execute() }
 3. Factory: protocol Factory { func create() -> Product }
 4. Observer: protocol Observer { func update() }
 5. Adapter: Make old API conform to new protocol
 */

// Run demonstrations
demonstrateFix()
