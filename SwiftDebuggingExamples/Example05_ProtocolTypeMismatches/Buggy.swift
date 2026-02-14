// Example 5: Protocol and Type Mismatches
// This code has protocol conformance and type casting bugs

import Foundation

// BUG 1: Protocol not fully implemented
protocol DataSource {
    func numberOfItems() -> Int
    func item(at index: Int) -> String
    func refresh()  // 🐛 Missing implementation below!
}

class TableDataSource: DataSource {
    func numberOfItems() -> Int {
        return 10
    }
    
    func item(at index: Int) -> String {
        return "Item \(index)"
    }
    // 💥 Missing refresh() - compile error!
}

// BUG 2: Type casting without checking
func processAnyData(_ data: Any) {
    let stringData = data as! String  // 💥 Crash if not String
    print(stringData.uppercased())
    
    let arrayData = data as! [Int]  // 💥 Crash if not [Int]
    print(arrayData.count)
}

// BUG 3: Protocol with associated type issues
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

// 🐛 Can't use protocol as type directly!
// let container: Container = StringContainer()  // 💥 Error!

// BUG 4: Downcasting in class hierarchy
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
    // 🐛 Assuming it's always a Dog!
    let dog = animal as! Dog  // 💥 Crash if it's a Cat!
    dog.bark()
}

// BUG 5: Dictionary type casting
func processUserData(_ data: [String: Any]) {
    let age = data["age"] as! Int  // 💥 Crash if wrong type
    let scores = data["scores"] as! [Int]  // 💥 Crash if wrong type
    
    print("Age: \(age)")
    print("Scores: \(scores)")
}

// BUG 6: Protocol composition issues
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

func processEntity(_ entity: Nameable) {
    // 🐛 Assuming it also conforms to Ageable
    let ageable = entity as! Ageable  // 💥 Crash if doesn't conform!
    print("\(ageable.age)")
}

// BUG 7: Generic constraints not enforced
func printItems<T>(_ items: [T]) {
    for item in items {
        print(item.description)  // 💥 Error! T might not have description
    }
}

// BUG 8: AnyObject vs Any confusion
protocol ViewProtocol: AnyObject {  // Class-only protocol
    func display()
}

struct ViewStruct {
    func display() { print("Struct view") }
}

// 💥 Error: Struct can't conform to class-only protocol
extension ViewStruct: ViewProtocol {
    
}

// BUG 9: Enum with associated values casting
enum Result {
    case success(String)
    case failure(Error)
}

func handleResult(_ result: Result) {
    // 🐛 Not checking which case it is
    if case .success(let value) = result {
        print(value)
    }
    
    let errorValue = result as! Error  // 💥 Can't cast enum to Error!
}

// BUG 10: Collection type mismatch
func processDictionary(_ dict: Any) {
    // 🐛 Wrong dictionary type
    let typedDict = dict as! [String: String]  // 💥 Crash if values aren't strings
    
    for (key, value) in typedDict {
        print("\(key): \(value.uppercased())")
    }
}

// Demonstrate the bugs:
print("=== Bug 2: Type Casting ===")
processAnyData(123)  // 💥 Crash! Not a String

print("\n=== Bug 4: Class Downcasting ===")
let cat = Cat(name: "Whiskers")
makeAnimalSound(cat)  // 💥 Crash! It's a Cat, not a Dog

print("\n=== Bug 5: Dictionary Type Casting ===")
let userData: [String: Any] = [
    "age": "25",  // String instead of Int!
    "scores": [1, 2, 3]
]
processUserData(userData)  // 💥 Crash! Age is String

print("\n=== Bug 10: Collection Type Mismatch ===")
let mixedDict: [String: Any] = [
    "name": "John",
    "age": 25  // Int, not String!
]
processDictionary(mixedDict)  // 💥 Crash! Not all values are Strings
