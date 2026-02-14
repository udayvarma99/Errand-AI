// Example 5: Protocol and Type Mismatches - FIXED VERSION
// Proper type checking and protocol usage prevents crashes

import Foundation

// FIX 1: Implement all protocol requirements
protocol DataSource {
    func numberOfItems() -> Int
    func item(at index: Int) -> String
    func refresh()
}

class TableDataSource: DataSource {
    func numberOfItems() -> Int {
        return 10
    }
    
    func item(at index: Int) -> String {
        return "Item \(index)"
    }
    
    func refresh() {  // ✅ Implemented all requirements
        print("Refreshing data...")
    }
}

// FIX 2: Safe type casting with conditional cast
func processAnyData(_ data: Any) {
    if let stringData = data as? String {
        print(stringData.uppercased())
    } else {
        print("Data is not a String")
    }
    
    if let arrayData = data as? [Int] {
        print("Array count: \(arrayData.count)")
    } else {
        print("Data is not an Int array")
    }
}

// Alternative: Pattern matching
func processAnyDataWithSwitch(_ data: Any) {
    switch data {
    case let string as String:
        print("String: \(string.uppercased())")
    case let array as [Int]:
        print("Array count: \(array.count)")
    case let number as Int:
        print("Number: \(number)")
    default:
        print("Unknown type")
    }
}

// FIX 3: Use type erasure for protocols with associated types
protocol Container {
    associatedtype Item
    func add(_ item: Item)
    func getAll() -> [Item]
}

class StringContainer: Container {
    typealias Item = String
    private var items: [String] = []
    
    func add(_ item: String) {
        items.append(item)
    }
    
    func getAll() -> [String] {
        return items
    }
}

// ✅ Type erasure wrapper
class AnyContainer<T> {
    private let _add: (T) -> Void
    private let _getAll: () -> [T]
    
    init<C: Container>(_ container: C) where C.Item == T {
        _add = container.add
        _getAll = container.getAll
    }
    
    func add(_ item: T) {
        _add(item)
    }
    
    func getAll() -> [T] {
        return _getAll()
    }
}

// Now we can use it
let stringContainer = StringContainer()
let anyContainer = AnyContainer(stringContainer)  // ✅ Works!

// Alternative: Use opaque types (Swift 5.1+)
func makeContainer() -> some Container {
    return StringContainer()
}

// FIX 4: Safe downcasting
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

func makeAnimalSound(_ animal: Animal) {
    // ✅ Check type before casting
    if let dog = animal as? Dog {
        dog.bark()
    } else if let cat = animal as? Cat {
        cat.meow()
    } else {
        print("Unknown animal")
    }
}

// Alternative: Use polymorphism
protocol SoundMaker {
    func makeSound()
}

extension Dog: SoundMaker {
    func makeSound() { bark() }
}

extension Cat: SoundMaker {
    func makeSound() { meow() }
}

func makeAnimalSoundPolymorphic(_ animal: SoundMaker) {
    animal.makeSound()  // ✅ No casting needed!
}

// FIX 5: Safe dictionary value extraction
func processUserData(_ data: [String: Any]) {
    guard let age = data["age"] as? Int else {
        print("Invalid age")
        return
    }
    
    guard let scores = data["scores"] as? [Int] else {
        print("Invalid scores")
        return
    }
    
    print("Age: \(age)")
    print("Scores: \(scores)")
}

// Alternative: Use Codable
struct UserData: Codable {
    let age: Int
    let scores: [Int]
}

func processUserDataCodable(from dict: [String: Any]) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict)
        let userData = try JSONDecoder().decode(UserData.self, from: jsonData)
        print("Age: \(userData.age)")
        print("Scores: \(userData.scores)")
    } catch {
        print("Failed to decode: \(error)")
    }
}

// FIX 6: Protocol composition
protocol Nameable {
    var name: String { get }
}

protocol Ageable {
    var age: Int { get }
}

struct Person: Nameable, Ageable {
    var name: String
    var age: Int
}

// ✅ Use protocol composition
func processEntity(_ entity: Nameable & Ageable) {
    print("\(entity.name) is \(entity.age) years old")
}

// Alternative: Check conformance
func processEntitySafe(_ entity: Nameable) {
    if let ageable = entity as? Ageable {
        print("\(entity.name) is \(ageable.age) years old")
    } else {
        print("\(entity.name)'s age is unknown")
    }
}

// FIX 7: Generic constraints
func printItems<T: CustomStringConvertible>(_ items: [T]) {
    for item in items {
        print(item.description)  // ✅ T conforms to CustomStringConvertible
    }
}

// Alternative: Where clause
func printItemsWhere<T>(_ items: [T]) where T: CustomStringConvertible {
    for item in items {
        print(item.description)
    }
}

// FIX 8: Struct vs Class protocols
protocol ViewProtocol {  // ✅ Not class-only
    func display()
}

struct ViewStruct: ViewProtocol {
    func display() {
        print("Struct view")
    }
}

// Or use class-only when needed
protocol ViewControllerProtocol: AnyObject {
    func display()
}

class ViewController: ViewControllerProtocol {
    func display() {
        print("ViewController")
    }
}

// FIX 9: Proper enum handling
enum Result {
    case success(String)
    case failure(Error)
}

func handleResult(_ result: Result) {
    switch result {
    case .success(let value):
        print("Success: \(value)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Alternative: Use if case
func handleResultIf(_ result: Result) {
    if case .success(let value) = result {
        print("Success: \(value)")
    }
    
    if case .failure(let error) = result {
        print("Error: \(error)")
    }
}

// FIX 10: Safe dictionary type casting
func processDictionary(_ dict: Any) {
    guard let typedDict = dict as? [String: Any] else {
        print("Not a dictionary")
        return
    }
    
    for (key, value) in typedDict {
        if let stringValue = value as? String {
            print("\(key): \(stringValue.uppercased())")
        } else {
            print("\(key): \(value)")
        }
    }
}

// Alternative: Type-specific processing
func processDictionarySafe(_ dict: Any) {
    guard let typedDict = dict as? [String: String] else {
        // Handle non-string values
        if let mixedDict = dict as? [String: Any] {
            for (key, value) in mixedDict {
                print("\(key): \(String(describing: value))")
            }
        }
        return
    }
    
    for (key, value) in typedDict {
        print("\(key): \(value.uppercased())")
    }
}

// BONUS: Type checking utilities
extension Any {
    func `is`<T>(_ type: T.Type) -> Bool {
        return self is T
    }
    
    func `as`<T>(_ type: T.Type) -> T? {
        return self as? T
    }
}

// Demonstrate the fixes:
print("=== Fix 2: Safe Type Casting ===")
processAnyData(123)  // ✅ Handles gracefully
processAnyData("Hello")  // ✅ Works correctly

print("\n=== Fix 4: Safe Downcasting ===")
let cat = Cat(name: "Whiskers")
makeAnimalSound(cat)  // ✅ Handles Cat correctly

let dog = Dog(name: "Buddy")
makeAnimalSound(dog)  // ✅ Handles Dog correctly

print("\n=== Fix 5: Safe Dictionary Access ===")
let validData: [String: Any] = [
    "age": 25,
    "scores": [90, 85, 95]
]
processUserData(validData)  // ✅ Works

let invalidData: [String: Any] = [
    "age": "25",  // String instead of Int
    "scores": [1, 2, 3]
]
processUserData(invalidData)  // ✅ Handles gracefully

print("\n=== Fix 6: Protocol Composition ===")
let person = Person(name: "Alice", age: 30)
processEntity(person)  // ✅ Works with composition

print("\n=== Fix 10: Safe Dictionary Processing ===")
let mixedDict: [String: Any] = [
    "name": "John",
    "age": 25
]
processDictionarySafe(mixedDict)  // ✅ Handles mixed types

print("\n✅ All type safety issues resolved!")
