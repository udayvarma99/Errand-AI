# Example 4: Thread Safety and Race Conditions

## 🐛 The Problem

Race conditions occur when multiple threads access shared data simultaneously, leading to:
- **Crashes**: Array/Dictionary mutation crashes
- **Data corruption**: Incorrect values
- **Inconsistent state**: Objects in invalid states
- **UI crashes**: UIKit accessed from background thread

**Common error messages:**
```
Thread 1: EXC_BAD_ACCESS (code=1, address=0x...)
Thread 1: Fatal error: UnsafeRawBufferPointer with negative count
Thread 1: signal SIGABRT
```

## 🔍 Understanding Race Conditions

### What is a Race Condition?

When the outcome depends on the timing of thread execution:

```swift
// Thread 1          // Thread 2
count = count + 1    count = count + 1

// Expected: count += 2
// Actual: count += 1 (race condition!)
```

### Why It Happens

Operations that look atomic aren't:

```swift
count += 1  // Actually three operations:
// 1. Read current value
// 2. Add 1
// 3. Write back

// Another thread can interleave!
```

## ✅ Solutions

### Solution 1: Serial DispatchQueue

For exclusive access:

```swift
class ThreadSafeClass {
    private var data: [String] = []
    private let queue = DispatchQueue(label: "com.app.queue")
    
    func add(_ item: String) {
        queue.sync {  // All access serialized
            data.append(item)
        }
    }
}
```

### Solution 2: Concurrent Queue with Barriers

For multiple readers, single writer:

```swift
class ThreadSafeCache {
    private var cache: [String: Any] = []
    private let queue = DispatchQueue(
        label: "com.app.cache",
        attributes: .concurrent
    )
    
    func get(_ key: String) -> Any? {
        queue.sync {  // Concurrent reads
            return cache[key]
        }
    }
    
    func set(_ value: Any, for key: String) {
        queue.async(flags: .barrier) {  // Exclusive write
            self.cache[key] = value
        }
    }
}
```

### Solution 3: Locks

For fine-grained control:

```swift
class Counter {
    private var count = 0
    private let lock = NSLock()
    
    func increment() {
        lock.lock()
        defer { lock.unlock() }
        count += 1
    }
}
```

### Solution 4: Actors (Swift 5.5+)

Modern approach:

```swift
actor Counter {
    private var count = 0
    
    func increment() {
        count += 1  // Automatically thread-safe
    }
    
    func getCount() -> Int {
        return count
    }
}

// Usage
let counter = Counter()
await counter.increment()
```

### Solution 5: Main Thread for UI

Always update UI on main thread:

```swift
DispatchQueue.main.async {
    self.label.text = "Updated"
}

// Or with async/await
await MainActor.run {
    self.label.text = "Updated"
}
```

## 📊 Synchronization Mechanisms Comparison

| Mechanism | Use Case | Pros | Cons |
|-----------|----------|------|------|
| Serial Queue | Simple exclusive access | Easy to use | Can be slow |
| Concurrent + Barrier | Multiple readers | Fast reads | More complex |
| NSLock | Fine-grained locking | Flexible | Easy to deadlock |
| OSAllocatedUnfairLock | High-performance | Very fast | Less safe |
| Actor | Modern Swift code | Built-in safety | Requires async/await |
| NSCache | Caching | Thread-safe, memory-managed | Limited use case |

## 🎯 Common Patterns

### Pattern 1: Thread-Safe Singleton

```swift
class Singleton {
    static let shared = Singleton()  // ✅ Thread-safe in Swift
    private init() { }
}
```

### Pattern 2: Read-Write Lock Pattern

```swift
class DataManager {
    private var data: [String] = []
    private let queue = DispatchQueue(label: "data", attributes: .concurrent)
    
    // Concurrent reads
    func getData() -> [String] {
        queue.sync { data }
    }
    
    // Exclusive writes
    func addData(_ item: String) {
        queue.async(flags: .barrier) {
            self.data.append(item)
        }
    }
}
```

### Pattern 3: UI Update Pattern

```swift
func updateUI() {
    if Thread.isMainThread {
        // Update directly
        label.text = "Update"
    } else {
        DispatchQueue.main.async {
            self.label.text = "Update"
        }
    }
}
```

### Pattern 4: Task Coordination

```swift
let group = DispatchGroup()

for item in items {
    group.enter()
    processItem(item) {
        group.leave()
    }
}

group.notify(queue: .main) {
    print("All done!")
}
```

## 🚨 Common Mistakes

### Mistake 1: Accessing UI from Background

```swift
// ❌ WRONG
URLSession.shared.dataTask(with: url) { data, _, _ in
    self.imageView.image = UIImage(data: data!)  // Crash!
}

// ✅ RIGHT
URLSession.shared.dataTask(with: url) { data, _, _ in
    DispatchQueue.main.async {
        self.imageView.image = UIImage(data: data!)
    }
}
```

### Mistake 2: Nested Locks (Deadlock)

```swift
// ❌ WRONG
func method1() {
    lock.lock()
    method2()  // Deadlock!
    lock.unlock()
}

func method2() {
    lock.lock()
    // ...
    lock.unlock()
}

// ✅ RIGHT
func method1() {
    lock.lock()
    defer { lock.unlock() }
    method2Internal()
}

private func method2Internal() {
    // Assumes lock is held
}
```

### Mistake 3: sync on Current Queue

```swift
// ❌ WRONG
queue.async {
    queue.sync {  // Deadlock!
        // ...
    }
}
```

## 💪 Practice Exercise

Fix the race conditions:

```swift
class UserManager {
    var users: [User] = []
    var cache: [String: User] = [:]
    
    func addUser(_ user: User) {
        users.append(user)
        cache[user.id] = user
    }
    
    func getUser(id: String) -> User? {
        return cache[id]
    }
}
```

**Answer:**

```swift
class UserManager {
    private var users: [User] = []
    private var cache: [String: User] = [:]
    private let queue = DispatchQueue(label: "com.users", attributes: .concurrent)
    
    func addUser(_ user: User) {
        queue.async(flags: .barrier) {
            self.users.append(user)
            self.cache[user.id] = user
        }
    }
    
    func getUser(id: String) -> User? {
        queue.sync {
            return cache[id]
        }
    }
}
```

## 📚 Key Takeaways

1. **Shared mutable state needs synchronization**
2. **Use serial queue for simple cases**
3. **Use concurrent queue with barriers for reader-writer**
4. **Always update UI on main thread**
5. **Actors are the modern way** for Swift 5.5+
6. **Test with Thread Sanitizer** enabled
7. **Avoid nested locks** to prevent deadlock
8. **Use `defer` to ensure lock release**
9. **NSCache is already thread-safe**
10. **Static let is thread-safe** for singletons
