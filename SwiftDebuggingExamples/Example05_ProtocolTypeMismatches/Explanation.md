# Example 5: Protocol and Type Mismatches

## 🐛 The Problem

Type casting and protocol conformance errors cause crashes with messages like:
```
Could not cast value of type 'Cat' to 'Dog'
Fatal error: Protocol type 'Container' cannot conform to itself
Type 'MyStruct' does not conform to protocol 'MyProtocol'
```

## ✅ Key Solutions

### 1. Safe Type Casting
```swift
// ❌ WRONG
let string = value as! String  // Crash if not String

// ✅ RIGHT
if let string = value as? String {
    print(string)
}

// ✅ SWITCH
switch value {
case let string as String: print(string)
case let number as Int: print(number)
default: print("Unknown")
}
```

### 2. Protocol Composition
```swift
// ❌ WRONG
func process(_ entity: Nameable) {
    let ageable = entity as! Ageable  // Might crash
}

// ✅ RIGHT
func process(_ entity: Nameable & Ageable) {
    print(entity.name, entity.age)  // Guaranteed to work
}
```

### 3. Generic Constraints
```swift
// ❌ WRONG
func print<T>(_ items: [T]) {
    items.forEach { print($0.description) }  // Error!
}

// ✅ RIGHT
func print<T: CustomStringConvertible>(_ items: [T]) {
    items.forEach { print($0.description) }
}
```

### 4. Type Erasure for Associated Types
```swift
protocol Container {
    associatedtype Item
    func add(_ item: Item)
}

// Can't use: let c: Container = ...

// ✅ Use type erasure
class AnyContainer<T> {
    private let _add: (T) -> Void
    init<C: Container>(_ container: C) where C.Item == T {
        _add = container.add
    }
    func add(_ item: T) { _add(item) }
}
```

## 📚 Key Takeaways

1. **Always use `as?` for conditional casting**, never `as!`
2. **Use protocol composition** (`&`) instead of casting
3. **Add generic constraints** when needed
4. **Use type erasure** for protocols with associated types
5. **Prefer polymorphism** over type casting
6. **Use `switch` with `case let`** for multiple type checks
7. **Class-only protocols** need `: AnyObject`
8. **Test with different types** to catch type errors
