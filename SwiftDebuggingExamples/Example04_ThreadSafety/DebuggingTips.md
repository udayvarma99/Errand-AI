# Debugging Thread Safety Issues

## 🔧 Detection Tools

### 1. Thread Sanitizer (TSan)

**Enable:**
1. Edit Scheme → Run → Diagnostics
2. Check "Thread Sanitizer"

**What it catches:**
- Data races
- Use after free
- Thread leaks

**Reading TSan output:**
```
WARNING: ThreadSanitizer: data race
  Write of size 8 at 0x7b0400000000 by thread T2:
    #0 -[MyClass setProperty:] MyClass.m:42
  
  Previous read at 0x7b0400000000 by main thread:
    #0 -[MyClass property] MyClass.m:38
```

### 2. Main Thread Checker

**Enable:**
Edit Scheme → Run → Diagnostics → Main Thread Checker

**Catches:**
- UI updates on background threads
- UIKit/AppKit called from background

### 3. Address Sanitizer

**Enable:**
Edit Scheme → Run → Diagnostics → Address Sanitizer

**Catches:**
- Use after free
- Buffer overflows
- Memory corruption

## 🛠 Debugging Techniques

### Technique 1: Adding Print Statements

```swift
func threadSafeMethod() {
    print("Thread: \(Thread.current)")
    print("Is main: \(Thread.isMainThread)")
    
    queue.sync {
        print("Inside queue: \(Thread.current)")
        // Your code
    }
}
```

### Technique 2: Breakpoint on Thread

In LLDB:
```
(lldb) thread list
(lldb) thread backtrace
(lldb) frame info
```

### Technique 3: Symbolic Breakpoint

Set breakpoint on:
- `objc_exception_throw`
- `_NSLockError`
- Main thread violations

### Technique 4: Logging Queue Name

```swift
func currentQueueName() -> String {
    let name = __dispatch_queue_get_label(nil)
    return String(cString: name, encoding: .utf8) ?? "Unknown"
}

print("Current queue: \(currentQueueName())")
```

## 🔍 Finding Race Conditions

### Step 1: Reproduce Consistently

```swift
// Increase iterations to make race more likely
DispatchQueue.concurrentPerform(iterations: 10000) { i in
    // Your code
}
```

### Step 2: Add Assertions

```swift
func updateUI() {
    assert(Thread.isMainThread, "Must be called on main thread")
    // Update UI
}
```

### Step 3: Use Dispatch Preconditions

```swift
class DataManager {
    private let queue = DispatchQueue(label: "data")
    
    func privateMethod() {
        dispatchPrecondition(condition: .onQueue(queue))
        // Crashes if not on correct queue
    }
}
```

## 📊 Common Crash Patterns

### Pattern 1: UI Crash

**Error:**
```
UIKit: must be called from main thread only
```

**Find:**
```swift
// Add breakpoint with action:
po Thread.isMainThread

// Or check call stack for UI methods
```

**Fix:**
```swift
DispatchQueue.main.async {
    // UI update here
}
```

### Pattern 2: Collection Mutation Crash

**Error:**
```
Fatal error: UnsafeRawBufferPointer with negative count
EXC_BAD_ACCESS
```

**Find:**
Enable Thread Sanitizer to see exact location

**Fix:**
```swift
private let queue = DispatchQueue(label: "array")

func modify() {
    queue.async(flags: .barrier) {
        array.append(item)
    }
}
```

### Pattern 3: Deadlock

**Symptoms:**
- App freezes
- Thread stuck in dispatch_sync

**Find:**
```
(lldb) thread backtrace all
# Look for threads waiting on same lock
```

**Fix:**
- Avoid nested sync calls
- Use recursive locks if needed
- Restructure code

## 🎯 Testing Strategies

### Unit Test for Races

```swift
func testThreadSafety() {
    let manager = DataManager()
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 100
    
    for i in 0..<100 {
        DispatchQueue.global().async {
            manager.addItem("Item \(i)")
            expectation.fulfill()
        }
    }
    
    wait(for: [expectation], timeout: 5.0)
    XCTAssertEqual(manager.count, 100)
}
```

### Stress Test

```swift
func stressTest() {
    let iterations = 10000
    
    DispatchQueue.concurrentPerform(iterations: iterations) { i in
        // Your concurrent code
    }
}
```

## 💡 Prevention Strategies

### 1. Code Review Checklist

- [ ] Shared mutable state synchronized?
- [ ] UI updates on main thread?
- [ ] Locks properly released (use defer)?
- [ ] No nested sync on same queue?
- [ ] Thread-safe collections used?

### 2. Static Analysis

Enable in Build Settings:
- Static Analyzer
- Run analyzer: Product → Analyze

### 3. Runtime Checks

```swift
#if DEBUG
func ensureMainThread() {
    assert(Thread.isMainThread, "Must be on main thread")
}
#endif
```

## 🚀 Advanced Debugging

### Custom Queue Labels

```swift
let queue = DispatchQueue(
    label: "com.myapp.specific.operation",  // Descriptive!
    qos: .userInitiated,
    attributes: .concurrent
)
```

### Queue Specific Keys

```swift
let key = DispatchSpecificKey<String>()
queue.setSpecific(key: key, value: "myQueue")

func isOnMyQueue() -> Bool {
    return DispatchQueue.getSpecific(key: key) != nil
}
```

### Instruments - System Trace

1. Product → Profile
2. Select "System Trace"
3. Record while reproducing issue
4. Examine thread activity

### Thread State Logging

```swift
extension Thread {
    static func logState() {
        print("""
            Thread State:
            - Current: \(current)
            - Main: \(isMainThread)
            - Count: \(activeCount)
            - Call stack: \(callStackSymbols.prefix(5))
            """)
    }
}
```

## 📝 Debugging Workflow

### When You Suspect a Race:

1. **Enable Thread Sanitizer** - Run your tests
2. **Check logs** for data race warnings
3. **Add print statements** around suspicious code
4. **Increase iterations** to reproduce
5. **Check thread dumps** with breakpoints
6. **Fix synchronization** based on findings
7. **Verify with TSan** again

### When App Freezes:

1. **Pause debugger**
2. **Check all threads**: `thread backtrace all`
3. **Look for** `dispatch_sync` calls
4. **Identify** which locks are held
5. **Check for** circular wait
6. **Restructure** to avoid deadlock

## 🎓 Additional Resources

- WWDC: "Building Responsive and Efficient Apps with GCD"
- WWDC: "Modernizing Grand Central Dispatch Usage"
- WWDC: "Swift Concurrency: Behind the Scenes"
- Thread Sanitizer Documentation
- Concurrency Programming Guide
