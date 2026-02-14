# Debugging Async/Await Issues

## 🔧 Debugging Tools

### 1. Swift Concurrency Instruments
Product → Profile → "Swift Concurrency" template

### 2. Enable Strict Concurrency Checking
Build Settings → Swift Compiler → Strict Concurrency Checking: Complete

### 3. Runtime Warnings
Edit Scheme → Run → Diagnostics → Runtime API Checking

## 🚨 Common Errors

### Error: "Call to main actor-isolated..."
```swift
// ✅ Fix
await MainActor.run {
    // UI update
}
```

### Error: "async let must be awaited..."
```swift
async let data = fetch()
_ = await data  // ✅ Must await
```

### Error: "Cannot call async function..."
```swift
// ✅ Make function async or use Task
Task {
    await asyncFunction()
}
```

## 💡 Quick Tips

1. **Print current executor**: `print(#function, Thread.current)`
2. **Check if on MainActor**: `MainActor.assumeIsolated { }`
3. **Task local values** for debugging context
4. **Instruments** for actor reentrancy issues
