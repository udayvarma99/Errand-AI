/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 5: PROTOCOL CONFORMANCE ERROR
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Protocols, Associated Types, and Generics
 Common In: 70% of Swift interviews (Protocol-Oriented Programming)
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - INCOMPLETE PROTOCOL CONFORMANCE
// ═══════════════════════════════════════════════════════════════

protocol Drawable {
    func draw()
    func getColor() -> String
    var isVisible: Bool { get set }
}

// 🐛 BUG: Missing required protocol methods/properties
// Compiler error: "Type 'CircleBuggy' does not conform to protocol 'Drawable'"
struct CircleBuggy: Drawable {
    var radius: Double
    // Missing: draw(), getColor(), isVisible
    // This won't compile!
}


// ❌ BUGGY CODE - Protocol with Associated Type Issues
// ═══════════════════════════════════════════════════════════════

protocol Container {
    associatedtype Item
    var items: [Item] { get set }
    func addItem(_ item: Item)
}

// 🐛 BUG: Associated type not specified correctly
struct StringContainerBuggy: Container {
    var items: [String] = []
    
    // 🐛 BUG: Using wrong type for parameter
    func addItem(_ item: Int) {  // Should be String!
        // Compiler error: Type mismatch
    }
}


// ❌ BUGGY CODE - Protocol Extension Confusion
// ═══════════════════════════════════════════════════════════════

protocol Animal {
    func makeSound() -> String
}

extension Animal {
    // Default implementation
    func makeSound() -> String {
        return "Some sound"
    }
}

struct DogBuggy: Animal {
    // 🐛 BUG: Trying to override, but protocols don't work like inheritance
    // This won't override the default implementation correctly
    func makeSound() -> String {
        return "Woof"  // This actually DOES work, but confusion about dispatch
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. INCOMPLETE CONFORMANCE:
    - Must implement ALL required methods and properties
    - Compiler won't let code compile until conformance is complete
    - Easy to miss requirements in large protocols
 
 2. ASSOCIATED TYPE MISMATCH:
    - Associated types must match across all protocol requirements
    - Can't use different types for same associated type
    - Swift infers associated type from implementation
 
 3. PROTOCOL VS CLASS INHERITANCE:
    - Protocol extensions provide defaults, not overrides
    - Static vs dynamic dispatch differences
    - Can cause confusion with method resolution
 
 4. GET vs GET/SET:
    - { get } can be satisfied by var or let
    - { get set } requires var
    - Common source of compiler errors
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Complete Protocol Conformance
// ═══════════════════════════════════════════════════════════════

struct Circle: Drawable {
    var radius: Double
    var isVisible: Bool  // ✅ Required property
    
    // ✅ Implement all required methods
    func draw() {
        if isVisible {
            print("Drawing circle with radius \(radius)")
        }
    }
    
    func getColor() -> String {
        return "Blue"
    }
}

struct Square: Drawable {
    var side: Double
    var isVisible: Bool
    
    func draw() {
        if isVisible {
            print("Drawing square with side \(side)")
        }
    }
    
    func getColor() -> String {
        return "Red"
    }
}


// ✅ FIXED CODE - SOLUTION 2: Associated Types Done Right
// ═══════════════════════════════════════════════════════════════

struct StringContainer: Container {
    typealias Item = String  // ✅ Explicit type (optional, Swift infers it)
    var items: [String] = []
    
    // ✅ Correct type for associated type
    mutating func addItem(_ item: String) {
        items.append(item)
    }
}

struct IntContainer: Container {
    // ✅ Swift infers Item = Int from implementation
    var items: [Int] = []
    
    mutating func addItem(_ item: Int) {
        items.append(item)
    }
}

// ✅ Generic container
struct GenericContainer<T>: Container {
    var items: [T] = []
    
    mutating func addItem(_ item: T) {
        items.append(item)
    }
}


// ✅ FIXED CODE - SOLUTION 3: Protocol Extensions with Customization
// ═══════════════════════════════════════════════════════════════

protocol AnimalFixed {
    var name: String { get }
    func makeSound() -> String
}

extension AnimalFixed {
    // ✅ Default implementation
    func makeSound() -> String {
        return "\(name) makes a sound"
    }
    
    // ✅ Additional method not in protocol
    func describe() -> String {
        return "\(name) says: \(makeSound())"
    }
}

struct Dog: AnimalFixed {
    let name: String
    
    // ✅ Override default implementation
    func makeSound() -> String {
        return "Woof!"
    }
}

struct Cat: AnimalFixed {
    let name: String
    
    // ✅ Override default implementation
    func makeSound() -> String {
        return "Meow!"
    }
}

struct GenericAnimal: AnimalFixed {
    let name: String
    // ✅ Uses default implementation (no makeSound defined)
}


// ✅ ADVANCED: Protocol Composition
// ═══════════════════════════════════════════════════════════════

protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

// ✅ Conform to multiple protocols
struct Person: Named, Aged {
    let name: String
    let age: Int
}

// ✅ Use protocol composition as type
func celebrate(entity: Named & Aged) {
    print("\(entity.name) is \(entity.age) years old!")
}


// ✅ ADVANCED: Protocol with Self Requirements
// ═══════════════════════════════════════════════════════════════

protocol Equatable {
    func isEqual(to other: Self) -> Bool
}

struct Point3D: Equatable {
    let x: Double
    let y: Double
    let z: Double
    
    // ✅ Self refers to Point3D
    func isEqual(to other: Point3D) -> Bool {
        return x == other.x && y == other.y && z == other.z
    }
}


// ✅ ADVANCED: Protocol Inheritance
// ═══════════════════════════════════════════════════════════════

protocol Identifiable {
    var id: String { get }
}

protocol Persistable: Identifiable {
    func save()
    func load()
}

struct User: Persistable {
    let id: String
    var name: String
    
    // ✅ Must implement Identifiable (inherited)
    // id already implemented above
    
    // ✅ Must implement Persistable methods
    func save() {
        print("Saving user \(id)")
    }
    
    func load() {
        print("Loading user \(id)")
    }
}


// ✅ REAL-WORLD EXAMPLE: Repository Pattern
// ═══════════════════════════════════════════════════════════════

protocol Repository {
    associatedtype Entity
    
    func fetchAll() -> [Entity]
    func fetch(by id: String) -> Entity?
    func save(_ entity: Entity)
    func delete(_ entity: Entity)
}

struct Book {
    let id: String
    let title: String
    let author: String
}

class BookRepository: Repository {
    typealias Entity = Book
    
    private var books: [Book] = []
    
    func fetchAll() -> [Book] {
        return books
    }
    
    func fetch(by id: String) -> Book? {
        return books.first { $0.id == id }
    }
    
    func save(_ entity: Book) {
        if let index = books.firstIndex(where: { $0.id == entity.id }) {
            books[index] = entity
        } else {
            books.append(entity)
        }
    }
    
    func delete(_ entity: Book) {
        books.removeAll { $0.id == entity.id }
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. PROTOCOL CONFORMANCE:
    - Must implement ALL required members
    - Compiler enforces complete conformance
    - Can use extensions to organize conformance
 
 2. ASSOCIATED TYPES:
    - Like generics for protocols
    - Swift infers from implementation
    - Can specify explicitly with typealias
    - All uses must match the same type
 
 3. PROTOCOL EXTENSIONS:
    - Provide default implementations
    - Add methods not in protocol
    - Enable protocol-oriented programming
    - Can have constraints (where clauses)
 
 4. GET vs GET/SET:
    - { get }: read-only, can use let or var
    - { get set }: read-write, must use var
    - Can provide more access than required
 
 5. PROTOCOL COMPOSITION:
    - Combine multiple protocols with &
    - Type must conform to all protocols
    - Great for flexible function parameters
 
 6. WHEN TO USE PROTOCOLS:
    - Define capabilities (Drawable, Codable)
    - Enable polymorphism without inheritance
    - Support dependency injection
    - Protocol-oriented programming (POP)
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "This type doesn't fully conform to the protocol - we're missing the 
    required methods and properties. I'll implement them."
 
 2. "The associated type needs to match across all protocol requirements. 
    Swift will infer it from our implementation."
 
 3. "I'd use a protocol extension to provide a default implementation, which 
    types can override if needed."
 
 4. "This property is marked { get set }, so it must be a var, not a let."
 
 5. "Protocol-oriented programming is preferred in Swift over class inheritance 
    because it works with value types and supports composition."
 
 BONUS POINTS:
 ✅ Discuss POP (Protocol-Oriented Programming) vs OOP
 ✅ Mention WWDC 2015 "Protocol-Oriented Programming in Swift"
 ✅ Know about Codable, Equatable, Hashable protocols
 ✅ Understand protocol witness tables (advanced)
 ✅ Discuss protocol extensions with where clauses
 
 EXAMPLE WITH WHERE CLAUSE:
 ```swift
 extension Collection where Element: Equatable {
     func countOf(_ element: Element) -> Int {
         return filter { $0 == element }.count
     }
 }
 ```
 
 RED FLAGS:
 ❌ "Protocols are just like interfaces in other languages" (oversimplification)
 ❌ Not knowing about associated types
 ❌ Confusing protocol extensions with inheritance
 ❌ Saying "I prefer classes over protocols"
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What's the difference between a protocol and an abstract class?"
 A: "Swift doesn't have abstract classes. Protocols are more flexible - they 
     work with structs, enums, and classes, and support composition."
 
 Q: "When would you use a protocol vs inheritance?"
 A: "Protocols for capabilities and behavior, inheritance for 'is-a' 
     relationships. Swift favors composition over inheritance."
 
 Q: "What are some common Swift protocols?"
 A: "Codable for JSON, Equatable for comparison, Hashable for dictionaries/sets, 
     Identifiable for SwiftUI, CustomStringConvertible for description."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample5() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 5: PROTOCOL CONFORMANCE")
    print("═══════════════════════════════════════════════════════\n")
    
    print("✅ DRAWABLE PROTOCOL:")
    let shapes: [Drawable] = [
        Circle(radius: 5.0, isVisible: true),
        Square(side: 10.0, isVisible: true)
    ]
    
    for shape in shapes {
        shape.draw()
        print("Color: \(shape.getColor())")
    }
    print()
    
    print("✅ ASSOCIATED TYPES:")
    var stringContainer = StringContainer()
    stringContainer.addItem("Hello")
    stringContainer.addItem("World")
    print("String container: \(stringContainer.items)")
    
    var intContainer = IntContainer()
    intContainer.addItem(1)
    intContainer.addItem(2)
    intContainer.addItem(3)
    print("Int container: \(intContainer.items)")
    print()
    
    print("✅ PROTOCOL EXTENSIONS:")
    let dog = Dog(name: "Buddy")
    let cat = Cat(name: "Whiskers")
    let generic = GenericAnimal(name: "Unknown")
    
    print(dog.describe())
    print(cat.describe())
    print(generic.describe())  // Uses default implementation
    print()
    
    print("✅ PROTOCOL COMPOSITION:")
    let person = Person(name: "Alice", age: 30)
    celebrate(entity: person)
    print()
    
    print("✅ REPOSITORY PATTERN:")
    let repo = BookRepository()
    repo.save(Book(id: "1", title: "Swift Guide", author: "Apple"))
    repo.save(Book(id: "2", title: "iOS Development", author: "Developer"))
    
    print("All books:")
    for book in repo.fetchAll() {
        print("- \(book.title) by \(book.author)")
    }
    
    if let book = repo.fetch(by: "1") {
        print("\nFetched: \(book.title)")
    }
    print()
}

// Uncomment to run:
// runExample5()
