// Example 8: Value vs Reference Type Confusion
// Misunderstanding struct (value) vs class (reference) semantics

import Foundation

// BUG 1: Expecting struct to behave like reference
struct Point {
    var x: Double
    var y: Double
}

func modifyPoint(_ point: Point) {
    var point = point
    point.x = 100  // 🐛 Modifies copy, not original!
    print("Inside: \(point.x)")
}

var myPoint = Point(x: 10, y: 20)
modifyPoint(myPoint)
print("Outside: \(myPoint.x)")  // Still 10!

// BUG 2: Unintentional copying of large struct
struct LargeData {
    var values: [Int]
}

func processData(_ data: LargeData) {
    var data = data
    // 🐛 Full copy of array created!
    data.values.append(999)
    print("Processed: \(data.values.count)")
}

var large = LargeData(values: Array(0..<10000))
processData(large)
print("Original: \(large.values.count)")  // Still 10000

// BUG 3: Expecting class to copy
class Person {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

var person1 = Person(name: "Alice", age: 30)
var person2 = person1  // 🐛 Both refer to same object!
person2.name = "Bob"
print("Person1: \(person1.name)")  // Changed to Bob!

// BUG 4: Array of classes vs structs
struct StructItem {
    var value: Int
}

class ClassItem {
    var value: Int
    init(value: Int) { self.value = value }
}

var structArray = [StructItem(value: 1), StructItem(value: 2)]
var structCopy = structArray
structCopy[0].value = 999
print("Struct original: \(structArray[0].value)")  // Still 1 ✅

var classArray = [ClassItem(value: 1), ClassItem(value: 2)]
var classCopy = classArray
classCopy[0].value = 999
print("Class original: \(classArray[0].value)")  // Changed to 999! 🐛

// BUG 5: Mutating method on constant struct
struct Counter {
    var count: Int
    
    mutating func increment() {
        count += 1
    }
}

let constantCounter = Counter(count: 0)
// constantCounter.increment()  // 💥 Error: Cannot use mutating member on immutable value

// BUG 6: Closure capturing struct
struct Settings {
    var theme: String
}

class SettingsManager {
    var settings = Settings(theme: "dark")
    
    func scheduleThemeChange() {
        // 🐛 Captures current value, won't see updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [settings] in
            print("Theme: \(settings.theme)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settings.theme = "light"
        }
    }
}

// BUG 7: Protocol with value/reference semantics
protocol Identifiable {
    var id: String { get set }
}

struct StructID: Identifiable {
    var id: String
}

class ClassID: Identifiable {
    var id: String
    init(id: String) { self.id = id }
}

func changeID(_ item: Identifiable) {
    var item = item
    item.id = "changed"  // 🐛 Struct: changes copy, Class: changes original
}

// BUG 8: Equality confusion
struct Value {
    var data: Int
}

class Reference {
    var data: Int
    init(data: Int) { self.data = data }
}

let value1 = Value(data: 42)
let value2 = Value(data: 42)
print("Values equal: \(value1.data == value2.data)")  // true

let ref1 = Reference(data: 42)
let ref2 = Reference(data: 42)
print("References equal: \(ref1 === ref2)")  // false! Different objects

// BUG 9: Implicit copy in property
class ViewModel {
    var data: LargeData = LargeData(values: Array(0..<10000))
    
    func processData() {
        // 🐛 Creates copy of struct!
        var localData = data
        localData.values.append(999)
        // Original data unchanged
    }
}

// BUG 10: Function parameter semantics
class Container {
    var items: [Int] = []
}

func addItem(to container: Container, item: Int) {
    container.items.append(item)  // ✅ Modifies original (reference)
}

struct StructContainer {
    var items: [Int] = []
}

func addItem(to container: StructContainer, item: Int) {
    var container = container
    container.items.append(item)  // 🐛 Modifies copy!
}

// Demonstrate bugs:
print("\n=== Value vs Reference Confusion ===")

let manager = SettingsManager()
manager.scheduleThemeChange()
Thread.sleep(forTimeInterval: 2)
print("Closure saw old value due to struct capture")
