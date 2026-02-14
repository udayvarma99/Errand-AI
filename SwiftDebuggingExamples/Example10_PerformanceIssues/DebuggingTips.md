# Debugging Performance Issues

## 🔧 Measuring Performance

### Time Measurement
```swift
let start = Date()
// Your code
let duration = Date().timeIntervalSince(start)
print("Time: \(duration)s")
```

### CFAbsoluteTime (More Precise)
```swift
let start = CFAbsoluteTimeGetCurrent()
// Your code
let duration = CFAbsoluteTimeGetCurrent() - start
print("Duration: \(duration)s")
```

### Measure in Tests
```swift
func testPerformance() {
    measure {
        // Code to measure
    }
}
```

## 🛠 Profiling Tools

### 1. Time Profiler (Instruments)
1. Product → Profile (⌘I)
2. Select "Time Profiler"
3. Record while using app
4. Find hot spots in call tree

### 2. Allocations Instrument
1. Product → Profile
2. Select "Allocations"
3. Look for memory growth
4. Check persistent objects

### 3. Debug Navigator
- Shows CPU and memory usage in realtime
- View → Navigators → Debug Navigator

## 🎯 Quick Checks

### Big O Complexity
```swift
// O(1) - Constant: Direct access
array[0]
dict[key]
set.contains(item)

// O(log n) - Logarithmic: Binary search
binarySearch()

// O(n) - Linear: Single loop
array.contains(item)
array.filter { }

// O(n log n) - Log-linear: Efficient sort
array.sorted()

// O(n²) - Quadratic: Nested loops
for item in array {
    for other in array { }
}
```

### Common Performance Mistakes
1. **array.contains in loop** → Use Set
2. **String concatenation in loop** → Use joined()
3. **filter().first** → Use first(where:)
4. **Nested loops** → Use dictionary/set
5. **Not reserving capacity** → Use reserveCapacity()

## 💡 Optimization Checklist

- [ ] Use Set for lookups
- [ ] Use lazy for chained operations
- [ ] Reserve capacity for arrays
- [ ] Use compactMap instead of manual filtering
- [ ] Use reduce(into:) for accumulation
- [ ] Avoid String += in loops
- [ ] Use first(where:) not filter().first
- [ ] Profile with Instruments
- [ ] Test with realistic data sizes
- [ ] Measure before and after optimization
