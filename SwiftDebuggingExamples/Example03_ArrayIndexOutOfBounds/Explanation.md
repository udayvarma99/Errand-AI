# Example 3: Array Index Out of Bounds

## 🐛 The Problem

Accessing an array at an invalid index causes an immediate crash with the error:

```
Fatal error: Index out of range
```

This is one of the most common runtime errors in Swift.

## 🔍 Understanding Array Indexing

### Valid Indices
```swift
let array = ["a", "b", "c"]
// Valid indices: 0, 1, 2
// array.count = 3
// array.indices = 0..<3

array[0]  // ✅ "a"
array[2]  // ✅ "c"
array[3]  // 💥 Crash! Index out of range
```

### Empty Array
```swift
let empty: [String] = []
// empty.count = 0
// empty.indices = 0..<0 (empty range)

empty[0]  // 💥 Crash! No elements at all
```

## ✅ Safe Access Patterns

### 1. Use `.first` and `.last`
```swift
// Instead of array[0]
let first = array.first  // Returns Optional<Element>

// Instead of array[array.count - 1]
let last = array.last  // Returns Optional<Element>
```

### 2. Check `.indices`
```swift
if array.indices.contains(index) {
    let element = array[index]  // ✅ Safe
}
```

### 3. Use `.isEmpty`
```swift
if !array.isEmpty {
    let first = array[0]  // ✅ Safe
}
```

### 4. Check `.count`
```swift
if index < array.count {
    let element = array[index]  // ✅ Safe
}
```

### 5. Safe Subscript Extension
```swift
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

let element = array[safe: 5]  // Returns nil instead of crashing
```

## 📊 Common Scenarios

### Scenario 1: Getting First Element
```swift
// ❌ WRONG
let first = array[0]

// ✅ RIGHT
let first = array.first

// ✅ With default
let first = array.first ?? defaultValue

// ✅ With guard
guard let first = array.first else { return }
```

### Scenario 2: Getting Last Element
```swift
// ❌ WRONG
let last = array[array.count - 1]

// ✅ RIGHT
let last = array.last
```

### Scenario 3: User Input Index
```swift
// ❌ WRONG
let index = Int(input)!
let item = array[index]

// ✅ RIGHT
guard let index = Int(input),
      array.indices.contains(index) else {
    print("Invalid index")
    return
}
let item = array[index]
```

### Scenario 4: Removing Elements While Iterating
```swift
// ❌ WRONG - modifies array during iteration
for i in 0..<array.count {
    if shouldRemove(array[i]) {
        array.remove(at: i)  // 💥 Array size changes!
    }
}

// ✅ RIGHT - filter creates new array
array = array.filter { !shouldRemove($0) }

// ✅ ALSO RIGHT - iterate in reverse
for i in (0..<array.count).reversed() {
    if shouldRemove(array[i]) {
        array.remove(at: i)
    }
}
```

### Scenario 5: Getting Multiple Elements
```swift
// ❌ WRONG
let first3 = [array[0], array[1], array[2]]

// ✅ RIGHT
let first3 = Array(array.prefix(3))

// ✅ Check count first
guard array.count >= 3 else { return nil }
let first3 = Array(array[0..<3])
```

### Scenario 6: Range Access
```swift
// ❌ WRONG
let slice = array[start...end]

// ✅ RIGHT
guard array.indices.contains(start),
      array.indices.contains(end),
      start <= end else {
    return nil
}
let slice = array[start...end]

// ✅ Use prefix/suffix
let first5 = array.prefix(5)  // Gets up to 5 elements
let last5 = array.suffix(5)   // Gets up to last 5 elements
```

## 🚨 Common Mistakes

### Mistake 1: Off-by-one errors
```swift
// ❌ WRONG
for i in 0...array.count {  // Goes one too far!
    print(array[i])
}

// ✅ RIGHT
for i in 0..<array.count {  // Correct range
    print(array[i])
}

// ✅ BETTER
for element in array {  // No index needed
    print(element)
}
```

### Mistake 2: Assuming array has elements
```swift
// ❌ WRONG
func process() {
    let item = dataArray[0]  // What if empty?
}

// ✅ RIGHT
func process() {
    guard let item = dataArray.first else { return }
    // Use item
}
```

### Mistake 3: Not validating calculated indices
```swift
// ❌ WRONG
let nextIndex = currentIndex + 1
let next = array[nextIndex]  // Might be out of range!

// ✅ RIGHT
let nextIndex = currentIndex + 1
guard array.indices.contains(nextIndex) else { return }
let next = array[nextIndex]
```

### Mistake 4: Concurrent modification
```swift
// ❌ WRONG
DispatchQueue.concurrentPerform(iterations: array.count) { i in
    print(array[i])  // Array might be modified!
}

// ✅ RIGHT
let arrayCopy = array
DispatchQueue.concurrentPerform(iterations: arrayCopy.count) { i in
    print(arrayCopy[i])
}
```

## 🎯 Best Practices

### 1. Prefer Safe Collection Methods
```swift
// Instead of direct indexing, use:
array.first              // First element
array.last               // Last element
array.first(where: { })  // First matching element
array.prefix(n)          // First n elements
array.suffix(n)          // Last n elements
array.dropFirst()        // All but first
array.dropLast()         // All but last
```

### 2. Use `enumerated()` Safely
```swift
// Safe enumeration
for (index, element) in array.enumerated() {
    // index is guaranteed valid
    print("\(index): \(element)")
}
```

### 3. Validate Before Accessing
```swift
func getElement(at index: Int) -> Element? {
    guard array.indices.contains(index) else { return nil }
    return array[index]
}
```

### 4. Use Guard for Required Access
```swift
guard array.indices.contains(index) else {
    print("Invalid index")
    return
}
let element = array[index]
```

## 💪 Practice Exercise

Fix this buggy code:

```swift
func processTopUsers(_ users: [User]) {
    let topUser = users[0]
    let secondUser = users[1]
    let thirdUser = users[2]
    
    print("Top 3: \(topUser.name), \(secondUser.name), \(thirdUser.name)")
    
    for i in 0...users.count {
        users[i].processDailyStat()
    }
}
```

**Answer:**

```swift
func processTopUsers(_ users: [User]) {
    // Safe access to top 3
    let topUsers = Array(users.prefix(3))
    
    guard topUsers.count >= 3 else {
        print("Not enough users")
        return
    }
    
    print("Top 3: \(topUsers[0].name), \(topUsers[1].name), \(topUsers[2].name)")
    
    // Safe iteration
    for user in users {
        user.processDailyStat()
    }
    
    // Or with index:
    for i in users.indices {
        users[i].processDailyStat()
    }
}
```

## 📚 Key Takeaways

1. **Never assume array has elements** - always check
2. **Use `.first` and `.last`** instead of `[0]` and `[count-1]`
3. **Check `.indices.contains(index)`** before accessing
4. **Use `.prefix()` and `.suffix()`** for getting multiple elements
5. **Iterate in reverse** when removing elements
6. **Create safe subscript extensions** for reusable safe access
7. **Validate user input** before using as index
8. **Be careful with concurrent access** - use copies
9. **Prefer iteration over indexing** when you don't need the index
10. **Use `enumerated()` for safe index/element pairs**
