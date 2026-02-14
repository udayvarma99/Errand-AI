# Example 6: Async/Await and Concurrency Issues

## 🐛 The Problem

Modern Swift concurrency errors include:
- Data races with non-Sendable types
- MainActor isolation violations
- Improper task cancellation
- Mixing old and new concurrency models
- Double continuation resume (crash!)

## ✅ Key Solutions

### 1. Use async/await Properly
```swift
// ✅ Mark functions async
func fetchData() async -> String {
    try? await URLSession.shared.data(from: url)
}

// ✅ Call with await
let data = await fetchData()
```

### 2. Actor for Thread-Safe State
```swift
actor Counter {
    private var value = 0
    func increment() { value += 1 }  // ✅ Thread-safe
}
```

### 3. Respect MainActor
```swift
@MainActor
class ViewModel {
    var data: [String] = []
}

// Call from any context
await MainActor.run {
    viewModel.data = newData
}
```

### 4. Handle Cancellation
```swift
func longTask() async throws -> Result {
    for item in items {
        try Task.checkCancellation()  // ✅ Check cancellation
        // Process item
    }
}
```

### 5. Proper Continuation Usage
```swift
// ✅ Resume exactly once
return await withCheckedContinuation { continuation in
    oldAPI { result in
        continuation.resume(returning: result)
    }
}
```

## 📚 Key Takeaways

1. **Use actors** for shared mutable state
2. **Always await** async let bindings
3. **Check cancellation** in long operations
4. **MainActor for UI** updates
5. **Sendable types** for task boundaries
6. **Resume continuation once** only
7. **Cancel tasks** in deinit
8. **async throws** for error handling
