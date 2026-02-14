# Example 7: Closure Capture Lists

## 🐛 The Problem

Closures capture variables from their surrounding context, which can cause:
- **Loop variable capture**: All closures capture same reference
- **Strong reference cycles**: Closure captures self strongly
- **Unintended value changes**: Captured reference changes later
- **Memory leaks**: Lazy properties with self capture

## ✅ Solutions

### 1. Capture Loop Values
```swift
// ❌ WRONG
for i in 0...5 {
    closure { print(i) }  // All print 5
}

// ✅ RIGHT
for i in 0...5 {
    closure { [i] in print(i) }  // Each prints different value
}
```

### 2. Weak Self in Closures
```swift
// ❌ WRONG
closure = {
    self.doWork()  // Strong capture
}

// ✅ RIGHT
closure = { [weak self] in
    self?.doWork()
}
```

### 3. Capture Values Not References
```swift
// ❌ Captures reference
let dict = self.settings
closure { print(dict) }  // Might change

// ✅ Captures copy
let dictCopy = self.settings
closure { [dictCopy] in print(dictCopy) }
```

### 4. Strong Self After Guard
```swift
closure { [weak self] in
    guard let self = self else { return }
    // self is now strong for this scope
    self.doWork()
    self.doMore()  // Safe
}
```

## 📚 Key Takeaways

1. **Use `[weak self]`** in escaping closures
2. **Capture loop indices** with `[i]`
3. **Capture values** when you need snapshot
4. **Use guard let self** for multiple accesses
5. **Weak capture in lazy** properties
6. **Clean up timers** in deinit
