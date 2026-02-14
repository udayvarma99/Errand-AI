// ============================================================================
// EXAMPLE 5: Protocol Conformance Issues
// Difficulty: Intermediate
// Topic: Protocol requirements, default implementations, conformance pitfalls
// ============================================================================

// ============================================================================
// WHAT ARE PROTOCOLS?
// ============================================================================
// A protocol defines a blueprint of methods, properties, and requirements
// that a type must implement. Think of it as a contract:
//
//   "If you want to be a Vehicle, you MUST have a `numberOfWheels` property
//    and a `drive()` method."
//
// Protocols are fundamental to Swift and iOS development. Apple uses them
// everywhere: Codable, Hashable, Equatable, Delegate patterns, etc.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Missing required protocol method
protocol Animal {
    var name: String { get }
    var sound: String { get }
    func describe() -> String
}

struct Cat: Animal {
    var name: String
    // Missing `sound` property!        <-- BUG: Won't compile
    // Missing `describe()` method!     <-- BUG: Won't compile
}


// Bug 2: Protocol method declared but not in protocol — not called polymorphically
protocol Drawable {
    func draw()
}

extension Drawable {
    func draw() {
        print("Default drawing")
    }

    func erase() {  // This is NOT a protocol requirement!
        print("Default erasing")
    }
}

class Circle: Drawable {
    func draw() {
        print("Drawing a circle")
    }

    func erase() {
        print("Erasing a circle")
    }
}

let shape: Drawable = Circle()
shape.draw()   // "Drawing a circle"  — correct, uses dynamic dispatch
shape.erase()  // "Default erasing"   — BUG! Uses the extension, not Circle's!


// Bug 3: Mutating method in protocol not marked as mutating
protocol Togglable {
    func toggle()  // Missing `mutating` keyword!
}

struct LightSwitch: Togglable {
    var isOn: Bool = false

    mutating func toggle() {  // Won't compile! Protocol doesn't say `mutating`
        isOn = !isOn
    }
}


// Bug 4: Equatable conformance that gives wrong results
struct Point: Equatable {
    var x: Double
    var y: Double
    var label: String

    // Custom Equatable that ignores label — but developer forgot this
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x  // BUG: Forgot to compare y!
    }
}

let p1 = Point(x: 1, y: 2, label: "A")
let p2 = Point(x: 1, y: 99, label: "B")
print(p1 == p2)  // true — but they have different y values! BUG!

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: When a type conforms to a protocol, it MUST implement ALL required
//         properties and methods. Missing any = compile error.
//
// Bug 2: Methods defined in a protocol extension (but NOT in the protocol
//         itself) use STATIC dispatch. The compiler decides at compile time
//         which version to call based on the variable's TYPE, not the actual
//         object. Since `shape` is typed as `Drawable`, it calls the extension.
//
// Bug 3: Structs need `mutating` to modify their properties. If the protocol
//         method might be used by structs, it must be marked `mutating`.
//
// Bug 4: Custom `==` only compares x, not y. Two points with same x but
//         different y are incorrectly considered equal.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Implement ALL required protocol properties and methods
protocol Animal {
    var name: String { get }
    var sound: String { get }
    func describe() -> String
}

struct Cat: Animal {
    var name: String
    var sound: String = "Meow"  // Now provided!

    func describe() -> String {  // Now implemented!
        return "\(name) says \(sound)"
    }
}

let cat = Cat(name: "Whiskers")
print(cat.describe())  // "Whiskers says Meow"


// Fix 2: Add the method to the protocol definition for dynamic dispatch
protocol Drawable {
    func draw()
    func erase()  // Now it's a protocol REQUIREMENT — uses dynamic dispatch!
}

extension Drawable {
    func draw() {
        print("Default drawing")
    }

    func erase() {
        print("Default erasing")
    }
}

class Circle: Drawable {
    func draw() {
        print("Drawing a circle")
    }

    func erase() {
        print("Erasing a circle")
    }
}

let shape: Drawable = Circle()
shape.draw()   // "Drawing a circle"   — correct!
shape.erase()  // "Erasing a circle"   — NOW correct! Dynamic dispatch is used.


// Fix 3: Mark protocol method as `mutating`
protocol Togglable {
    mutating func toggle()  // `mutating` allows structs to modify self
}

struct LightSwitch: Togglable {
    var isOn: Bool = false

    mutating func toggle() {
        isOn = !isOn
    }
}

var light = LightSwitch()
print("Light is on: \(light.isOn)")  // false
light.toggle()
print("Light is on: \(light.isOn)")  // true

// Note: Classes don't need `mutating` — they can always modify properties.
class Fan: Togglable {
    var isOn: Bool = false

    func toggle() {  // No `mutating` needed for classes!
        isOn = !isOn
    }
}


// Fix 4: Implement Equatable correctly — compare ALL relevant fields
struct Point: Equatable {
    var x: Double
    var y: Double
    var label: String

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y  // Compare BOTH x and y
        // Intentionally NOT comparing label (labels are display-only)
    }
}

let p1 = Point(x: 1, y: 2, label: "A")
let p2 = Point(x: 1, y: 99, label: "B")
let p3 = Point(x: 1, y: 2, label: "C")

print(p1 == p2)  // false — different y values, correct!
print(p1 == p3)  // true  — same coordinates, label ignored as intended


// ============================================================================
// BONUS: Protocol-Oriented Programming (Apple's preferred approach)
// ============================================================================

// Instead of class inheritance, Swift prefers protocol composition:
protocol Identifiable {
    var id: String { get }
}

protocol Displayable {
    var displayName: String { get }
}

// A type can conform to multiple protocols (unlike single inheritance!)
struct User: Identifiable, Displayable {
    var id: String
    var displayName: String
}

// You can combine protocols as a type:
func showInfo(item: Identifiable & Displayable) {
    print("ID: \(item.id), Name: \(item.displayName)")
}

let user = User(id: "123", displayName: "Alice")
showInfo(item: user)  // "ID: 123, Name: Alice"


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "What's the difference between a protocol and an abstract class?"
//    Answer: Swift doesn't have abstract classes. Protocols can be adopted by
//    structs, enums, AND classes. A type can conform to multiple protocols
//    but can only inherit from one class.
//
// 2. "Explain static dispatch vs dynamic dispatch in protocols."
//    Answer: Methods declared in the protocol itself use dynamic dispatch
//    (the actual object's implementation is called). Methods only in the
//    extension use static dispatch (the declared type's implementation is called).
//
// 3. "What is Protocol-Oriented Programming?"
//    Answer: Apple's recommended approach in Swift. Instead of building deep
//    class hierarchies, define behavior in protocols with default extensions.
//    Types compose behavior by conforming to multiple protocols.
//
// 4. Know these built-in protocols: Equatable, Hashable, Comparable,
//    Codable (Encodable & Decodable), CustomStringConvertible, Identifiable.
// ============================================================================
