# Debugging Memory Leaks

## 🔧 Detecting Memory Leaks

### Method 1: Using deinit

The simplest way to detect if objects are being deallocated:

```swift
class MyClass {
    let name: String
    
    init(name: String) {
        self.name = name
        print("✅ \(name) initialized")
    }
    
    deinit {
        print("🗑️ \(name) deallocated")
    }
}

// Test
func test() {
    let obj = MyClass(name: "Test")
    // obj should be deallocated when function exits
}
test()
// If you don't see "🗑️ Test deallocated", you have a leak!
```

### Method 2: Xcode Memory Graph Debugger

**Step-by-step:**

1. Run your app in Xcode
2. Perform actions that might leak memory
3. Click the Debug Memory Graph button (📊 icon) in the debug bar
4. Look for purple icons (!) indicating retain cycles
5. Click on an object to see its references

**What to look for:**
- Objects that should be deallocated but aren't
- Purple warning icons
- Unexpected strong references

### Method 3: Instruments - Leaks Tool

**How to use:**

1. Product → Profile (⌘I)
2. Select "Leaks" template
3. Click Record
4. Use your app normally
5. Look for red leak indicators
6. Click on a leak to see the stack trace

**Interpreting results:**
- Red bars = memory leaks detected
- Click leak to see allocation stack trace
- "Leaks" list shows all leaked objects

### Method 4: Instruments - Allocations Tool

**Best for:**
- Tracking object allocation/deallocation
- Finding objects that aren't being freed
- Monitoring memory growth over time

**How to use:**

1. Product → Profile (⌘I)
2. Select "Allocations" template
3. Filter by class name
4. Check "Created & Persistent" vs "Created & Destroyed"
5. Objects in "Persistent" that should be destroyed = leak

## 🛠 Debugging Techniques

### Technique 1: Reference Counting

Check retain count (for debugging only):

```swift
import Foundation

class MyClass {
    var name: String
    init(name: String) { self.name = name }
}

let obj = MyClass(name: "Test")
print(CFGetRetainCount(obj as CFTypeRef))  // Shows retain count
```

### Technique 2: Weak Reference Debugging

Track when weak references become nil:

```swift
weak var delegate: SomeDelegate? {
    didSet {
        if delegate == nil {
            print("⚠️ Delegate was set to nil")
        }
    }
}
```

### Technique 3: Capture List Debugging

Print what's being captured:

```swift
func setupClosure() {
    let localValue = "test"
    
    closure = { [weak self, capturedValue = localValue] in
        print("Self exists: \(self != nil)")
        print("Captured: \(capturedValue)")
    }
}
```

### Technique 4: Finding Closure Cycles

Add logging to see when closures are created/destroyed:

```swift
class Manager {
    var completion: (() -> Void)? {
        didSet {
            print("Completion handler set")
        }
    }
    
    deinit {
        print("Manager deallocated")
        if completion != nil {
            print("⚠️ Warning: Completion handler still exists!")
        }
    }
}
```

## 🔍 LLDB Commands for Memory Debugging

### Check if object is deallocated

```
(lldb) po self
# If object is deallocated, you'll see an error

(lldb) frame variable self
# Shows self without evaluating it
```

### Print all strong references to an object

```
(lldb) po CFGetRetainCount(object as CFTypeRef)
```

### Find all instances of a class

```
(lldb) expression -lobjc -O -- [NSObject allInstances]
```

## 📊 Common Memory Leak Patterns

### Pattern 1: Timer Leaks

```swift
// PROBLEM
class TimerManager {
    var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
        // Even with weak self, timer keeps manager alive!
    }
}

// SOLUTION
deinit {
    timer?.invalidate()
    timer = nil
}
```

### Pattern 2: Notification Observer Leaks

```swift
// PROBLEM
class Observer {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification),
            name: .dataUpdated,
            object: nil
        )
        // Never removed!
    }
}

// SOLUTION
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

### Pattern 3: URLSession Leaks

```swift
// PROBLEM
class NetworkManager {
    func fetch() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            self.process(data)  // Strong capture
        }.resume()
    }
}

// SOLUTION
func fetch() {
    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        self?.process(data)
    }.resume()
}
```

### Pattern 4: GCD Leaks

```swift
// PROBLEM
class Worker {
    var queue = DispatchQueue(label: "work")
    
    func doWork() {
        queue.async {
            self.process()  // Strong capture
        }
    }
}

// SOLUTION
func doWork() {
    queue.async { [weak self] in
        self?.process()
    }
}
```

## 🎯 Testing for Memory Leaks

### Unit Test for Deallocation

```swift
import XCTest

class MemoryLeakTests: XCTestCase {
    func testViewControllerDeallocates() {
        var viewController: ViewController? = ViewController()
        
        // Create weak reference
        weak var weakVC = viewController
        
        // Simulate usage
        viewController?.viewDidLoad()
        
        // Release strong reference
        viewController = nil
        
        // Check if deallocated
        XCTAssertNil(weakVC, "ViewController should be deallocated")
    }
    
    func testDelegateDoesNotCreateRetainCycle() {
        var parent: ParentView? = ParentView()
        var child: ChildView? = ChildView()
        
        child?.delegate = parent
        
        weak var weakParent = parent
        parent = nil
        
        XCTAssertNil(weakParent, "Parent should be deallocated despite being delegate")
        
        child = nil
    }
}
```

### Memory Leak Detection Helper

```swift
class LeakDetector {
    static func track(_ object: AnyObject, file: String = #file, line: Int = #line) {
        weak var weakObject = object
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if weakObject != nil {
                print("⚠️ Potential leak at \(file):\(line)")
            }
        }
    }
}

// Usage
let manager = NetworkManager()
LeakDetector.track(manager)
```

## 🚀 Advanced Debugging

### Using Memory Graph Export

1. Debug → Debug Memory Graph
2. File → Export Memory Graph
3. Open in terminal:
```bash
leaks <path-to-memgraph>
```

### Using malloc_history

```bash
# Enable malloc stack logging
export MallocStackLogging=1

# Run app and get PID
# Then:
malloc_history <PID> <address>
```

### Custom Leak Detection

```swift
#if DEBUG
class LeakTracker {
    static var trackedObjects: [WeakBox] = []
    
    class WeakBox {
        weak var object: AnyObject?
        let name: String
        
        init(object: AnyObject, name: String) {
            self.object = object
            self.name = name
        }
    }
    
    static func track(_ object: AnyObject, name: String) {
        trackedObjects.append(WeakBox(object: object, name: name))
    }
    
    static func checkLeaks() {
        trackedObjects = trackedObjects.filter { $0.object != nil }
        
        if !trackedObjects.isEmpty {
            print("⚠️ Potential leaks:")
            trackedObjects.forEach { box in
                print("  - \(box.name)")
            }
        }
    }
}
#endif

// Usage
let obj = MyObject()
LeakTracker.track(obj, name: "MyObject instance")

// Later
LeakTracker.checkLeaks()
```

## 📝 Checklist for Code Review

- [ ] All delegates are `weak`
- [ ] All protocols used as delegates inherit from `AnyObject`
- [ ] Closures use `[weak self]` or `[unowned self]`
- [ ] Timers are invalidated in `deinit`
- [ ] Notification observers are removed in `deinit`
- [ ] Parent-child relationships use `weak` for child→parent
- [ ] Async operations use weak captures
- [ ] No strong reference cycles between objects
- [ ] `deinit` prints added for testing (remove in production)

## 💡 Pro Tips

1. **Always add `deinit` during development** to verify deallocation
2. **Profile regularly** with Instruments, don't wait for obvious leaks
3. **Test deallocation in unit tests** for critical classes
4. **Use weak by default** for delegates and callbacks
5. **Document why you use unowned** - it's the exception, not the rule
6. **Enable Address Sanitizer** during development (Edit Scheme → Diagnostics)
7. **Run static analyzer** (Product → Analyze) to catch potential issues
8. **Use SwiftLint rules** to enforce weak delegates

## 📚 Additional Resources

- WWDC: "Finding Bugs Using Xcode Runtime Tools"
- WWDC: "iOS Memory Deep Dive"
- Apple Documentation: "Resolving Retain Cycles"
- Instruments User Guide
