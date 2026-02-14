/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 7: CLOSURES AND CAPTURE LISTS
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Capture semantics, escaping vs non-escaping
 Common Interview Question: "Explain closure capture and escaping closures"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Capturing value vs reference

func demonstrateCaptureValueBug() {
    var counter = 0
    
    let increment = {
        counter += 1  // 🐛 Captures 'counter' by reference
        print("Counter: \(counter)")
    }
    
    increment()  // 1
    increment()  // 2
    counter = 10
    increment()  // 11 (not 3! Unexpected!)
    
    // BUG: Developer expected closure to have its own copy of counter
}


// Scenario 2: Capturing in loops (classic bug!)

class TaskManagerBuggy {
    var tasks: [() -> Void] = []
    
    func createTasks() {
        for i in 0..<5 {
            // 🐛 BUG: All closures capture the same 'i'
            tasks.append({
                print("Task \(i)")
            })
        }
    }
    
    func runTasks() {
        for task in tasks {
            task()
        }
        // Expected: Task 0, Task 1, Task 2, Task 3, Task 4
        // Actual: Task 5, Task 5, Task 5, Task 5, Task 5 💥
        // All closures share the same 'i' reference!
    }
}


// Scenario 3: Escaping closure without weak self

class NetworkManagerBuggy {
    var data: String = ""
    var completion: (() -> Void)?
    
    func fetchData() {
        // 🐛 BUG: Strong capture of self in escaping closure
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.data = "Downloaded"  // Retain cycle!
            print("Data: \(self.data)")
        }
    }
    
    deinit {
        print("NetworkManager deinitialized")  // Never called! 💥
    }
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Closures in Swift are reference types and capture values from their
 surrounding context. Common issues:
 
 1. CAPTURE BY REFERENCE: Variables are captured by reference,
    not value. Changes to the variable affect the closure.
 
 2. LOOP CAPTURE BUG: Closures in loops all capture the same
    loop variable reference.
 
 3. RETAIN CYCLES: Closures capture 'self' strongly, creating
    memory leaks if stored in properties.
 
 4. ESCAPING vs NON-ESCAPING:
    - Non-escaping: Closure executes before function returns
    - Escaping: Closure might execute after function returns
    - Escaping closures need explicit 'self'
 
 5. CAPTURE LIST: Syntax to control how values are captured
    [weak self], [unowned self], [value]
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Look for closures capturing 'self' or variables
 2. Check if closure is escaping (stored or async)
 3. Use Memory Graph Debugger for retain cycles
 4. Add print statements in deinit to verify deallocation
 5. Look for loops creating closures
 6. Understand capture vs copy semantics
 
 Compiler warnings:
 - "Reference to property 'x' in closure requires explicit use of 'self'"
 - "Escaping closure captures mutating 'self' parameter"
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Capture value explicitly in capture list

func demonstrateCaptureValueFixed() {
    var counter = 0
    
    // ✅ Capture current VALUE of counter
    let increment = { [counter] in
        // This 'counter' is a copy, immutable
        print("Counter: \(counter)")
    }
    
    increment()  // 0
    counter = 10
    increment()  // Still 0 (captured value)
}

// For mutable capture, capture as mutable copy
func demonstrateMutableCapture() {
    var counter = 0
    
    var increment = { [counter] in
        var counter = counter  // Make local copy mutable
        counter += 1
        print("Counter: \(counter)")
    }
    
    increment()  // 1
    increment()  // 1 (each call uses original captured value)
}


// SOLUTION 2: Fix loop capture bug

class TaskManagerFixed {
    var tasks: [() -> Void] = []
    
    func createTasks_Solution1() {
        for i in 0..<5 {
            // ✅ Capture VALUE of i for each closure
            tasks.append({ [i] in
                print("Task \(i)")
            })
        }
    }
    
    func createTasks_Solution2() {
        // ✅ Alternative: Use forEach with value semantics
        (0..<5).forEach { i in
            tasks.append({
                print("Task \(i)")
            })
        }
    }
    
    func runTasks() {
        for task in tasks {
            task()
        }
        // Now prints: Task 0, Task 1, Task 2, Task 3, Task 4 ✅
    }
}


// SOLUTION 3: Use weak/unowned self for escaping closures

class NetworkManagerFixed {
    var data: String = ""
    
    // SOLUTION 3A: Weak self (safest)
    func fetchData_Weak() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {
                print("Self was deallocated")
                return
            }
            self.data = "Downloaded"
            print("Data: \(self.data)")
        }
    }
    
    // SOLUTION 3B: Unowned self (if you're sure self exists)
    func fetchData_Unowned() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.data = "Downloaded"
            print("Data: \(self.data)")
        }
    }
    
    deinit {
        print("✨ NetworkManager deinitialized")  // Now called!
    }
}


// SOLUTION 4: Understanding escaping vs non-escaping

class ClosureManager {
    // Non-escaping (default): executes before function returns
    func performNonEscaping(operation: () -> Void) {
        operation()  // Executes immediately
    }  // Function returns, closure can't be called anymore
    
    // Escaping: might execute after function returns
    func performEscaping(operation: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            operation()  // Executes later
        }
    }
    
    var storedClosure: (() -> Void)?
    
    // Escaping: closure is stored
    func store(operation: @escaping () -> Void) {
        storedClosure = operation
    }
}


// SOLUTION 5: Capturing multiple values

class ViewControllerFixed {
    var name: String = "HomeVC"
    var viewModel: ViewModel?
    
    func setupMultipleCaptures() {
        let localValue = 42
        
        // ✅ Capture multiple items
        fetchData { [weak self, weak viewModel = self.viewModel, localValue] result in
            guard let self = self else { return }
            
            print("VC: \(self.name)")
            print("ViewModel: \(viewModel?.description ?? "nil")")
            print("Local value: \(localValue)")
        }
    }
    
    func fetchData(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            completion("Success")
        }
    }
}

class ViewModel {
    var description: String = "MainViewModel"
}


// SOLUTION 6: Closure as property (must be escaping)

class Button {
    // Stored closure must be @escaping
    var onTap: (() -> Void)?
    
    func configure(action: @escaping () -> Void) {
        onTap = action
    }
    
    func tap() {
        onTap?()
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample07() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 7: CLOSURES AND CAPTURE LISTS")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Capture by value
    print("Test Case 1: Capture by Value")
    demonstrateCaptureValueFixed()
    print("✅ Closure captures value, not reference\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Loop capture fix
    print("Test Case 2: Loop Capture (Fixed)")
    let taskManager = TaskManagerFixed()
    taskManager.createTasks_Solution1()
    taskManager.runTasks()
    print("✅ Each closure has correct index\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Weak self
    print("Test Case 3: Weak Self (No Retain Cycle)")
    var networkManager: NetworkManagerFixed? = NetworkManagerFixed()
    networkManager?.fetchData_Weak()
    
    Thread.sleep(forTimeInterval: 0.5)
    networkManager = nil  // Deallocate
    print("Set to nil, waiting for closure...")
    Thread.sleep(forTimeInterval: 1)
    print("✅ NetworkManager properly deallocated\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Non-escaping vs escaping
    print("Test Case 4: Non-escaping vs Escaping")
    let manager = ClosureManager()
    
    manager.performNonEscaping {
        print("Non-escaping: Executes immediately")
    }
    
    manager.performEscaping {
        print("Escaping: Executes later")
    }
    
    Thread.sleep(forTimeInterval: 1.5)
    print("✅ Both closure types work correctly\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Closures are REFERENCE TYPES and capture by reference by default
 
 2. Capture list syntax: [weak self, unowned obj, value]
    - Goes before 'in' keyword
    - Can capture multiple items
    - Creates a copy for value types
    - Creates weak/unowned reference for objects
 
 3. When to use each:
    - [weak self]: When self might be deallocated (most common)
    - [unowned self]: When self definitely won't be deallocated
    - [value]: To capture current value, not reference
 
 4. Escaping closures:
    - Mark with @escaping
    - Required when stored or used async
    - Must explicitly capture self
    - Can cause retain cycles
 
 5. Non-escaping closures (default):
    - Execute before function returns
    - Safer (can't cause retain cycles)
    - Don't require @escaping annotation
    - Can use self implicitly
 
 6. Common patterns:
    - Completion handlers: Use [weak self]
    - Animation blocks: Usually safe without capture list
    - forEach/map: Non-escaping, safe to use self
    - Stored closures: Always @escaping, use [weak self]
 
 7. Loop capture bug:
    - Closures in loops capture loop variable by reference
    - All closures share the same variable
    - Fix: Use capture list [i] or forEach
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between escaping and non-escaping closures?"
 A1: Non-escaping closures execute before the function returns and are
     the default. Escaping closures can be stored or called after the
     function returns, marked with @escaping, and require explicit self.
 
 Q2: "Why do escaping closures require @escaping annotation?"
 A2: For optimization and safety. Non-escaping closures can be stack-
     allocated and don't need to manage memory. @escaping makes the
     lifetime requirements explicit.
 
 Q3: "What's the difference between [weak self] and [unowned self]?"
 A3: weak makes self optional and becomes nil when deallocated. unowned
     assumes self always exists and crashes if accessed after deallocation.
     Use weak when unsure, unowned for guaranteed parent-child relationships.
 
 Q4: "Can you explain the loop capture bug?"
 A4: Closures created in a loop capture the loop variable by reference.
     All closures share the same variable, so they all see the final value.
     Fix by capturing the value in a capture list: [i].
 
 Q5: "Why use 'guard let self = self' after [weak self]?"
 A5: Weak self is optional. Guard unwraps it and exits early if nil,
     avoiding repeated optional chaining and ensuring self exists for
     the rest of the closure.
 
 Q6: "Are closures value types or reference types?"
 A6: Reference types. Multiple variables holding the same closure
     reference the same instance. This is why they can cause retain cycles.
*/


// 💡 ADVANCED: Closure Patterns
// ═══════════════════════════════════════════════════════════════════

// Pattern 1: Lazy property with self capture (special case)
class LazyExample {
    var name: String = "Example"
    
    // Lazy closures can capture self without [weak self]
    // because they're only called once
    lazy var description: String = {
        return "Description for \(self.name)"
    }()
}


// Pattern 2: Autoclosure
func logIfDebug(_ message: @autoclosure () -> String) {
    #if DEBUG
    print(message())
    #endif
}

// Usage: logIfDebug("Expensive \(computation())")
// computation() only runs in debug builds


// Pattern 3: Capturing immutable vs mutable
func demonstrateMutabilityCapture() {
    var mutableValue = 10
    let immutableValue = 20
    
    let closure1 = { [mutableValue] in
        // mutableValue is immutable copy here
        // mutableValue += 1  // Error!
        print(mutableValue)
    }
    
    let closure2 = {
        // Captures mutableValue by reference
        print(mutableValue)  // Can see changes
    }
    
    mutableValue = 30
    closure1()  // 10 (captured value)
    closure2()  // 30 (reference)
}


// Pattern 4: Capturing with strong reference temporarily
class TemporaryCaptureExample {
    func performWork() {
        loadData { [weak self] data in
            // Temporarily make self strong for this block
            guard let self = self else { return }
            
            self.process(data)
            self.save()
            // self becomes weak again after block
        }
    }
    
    func loadData(completion: @escaping (String) -> Void) {
        completion("data")
    }
    
    func process(_ data: String) { }
    func save() { }
}


// Uncomment to run:
// runExample07()
