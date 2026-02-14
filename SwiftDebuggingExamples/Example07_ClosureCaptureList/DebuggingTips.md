# Debugging Closure Capture Issues

## 🔧 Finding Capture Problems

### Check What's Captured
```swift
// Add print to see captures
closure = { [weak self, value] in
    print("Self: \(self != nil)")
    print("Value: \(value)")
}
```

### Memory Graph Debugger
1. Debug → Debug Memory Graph
2. Look for closure → self cycles
3. Check purple warning icons

### Add deinit
```swift
class MyClass {
    deinit {
        print("Deallocated")  // Not called = leak
    }
}
```

## 💡 Quick Fixes

1. **Add [weak self]** to all escaping closures
2. **Use [i]** in loops
3. **Cancel timers** in deinit
4. **Prefer async/await** over closures when possible
