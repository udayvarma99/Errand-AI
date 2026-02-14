# Example 10: Performance Issues with Collections

## 🐛 The Problem

Poor collection usage causes:
- **Slow app performance**: O(n²) instead of O(n)
- **High memory usage**: Unnecessary copies
- **UI freezing**: Blocking main thread
- **Battery drain**: Wasted CPU cycles

## ✅ Key Optimizations

### 1. Use Set for Lookups
```swift
// ❌ O(n) lookup
if array.contains(item) { }

// ✅ O(1) lookup
let set = Set(array)
if set.contains(item) { }
```

### 2. Use String Builder
```swift
// ❌ O(n²)
var result = ""
for item in items {
    result += item
}

// ✅ O(n)
let result = items.joined()
```

### 3. Use first(where:)
```swift
// ❌ Processes entire array
let match = array.filter(condition).first

// ✅ Stops at first match
let match = array.first(where: condition)
```

### 4. Use compactMap
```swift
// ❌ Verbose and slow
var result: [Int] = []
for str in strings {
    if let num = Int(str) {
        result.append(num)
    }
}

// ✅ Clean and fast
let result = strings.compactMap { Int($0) }
```

### 5. Use Lazy Evaluation
```swift
// ❌ Processes entire array
let result = numbers
    .map { $0 * 2 }
    .filter { $0 > 100 }
    .first

// ✅ Stops early
let result = numbers
    .lazy
    .map { $0 * 2 }
    .first { $0 > 100 }
```

### 6. Reserve Capacity
```swift
var array: [Int] = []
array.reserveCapacity(1000)  // ✅ Avoid reallocations

for i in 0..<1000 {
    array.append(i)
}
```

### 7. Use reduce(into:)
```swift
// ❌ Creates copies
let result = items.reduce([]) { $0 + [$1 * 2] }

// ✅ Mutates in place
let result = items.reduce(into: []) { $0.append($1 * 2) }
```

### 8. Dictionary Default Values
```swift
// ❌ Multiple lookups
if let count = dict[key] {
    dict[key] = count + 1
} else {
    dict[key] = 1
}

// ✅ Single operation
dict[key, default: 0] += 1
```

## 📊 Performance Comparison

| Operation | Slow | Fast | Improvement |
|-----------|------|------|-------------|
| Lookup | Array O(n) | Set O(1) | 100x |
| String concat | += O(n²) | joined() O(n) | 10x |
| Find first | filter+first | first(where:) | 2x |
| Transform | map→filter→first | lazy | 100x |

## 📚 Key Takeaways

1. **Use Set** for frequent lookups
2. **Use first(where:)** instead of filter().first
3. **Use lazy** for chained operations
4. **Reserve capacity** when size is known
5. **Use compactMap** for optional unwrapping
6. **Use reduce(into:)** for accumulation
7. **Profile with Instruments** to find bottlenecks
8. **Test with large datasets** to catch performance issues
9. **Avoid nested loops** when possible
10. **Use appropriate data structures** (Set, Dictionary, Array)
