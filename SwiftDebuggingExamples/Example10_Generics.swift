// =============================================================================
// EXAMPLE 10: Generic Constraints Bug
// Topic: Missing type constraints, incorrect generic usage
// Difficulty: Advanced
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

// BUG 1: Using == on a generic type without Equatable constraint
func findIndex<T>(of value: T, in array: [T]) -> Int? {
    for (index, element) in array.enumerated() {
        if element == value {  // ERROR: Binary operator '==' cannot be applied to two 'T' operands
            return index
        }
    }
    return nil
}


// BUG 2: Trying to sort without Comparable constraint
func sortedArray<T>(_ array: [T]) -> [T] {
    return array.sorted()  // ERROR: Argument type 'T' does not conform to 'Comparable'
}


// BUG 3: Using a protocol as a concrete type when it has associated types
protocol Container {
    associatedtype Item
    var items: [Item] { get }
    mutating func add(_ item: Item)
}

// ERROR: Protocol 'Container' can only be used as a generic constraint
// because it has Self or associated type requirements
func printContainerItems(container: Container) {  // This does NOT compile
    for item in container.items {
        print(item)
    }
}

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: Generic type T has no constraints by default. You cannot use == on
//         two T values unless T conforms to Equatable.
//
// Bug 2: Similarly, you cannot sort T values unless T conforms to Comparable.
//
// Bug 3: Protocols with associated types (PATs) cannot be used as concrete
//         types directly. They can only be used as generic constraints.
//         This is because the compiler needs to know the specific associated
//         type at compile time.
//

// =============================================================================
// FIXED CODE
// =============================================================================

// --- Fix 1: Add Equatable constraint ---

func findIndex<T: Equatable>(of value: T, in array: [T]) -> Int? {
    for (index, element) in array.enumerated() {
        if element == value {  // FIX: Now works because T is Equatable
            return index
        }
    }
    return nil
}

// Even better: Use the built-in method
func findIndexBuiltIn<T: Equatable>(of value: T, in array: [T]) -> Int? {
    return array.firstIndex(of: value)
}

// --- Fix 2: Add Comparable constraint ---

func sortedArray<T: Comparable>(_ array: [T]) -> [T] {
    return array.sorted()  // FIX: Now works because T is Comparable
}

// --- Fix 3: Use generics with protocol constraints instead ---

protocol Container {
    associatedtype Item
    var items: [Item] { get set }
    mutating func add(_ item: Item)
}

// FIX: Use a generic function with a type constraint
func printContainerItems<C: Container>(container: C) {
    for item in container.items {
        print("  \(item)")
    }
}

// Or in Swift 5.7+, use 'some' keyword:
// func printContainerItems(container: some Container) { ... }

// Implement a concrete container
struct NumberContainer: Container {
    var items: [Int] = []

    mutating func add(_ item: Int) {
        items.append(item)
    }
}

struct StringContainer: Container {
    var items: [String] = []

    mutating func add(_ item: String) {
        items.append(item)
    }
}

// --- Test all fixes ---
print("=== Fix 1: Equatable constraint ===")
let names = ["Alice", "Bob", "Charlie", "Diana"]
if let index = findIndex(of: "Charlie", in: names) {
    print("Found 'Charlie' at index \(index)")  // Found 'Charlie' at index 2
} else {
    print("Not found")
}

let numbers = [10, 20, 30, 40, 50]
if let index = findIndex(of: 99, in: numbers) {
    print("Found 99 at index \(index)")
} else {
    print("99 not found in array")  // 99 not found in array
}

print("\n=== Fix 2: Comparable constraint ===")
let unsorted = [5, 2, 8, 1, 9, 3]
print("Sorted: \(sortedArray(unsorted))")  // [1, 2, 3, 5, 8, 9]

let words = ["banana", "apple", "cherry"]
print("Sorted: \(sortedArray(words))")  // ["apple", "banana", "cherry"]

print("\n=== Fix 3: Generic function with protocol constraint ===")
var numContainer = NumberContainer()
numContainer.add(42)
numContainer.add(17)
numContainer.add(99)
print("NumberContainer:")
printContainerItems(container: numContainer)

var strContainer = StringContainer()
strContainer.add("Hello")
strContainer.add("World")
print("StringContainer:")
printContainerItems(container: strContainer)

// =============================================================================
// BONUS: Writing a generic Stack with multiple constraints
// =============================================================================

struct Stack<Element> {
    private var storage: [Element] = []

    var isEmpty: Bool { storage.isEmpty }
    var count: Int { storage.count }
    var top: Element? { storage.last }

    mutating func push(_ element: Element) {
        storage.append(element)
    }

    mutating func pop() -> Element? {
        return storage.popLast()
    }
}

// Extend only when Element is Equatable
extension Stack where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        return storage.contains(element)
    }
}

// Extend only when Element is Comparable
extension Stack where Element: Comparable {
    func sorted() -> [Element] {
        return storage.sorted()
    }

    func min() -> Element? {
        return storage.min()
    }

    func max() -> Element? {
        return storage.max()
    }
}

// Extend only when Element is CustomStringConvertible
extension Stack: CustomStringConvertible where Element: CustomStringConvertible {
    var description: String {
        let items = storage.map { $0.description }.joined(separator: ", ")
        return "Stack[\(items)]"
    }
}

print("\n=== Bonus: Generic Stack ===")
var intStack = Stack<Int>()
intStack.push(3)
intStack.push(1)
intStack.push(4)
intStack.push(1)
intStack.push(5)

print("Stack: \(intStack)")           // Stack[3, 1, 4, 1, 5]
print("Contains 4: \(intStack.contains(4))")  // true
print("Min: \(intStack.min()!)")       // 1
print("Max: \(intStack.max()!)")       // 5
print("Sorted: \(intStack.sorted())")  // [1, 1, 3, 4, 5]

// =============================================================================
// BONUS: Opaque types (some) and type erasure (any) — Swift 5.7+
// =============================================================================
//
//  // 'some' = Opaque type: caller doesn't know the specific type,
//  //          but the compiler does (used for return types)
//  func makeContainer() -> some Container {
//      return NumberContainer()
//  }
//
//  // 'any' = Existential type: used to store any conforming type
//  func processContainer(_ container: any Container) {
//      // Can work with any Container, but with some limitations
//  }
//
//  // Difference:
//  //   'some Container' = one specific (hidden) concrete type
//  //   'any Container'  = could be ANY type conforming to Container
//

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Generic types have NO capabilities by default. You must add constraints
// (like Equatable, Comparable, Hashable) to use specific operations.
//
// In interviews, Apple engineers look for:
//   1. Understanding generic syntax: <T: Protocol>
//   2. Knowing common constraints: Equatable, Comparable, Hashable, Codable
//   3. Conditional conformance (extension Stack where Element: Equatable)
//   4. Associated type protocols and why they can't be used as concrete types
//   5. Understanding 'some' (opaque) vs 'any' (existential) types
//   6. Writing reusable, type-safe code with generics
//
// Common interview question:
//   "Why can't you use a protocol with an associated type as a variable type?"
//   Answer: The compiler needs to know the exact associated type at compile time
//   to allocate memory and generate code. Protocols with associated types are
//   "incomplete" types — they're a blueprint that only makes sense when a
//   specific concrete type fills in the associated type.
// =============================================================================
