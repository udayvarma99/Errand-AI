# Example 8: Value vs Reference Types

## 🐛 The Problem

Confusion between value types (struct, enum) and reference types (class) causes:
- **Unexpected mutations**: Changing a copy changes the original (or doesn't!)
- **Performance issues**: Unnecessary copying of large structs
- **Logic errors**: Expecting reference when using value type

## ✅ Key Differences

### Value Types (Struct, Enum)
- **Copied** when assigned or passed
- **Independent** instances
- **Immutable** if declared with `let`
- **Thread-safe** by default

### Reference Types (Class)
- **Shared** when assigned or passed
- **Same** instance
- **Properties can mutate** even with `let`
- **Need synchronization** for thread safety

## 📊 Quick Solutions

### 1. Use `inout` for Mutable Struct Parameters
```swift
func modify(_ point: inout Point) {
    point.x = 100  // ✅ Modifies original
}

var p = Point(x: 0, y: 0)
modify(&p)
```

### 2. Implement Copy for Classes
```swift
class Person {
    func copy() -> Person {
        return Person(name: name, age: age)
    }
}
```

### 3. Choose Type Based on Needs
```swift
// Use struct for simple values
struct Point { var x, y: Double }

// Use class for shared state
class Account { var balance: Double }
```

## 📚 When to Use What

**Use Struct:**
- Simple data types
- Want automatic copy
- Immutability preferred
- No inheritance needed

**Use Class:**
- Shared mutable state
- Need inheritance
- Identity matters
- Require deinit
