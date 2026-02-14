// Example 8: Value vs Reference - FIXED VERSION
// Proper understanding and usage of value and reference types

import Foundation

// FIX 1: Use inout for mutating structs
struct Point {
    var x: Double
    var y: Double
}

func modifyPoint(_ point: inout Point) {
    point.x = 100  // ✅ Modifies original
    print("Inside: \(point.x)")
}

var myPoint = Point(x: 10, y: 20)
modifyPoint(&myPoint)
print("Outside: \(myPoint.x)")  // ✅ Now 100

// FIX 2: Use class for shared mutable state
class LargeData {
    var values: [Int]
    
    init(values: [Int]) {
        self.values = values
    }
}

func processData(_ data: LargeData) {
    // ✅ No copy, modifies original
    data.values.append(999)
    print("Processed: \(data.values.count)")
}

let large = LargeData(values: Array(0..<10000))
processData(large)
print("Original: \(large.values.count)")  // ✅ Now 10001

// Or use struct with inout
struct LargeDataStruct {
    var values: [Int]
}

func processDataStruct(_ data: inout LargeDataStruct) {
    data.values.append(999)  // ✅ Modifies original
}

// FIX 3: Explicit copy for classes
class Person {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // ✅ Implement copy method
    func copy() -> Person {
        return Person(name: name, age: age)
    }
}

var person1 = Person(name: "Alice", age: 30)
var person2 = person1.copy()  // ✅ Explicit copy
person2.name = "Bob"
print("Person1: \(person1.name)")  // ✅ Still Alice

// Alternative: Use struct when you want value semantics
struct PersonStruct {
    var name: String
    var age: Int
}

var personStruct1 = PersonStruct(name: "Alice", age: 30)
var personStruct2 = personStruct1  // ✅ Automatic copy
personStruct2.name = "Bob"
print("PersonStruct1: \(personStruct1.name)")  // ✅ Still Alice

// FIX 4: Understand array semantics
struct StructItem {
    var value: Int
}

class ClassItem {
    var value: Int
    init(value: Int) { self.value = value }
}

// Struct array - value semantics
var structArray = [StructItem(value: 1), StructItem(value: 2)]
var structCopy = structArray
structCopy[0].value = 999
print("Struct original: \(structArray[0].value)")  // ✅ Still 1

// Class array - need explicit copy
var classArray = [ClassItem(value: 1), ClassItem(value: 2)]
var classCopy = classArray.map { $0.value }.map { ClassItem(value: $0) }  // ✅ Deep copy
classCopy[0].value = 999
print("Class original: \(classArray[0].value)")  // ✅ Still 1

// FIX 5: Use var for mutable struct
struct Counter {
    var count: Int
    
    mutating func increment() {
        count += 1
    }
}

var mutableCounter = Counter(count: 0)  // ✅ var, not let
mutableCounter.increment()
print("Counter: \(mutableCounter.count)")  // ✅ Works

// FIX 6: Capture class reference in closure
class Settings {
    var theme: String
    
    init(theme: String) {
        self.theme = theme
    }
}

class SettingsManager {
    var settings = Settings(theme: "dark")
    
    func scheduleThemeChange() {
        // ✅ Capture weak self to see updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if let theme = self?.settings.theme {
                print("Theme: \(theme)")  // ✅ Shows updated theme
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settings.theme = "light"
        }
    }
}

// FIX 7: Use inout for protocols
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

func changeID(_ item: inout Identifiable) {
    item.id = "changed"  // ✅ Works for both
}

// Or use generic with class constraint for references only
func changeIDClass<T: Identifiable & AnyObject>(_ item: T) {
    item.id = "changed"  // ✅ Only accepts classes
}

// FIX 8: Implement Equatable
struct Value: Equatable {
    var data: Int
}

class Reference: Equatable {
    var data: Int
    init(data: Int) { self.data = data }
    
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        return lhs.data == rhs.data  // Value equality
    }
}

let value1 = Value(data: 42)
let value2 = Value(data: 42)
print("Values equal: \(value1 == value2)")  // ✅ true

let ref1 = Reference(data: 42)
let ref2 = Reference(data: 42)
print("References value equal: \(ref1 == ref2)")  // ✅ true (value equality)
print("References identity equal: \(ref1 === ref2)")  // ✅ false (different objects)

// FIX 9: Return modified value
struct LargeDataStruct2 {
    var values: [Int]
}

class ViewModel {
    var data: LargeDataStruct2 = LargeDataStruct2(values: Array(0..<10000))
    
    func processData() {
        // ✅ Assign modified value back
        var localData = data
        localData.values.append(999)
        data = localData  // ✅ Update original
    }
    
    // Alternative: Use class for data
    var dataClass: LargeData = LargeData(values: Array(0..<10000))
    
    func processDataClass() {
        dataClass.values.append(999)  // ✅ Direct modification
    }
}

// FIX 10: Use inout or return value
func addItemInout(to container: inout StructContainer, item: Int) {
    container.items.append(item)  // ✅ Modifies original
}

func addItemReturn(to container: StructContainer, item: Int) -> StructContainer {
    var container = container
    container.items.append(item)
    return container  // ✅ Return modified copy
}

struct StructContainer {
    var items: [Int] = []
}

// BONUS: When to use struct vs class

// ✅ Use STRUCT when:
// - Representing a simple value (Point, Size, Date)
// - Want automatic copy behavior
// - Immutability is preferred
// - Small amount of data
// - No shared mutable state needed

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

// ✅ Use CLASS when:
// - Need shared mutable state
// - Require inheritance
// - Identity matters (two different objects with same data)
// - Large amount of data (avoid copy overhead)
// - Need deinit

class FileHandle {
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    deinit {
        // Clean up resources
    }
}

// Demonstrate fixes:
print("\n=== Fixed Value vs Reference ===")

print("\n1. Struct with inout:")
var point = Point(x: 5, y: 10)
modifyPoint(&point)
print("Point modified: \(point.x)")

print("\n2. Class for shared state:")
let data = LargeData(values: [1, 2, 3])
processData(data)
print("Data modified: \(data.values.count)")

print("\n3. Explicit copy:")
let p1 = Person(name: "Alice", age: 30)
let p2 = p1.copy()
p2.name = "Bob"
print("P1: \(p1.name), P2: \(p2.name)")

print("\n4. Settings with class:")
let settingsManager = SettingsManager()
settingsManager.scheduleThemeChange()
Thread.sleep(forTimeInterval: 2)
print("Closure saw updated theme")

print("\n✅ All value vs reference issues resolved!")
