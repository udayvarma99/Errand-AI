/*
 ============================================
 EXAMPLE 10: CLOSURE CAPTURE PROBLEMS
 ============================================
 
 Common Issue: Capturing variables incorrectly in closures
 Apple Interview Focus: Closures, capture lists, escaping vs non-escaping
 */

import Foundation

// ❌ BUGGY CODE - Closure Capture Issues!

class BuggyClosureExamples {
    
    // 🐛 BUG 1: Capturing mutable variable in loop
    func captureInLoop() {
        var closures: [() -> Void] = []
        
        for i in 0..<5 {
            closures.append({
                // 🐛 BUG: All closures capture same 'i' reference
                print("Value: \(i)")
            })
        }
        
        // Execute closures
        print("Buggy loop capture:")
        for closure in closures {
            closure()  // All print "Value: 5" instead of 0,1,2,3,4!
        }
    }
    
    // 🐛 BUG 2: Capturing self in escaping closure (retain cycle)
    var completionHandler: (() -> Void)?
    var name = "BuggyExample"
    
    func setupHandler() {
        // 🐛 BUG: Strong reference cycle
        completionHandler = {
            print("Name: \(self.name)")  // Captures self strongly
            self.doSomething()
        }
        // self holds closure, closure holds self → memory leak!
    }
    
    func doSomething() {
        print("Doing something")
    }
    
    // 🐛 BUG 3: Unexpected value changes
    func unexpectedValueChange() {
        var counter = 0
        
        let increment = {
            counter += 1
            print("Counter: \(counter)")
        }
        
        counter = 10  // Changes before closure executes
        
        increment()  // Prints "Counter: 11" (not 1 as might be expected)
    }
    
    // 🐛 BUG 4: Capturing value vs reference
    func captureConfusion() {
        var numbers = [1, 2, 3]
        
        let closure = {
            // 🐛 BUG: Captures reference to numbers array
            print("Numbers: \(numbers)")
        }
        
        numbers.append(4)  // Modifies array
        
        closure()  // Prints [1, 2, 3, 4], not [1, 2, 3]
    }
    
    // 🐛 BUG 5: Async timing issues
    func asyncCaptureIssue() {
        var value = "Initial"
        
        DispatchQueue.global().async {
            // 🐛 BUG: Value might change before this executes
            print("Async value: \(value)")
        }
        
        value = "Changed"  // Might happen before async block executes
        // Could print either "Initial" or "Changed" - race condition!
    }
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Print captured variable addresses to see if same reference
 2. Use [weak self] or [unowned self] to break retain cycles
 3. Memory graph debugger to detect cycles
 4. Add deinit with print to verify deallocation
 5. Use instruments to check for memory leaks
 6. Understand escaping vs non-escaping closures
 */

// ✅ FIXED CODE - Proper Closure Capture

class FixedClosureExamples {
    
    // FIX 1: Capture value at each iteration
    func captureInLoop_Fixed() {
        var closures: [() -> Void] = []
        
        for i in 0..<5 {
            // Method 1: Capture value explicitly
            closures.append({ [i] in
                print("Value: \(i)")
            })
        }
        
        print("Fixed loop capture (Method 1):")
        for closure in closures {
            closure()  // ✅ Prints 0,1,2,3,4 correctly!
        }
        
        // Method 2: Use local constant
        closures.removeAll()
        for i in 0..<5 {
            let currentValue = i  // Create local copy
            closures.append({
                print("Value: \(currentValue)")
            })
        }
        
        print("\nFixed loop capture (Method 2):")
        for closure in closures {
            closure()
        }
    }
    
    // FIX 2: Use [weak self] to prevent retain cycle
    var completionHandler: (() -> Void)?
    var name = "FixedExample"
    
    func setupHandler_Weak() {
        // ✅ Use weak self
        completionHandler = { [weak self] in
            guard let self = self else { return }
            print("Name: \(self.name)")
            self.doSomething()
        }
        // No retain cycle - closure holds weak reference
    }
    
    // Alternative: [unowned self] if you're certain self outlives closure
    func setupHandler_Unowned() {
        completionHandler = { [unowned self] in
            print("Name: \(self.name)")
            self.doSomething()
        }
    }
    
    func doSomething() {
        print("Doing something")
    }
    
    // FIX 3: Capture value explicitly
    func fixedValueChange() {
        var counter = 0
        
        // Capture current value of counter
        let increment = { [counter] in
            var mutableCounter = counter
            mutableCounter += 1
            print("Counter: \(mutableCounter)")
        }
        
        counter = 10  // Doesn't affect captured value
        
        increment()  // ✅ Prints "Counter: 1" (captured 0, then +1)
    }
    
    // Alternative: Capture as constant
    func fixedValueChange_Alt() {
        var counter = 0
        let capturedValue = counter  // Explicit copy
        
        let increment = {
            print("Counter: \(capturedValue + 1)")
        }
        
        counter = 10
        increment()  // ✅ Prints "Counter: 1"
    }
    
    // FIX 4: Capture value copy for value types
    func captureValue_Fixed() {
        var numbers = [1, 2, 3]
        
        // Capture copy of array
        let closure = { [numbers] in
            print("Numbers: \(numbers)")
        }
        
        numbers.append(4)
        
        closure()  // ✅ Prints [1, 2, 3] (captured copy)
        print("Current numbers: \(numbers)")  // [1, 2, 3, 4]
    }
    
    // FIX 5: Capture value for async operations
    func asyncCapture_Fixed() {
        var value = "Initial"
        let capturedValue = value  // Capture current value
        
        DispatchQueue.global().async {
            // ✅ Uses captured value, immune to changes
            print("Async value: \(capturedValue)")
        }
        
        value = "Changed"
        print("Main value: \(value)")
    }
}

// Advanced capture scenarios
class AdvancedClosureExamples {
    
    // Escaping vs non-escaping closures
    func nonEscapingClosure(completion: () -> Void) {
        // Non-escaping: executes before function returns
        completion()
    }
    
    func escapingClosure(completion: @escaping () -> Void) {
        // Escaping: might execute after function returns
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }
    
    // Autoclosure
    func logIf(_ condition: Bool, message: @autoclosure () -> String) {
        if condition {
            print(message())  // Only evaluated if condition is true
        }
    }
    
    // Multiple captures in one closure
    var delegate: AnyObject?
    var value: Int = 0
    
    func complexCapture() {
        // Capture self weakly, value as copy
        let closure = { [weak self, value] in
            guard let self = self else { return }
            print("Value: \(value), Current: \(self.value)")
        }
        
        value = 10
        closure()  // Prints captured value (0), current value (10)
    }
    
    // Capturing in nested closures
    func nestedClosures() {
        let outer = { [weak self] in
            guard let self = self else { return }
            
            // In nested closure, need to capture again or use self
            let inner = {
                // Still has access to self from outer scope
                print("Nested value: \(self.value)")
            }
            
            inner()
        }
        
        outer()
    }
    
    // Function returning closure
    func makeIncrementer(increment: Int) -> () -> Int {
        var total = 0
        
        // Closure captures 'total' and 'increment'
        return {
            total += increment
            return total
        }
    }
    
    // Closure as property
    lazy var expensiveComputation: () -> Int = { [unowned self] in
        // Compute something expensive once
        return self.value * 100
    }
}

// Practical examples
class NetworkManager {
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    
    private var handlers: [CompletionHandler] = []
    
    // ✅ Proper escaping closure
    func fetchData(completion: @escaping CompletionHandler) {
        handlers.append(completion)
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Simulate network request
            let success = Bool.random()
            
            DispatchQueue.main.async {
                if success {
                    completion(.success(Data()))
                } else {
                    completion(.failure(NSError(domain: "Network", code: -1)))
                }
            }
        }
    }
}

class ViewControllerSimulation {
    var isLoading = false
    var data: [String] = []
    
    func loadData() {
        isLoading = true
        
        // ✅ Weak self in async operation
        NetworkManager().fetchData { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let data):
                print("Loaded \(data.count) bytes")
                self.updateUI()
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func updateUI() {
        print("Updating UI with \(data.count) items")
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== CLOSURE CAPTURE EXAMPLES ===\n")
    
    print("--- Buggy loop capture ---")
    let buggy = BuggyClosureExamples()
    buggy.captureInLoop()
    
    print("\n--- Fixed loop capture ---")
    let fixed = FixedClosureExamples()
    fixed.captureInLoop_Fixed()
    
    print("\n--- Fixed value capture ---")
    fixed.fixedValueChange()
    
    print("\n--- Array capture ---")
    fixed.captureValue_Fixed()
    
    print("\n--- Async capture ---")
    fixed.asyncCapture_Fixed()
    Thread.sleep(forTimeInterval: 0.1)
    
    print("\n--- Advanced examples ---")
    let advanced = AdvancedClosureExamples()
    
    advanced.logIf(true, message: "This is logged")
    advanced.logIf(false, message: "This is not logged")
    
    advanced.complexCapture()
    
    print("\n--- Incrementer closure ---")
    let incrementBy5 = advanced.makeIncrementer(increment: 5)
    print("Increment: \(incrementBy5())")  // 5
    print("Increment: \(incrementBy5())")  // 10
    print("Increment: \(incrementBy5())")  // 15
    
    print("\n--- View controller simulation ---")
    let vc = ViewControllerSimulation()
    vc.loadData()
    Thread.sleep(forTimeInterval: 0.2)
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. Closures capture variables by REFERENCE by default
 2. Use capture lists [var1, var2] to capture by value
 3. Use [weak self] to prevent retain cycles
 4. Use [unowned self] when you're certain self outlives closure
 5. @escaping closures outlive function scope
 6. Capture lists create immutable copies
 7. Value types (struct) are copied, reference types aren't
 
 🎯 CAPTURE LIST SYNTAX:
 
 // Basic capture
 let closure = { [weak self] in
     guard let self = self else { return }
     self.method()
 }
 
 // Multiple captures
 let closure = { [weak self, weak delegate, value] in
     // weak self, weak delegate, value copied
 }
 
 // Rename in capture
 let closure = { [weak self, original = value] in
     guard let self = self else { return }
     print(original)  // Captured as 'original'
 }
 
 ⚠️  COMMON CLOSURE MISTAKES:
 
 1. Not using [weak self] in escaping closures
 2. Capturing loop variables by reference
 3. Assuming value captures for reference types
 4. Forgetting @escaping for stored closures
 5. Using [unowned self] when not safe
 6. Not understanding when closures execute
 
 💡 WEAK vs UNOWNED:
 
 [weak self]:
 - self becomes optional
 - Safe - won't crash if deallocated
 - Need guard let or if let
 - Use when unsure about lifetime
 
 [unowned self]:
 - self is non-optional
 - Crashes if accessed after deallocation
 - No unwrapping needed
 - Use only when certain about lifetime
 
 🛠️  ESCAPING vs NON-ESCAPING:
 
 // Non-escaping (default)
 func process(closure: () -> Void) {
     closure()  // Executes immediately
 }
 
 // Escaping
 func processLater(closure: @escaping () -> Void) {
     DispatchQueue.main.async {
         closure()  // Executes later
     }
 }
 
 var stored: (() -> Void)?
 func store(closure: @escaping () -> Void) {
     stored = closure  // Must be @escaping
 }
 
 ⚡ CLOSURE BEST PRACTICES:
 
 1. Always use [weak self] in async operations
 2. Capture specific values you need, not entire object
 3. Use guard let pattern for weak self
 4. Be explicit about what you're capturing
 5. Understand value vs reference semantics
 6. Document why using [unowned self] if you do
 
 🎓 ADVANCED CONCEPTS:
 
 // Autoclosure
 func assert(_ condition: @autoclosure () -> Bool) {
     if !condition() {
         fatalError()
     }
 }
 assert(x > 0)  // Looks like boolean, actually closure
 
 // Closure type aliases
 typealias Handler = (Result<Data, Error>) -> Void
 
 // Returning closures
 func makeHandler() -> () -> Void {
     var count = 0
     return { count += 1; print(count) }
 }
 
 // Closure parameters
 func transform<T>(_ value: T, using: (T) -> T) -> T {
     return using(value)
 }
 
 🏗️  REAL-WORLD PATTERNS:
 
 // Network completion handlers
 func fetch(completion: @escaping (Result<Data, Error>) -> Void) {
     URLSession.shared.dataTask(with: url) { data, _, error in
         if let error = error {
             completion(.failure(error))
         } else if let data = data {
             completion(.success(data))
         }
     }.resume()
 }
 
 // Animation completion
 UIView.animate(withDuration: 1.0) { [weak self] in
     self?.view.alpha = 0
 } completion: { [weak self] _ in
     self?.view.removeFromSuperview()
 }
 
 // Map, filter, reduce
 let doubled = numbers.map { $0 * 2 }
 let evens = numbers.filter { $0 % 2 == 0 }
 let sum = numbers.reduce(0) { $0 + $1 }
 
 ⚠️  INTERVIEW WARNING SIGNS:
 
 - Closure that might outlive self without [weak self]
 - Storing closures without @escaping
 - Capturing loop variable by reference
 - Not handling deallocated self in async code
 - Using [unowned self] without justification
 */

// Run demonstrations
demonstrateFix()
