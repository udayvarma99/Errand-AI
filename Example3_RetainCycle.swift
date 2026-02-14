/*
 ============================================
 EXAMPLE 3: MEMORY LEAKS (RETAIN CYCLES)
 ============================================
 
 Common Issue: Strong reference cycles prevent deallocation
 Apple Interview Focus: Understanding ARC and memory management
 */

import Foundation

// ❌ BUGGY CODE - Memory Leak!

class BuggyViewController {
    var name: String
    var dataHandler: (() -> Void)?
    
    init(name: String) {
        self.name = name
        print("✅ \(name) initialized")
    }
    
    deinit {
        print("♻️  \(name) deinitialized")  // This won't be called due to retain cycle!
    }
    
    func setupHandler() {
        // 🐛 BUG: Strong reference cycle - self captures closure, closure captures self
        dataHandler = {
            print("Data from \(self.name)")  // self is strongly captured
            self.processData()
        }
    }
    
    func processData() {
        print("Processing data...")
    }
}

class BuggyParent {
    var name: String
    var child: BuggyChild?
    
    init(name: String) {
        self.name = name
        print("✅ Parent \(name) initialized")
    }
    
    deinit {
        print("♻️  Parent \(name) deinitialized")  // Won't be called!
    }
}

class BuggyChild {
    var name: String
    var parent: BuggyParent?  // 🐛 BUG: Strong reference to parent
    
    init(name: String) {
        self.name = name
        print("✅ Child \(name) initialized")
    }
    
    deinit {
        print("♻️  Child \(name) deinitialized")  // Won't be called!
    }
}

// Example of the memory leak:
func demonstrateBug() {
    print("=== Creating buggy objects ===")
    do {
        let vc = BuggyViewController(name: "BuggyVC")
        vc.setupHandler()
        // When vc goes out of scope, it won't be deallocated!
    }
    
    do {
        let parent = BuggyParent(name: "BuggyParent")
        let child = BuggyChild(name: "BuggyChild")
        parent.child = child
        child.parent = parent  // Creates retain cycle
        // Neither will be deallocated!
    }
    
    print("=== Objects should be deallocated here, but they won't be ===\n")
    // You won't see deinit messages - objects are leaked!
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Use Xcode Memory Graph Debugger (Debug Navigator → Memory)
 2. Look for purple exclamation marks (retain cycles)
 3. Use Instruments → Leaks tool
 4. Check if deinit is called (add print statements)
 5. Enable malloc stack logging in scheme
 6. Use weak/unowned references appropriately
 */

// ✅ FIXED CODE - No Memory Leaks

class FixedViewController {
    var name: String
    var dataHandler: (() -> Void)?
    
    init(name: String) {
        self.name = name
        print("✅ \(name) initialized")
    }
    
    deinit {
        print("♻️  \(name) deinitialized")  // This WILL be called now!
    }
    
    // SOLUTION 1: Use [weak self] in closures
    func setupHandlerWithWeak() {
        dataHandler = { [weak self] in
            guard let self = self else { return }
            print("Data from \(self.name)")
            self.processData()
        }
    }
    
    // SOLUTION 2: Use [unowned self] when you're sure self will outlive the closure
    func setupHandlerWithUnowned() {
        dataHandler = { [unowned self] in
            print("Data from \(self.name)")
            self.processData()
        }
    }
    
    // SOLUTION 3: Capture specific properties instead of self
    func setupHandlerCaptureProperty() {
        let name = self.name  // Capture just the string
        dataHandler = {
            print("Data from \(name)")
            // Can't call self.processData() here, which is safer
        }
    }
    
    func processData() {
        print("Processing data...")
    }
}

class FixedParent {
    var name: String
    var child: FixedChild?
    
    init(name: String) {
        self.name = name
        print("✅ Parent \(name) initialized")
    }
    
    deinit {
        print("♻️  Parent \(name) deinitialized")  // Will be called!
    }
}

class FixedChild {
    var name: String
    weak var parent: FixedParent?  // ✅ FIX: weak reference breaks the cycle
    
    init(name: String) {
        self.name = name
        print("✅ Child \(name) initialized")
    }
    
    deinit {
        print("♻️  Child \(name) deinitialized")  // Will be called!
    }
}

// More complex example: Delegate pattern
protocol DataManagerDelegate: AnyObject {  // Must be AnyObject for weak references
    func dataDidUpdate(_ data: String)
}

class FixedDataManager {
    weak var delegate: DataManagerDelegate?  // ✅ Always weak for delegates!
    
    func fetchData() {
        delegate?.dataDidUpdate("New data")
    }
}

class FixedController: DataManagerDelegate {
    let dataManager = FixedDataManager()
    
    init() {
        dataManager.delegate = self  // No retain cycle because delegate is weak
        print("✅ Controller initialized")
    }
    
    deinit {
        print("♻️  Controller deinitialized")
    }
    
    func dataDidUpdate(_ data: String) {
        print("Received: \(data)")
    }
}

// Example with lazy properties and closures
class FixedLazyExample {
    var name: String = "LazyExample"
    
    init() {
        print("✅ LazyExample initialized")
    }
    
    deinit {
        print("♻️  LazyExample deinitialized")
    }
    
    // CORRECT: Lazy closure with [weak self] or [unowned self]
    lazy var computedValue: String = { [unowned self] in
        return "Value from \(self.name)"
    }()
    
    // ALTERNATIVE: Lazy closure that doesn't capture self
    lazy var simpleValue: String = {
        return "Simple value"
    }()
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== Creating fixed objects ===")
    
    do {
        let vc = FixedViewController(name: "FixedVC")
        vc.setupHandlerWithWeak()
        print("About to leave scope...")
    }
    print("Should see deinit above\n")
    
    do {
        let parent = FixedParent(name: "FixedParent")
        let child = FixedChild(name: "FixedChild")
        parent.child = child
        child.parent = parent  // No retain cycle - parent is weak
        print("About to leave scope...")
    }
    print("Should see both deinits above\n")
    
    do {
        let controller = FixedController()
        controller.dataManager.fetchData()
        print("About to leave scope...")
    }
    print("Should see deinit above\n")
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. USE [weak self] in closures that might outlive the object
 2. USE [unowned self] only when you're CERTAIN self will outlive the closure
 3. Delegates should ALWAYS be weak
 4. Parent-child relationships: parent strong, child weak to parent
 5. Closures create strong references to captured variables by default
 6. Protocols for delegates must be AnyObject (class-only)
 
 🎯 WHEN TO USE EACH:
 
 - weak: When the referenced object might be deallocated first
        (delegates, parent references, optional closures)
 - unowned: When you're certain the referenced object will outlive the reference
           (Use with caution! Can crash if object is deallocated)
 - strong: Default, when you want to keep the object alive
 
 ⚠️  WEAK vs UNOWNED:
 
 weak:
 - Always optional (can become nil)
 - Safe (won't crash if object is deallocated)
 - Slightly more overhead
 - Use when unsure
 
 unowned:
 - Non-optional (assumes always exists)
 - Crashes if accessed after deallocation
 - Slightly less overhead
 - Use only when certain object outlives reference
 
 💡 COMMON RETAIN CYCLE SCENARIOS:
 
 1. Closures capturing self
 2. Delegate patterns
 3. Parent-child object relationships
 4. Observers and notifications
 5. Completion handlers
 6. Timer targets
 
 🛠️  DEBUGGING TIPS:
 
 - Add deinit with print to verify deallocation
 - Use Memory Graph Debugger in Xcode
 - Run Instruments → Leaks
 - Look for purple ! in Memory Graph (indicates cycle)
 - Check reference count with CFGetRetainCount (debugging only)
 
 ⚡ INTERVIEW PATTERN:
 
 Whenever you write a closure that captures self, ask:
 "Could this closure outlive self?"
 If yes → use [weak self]
 If no, but it's a delegate → still use weak
 If absolutely certain self outlives closure → [unowned self]
 */

// Run demonstrations
print("🐛 BUGGY VERSION (Memory Leaks):")
demonstrateBug()

print("\n✅ FIXED VERSION (No Memory Leaks):")
demonstrateFix()
