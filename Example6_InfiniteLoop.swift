/*
 ============================================
 EXAMPLE 6: INFINITE LOOPS
 ============================================
 
 Common Issue: Loops that never terminate, freezing the app
 Apple Interview Focus: Loop conditions, algorithm correctness
 */

import Foundation

// ❌ BUGGY CODE - Infinite Loops!

class BuggyLoopExamples {
    
    // 🐛 BUG 1: Condition never becomes false
    func infiniteWhileLoop() {
        var counter = 0
        while counter >= 0 {  // counter will always be >= 0!
            print("Counter: \(counter)")
            counter += 1  // Making it worse - counter increases forever!
            // This loop never ends!
        }
    }
    
    // 🐛 BUG 2: Loop variable not updated
    func forgottenIncrement() {
        var i = 0
        while i < 10 {
            print("i = \(i)")
            // Forgot to increment i!
            // i stays 0 forever
        }
    }
    
    // 🐛 BUG 3: Wrong increment direction
    func wrongDirection() {
        var countdown = 10
        while countdown > 0 {
            print("Countdown: \(countdown)")
            countdown += 1  // Should be -= 1
            // countdown increases instead of decreasing!
        }
    }
    
    // 🐛 BUG 4: Array modification during iteration
    func modifyWhileIterating() {
        var numbers = [1, 2, 3, 4, 5]
        var index = 0
        
        while index < numbers.count {
            print("Processing: \(numbers[index])")
            numbers.append(index * 10)  // Array keeps growing!
            index += 1
            // numbers.count keeps increasing, so loop never ends
        }
    }
    
    // 🐛 BUG 5: Incorrect loop condition with floats
    func floatingPointIssue() {
        var value = 0.0
        while value != 1.0 {  // Float equality is problematic!
            value += 0.1
            print("Value: \(value)")
            // Due to floating-point precision, value might never equal exactly 1.0
        }
    }
    
    // 🐛 BUG 6: Nested loop with wrong break
    func wrongBreakScope() {
        var found = false
        
        while !found {
            for i in 1...5 {
                print("Checking \(i)")
                if i == 3 {
                    break  // Only breaks inner loop, not outer!
                }
            }
            // found is never set to true - outer loop infinite!
        }
    }
}

// Examples are commented out to prevent hanging
func demonstrateBug() {
    print("=== INFINITE LOOP EXAMPLES ===")
    print("⚠️  All buggy examples are commented out to prevent hanging\n")
    
    // DON'T RUN THESE - THEY WILL HANG!
    // let buggy = BuggyLoopExamples()
    // buggy.infiniteWhileLoop()
    // buggy.forgottenIncrement()
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Add a counter and max iterations limit during development
 2. Add print statements to see if loop is progressing
 3. Use Xcode's "Pause" button when app hangs
 4. Check the call stack - you'll see the infinite loop
 5. Use debugger to step through loop iterations
 6. Add assertions: assert(iterations < 1000, "Too many iterations")
 7. Use watchpoints to monitor variable changes
 8. Profile with Instruments to see CPU usage
 */

// ✅ FIXED CODE - Safe Loop Patterns

class FixedLoopExamples {
    
    // FIX 1: Correct loop condition
    func correctWhileLoop() {
        var counter = 0
        let maxCount = 10
        
        while counter < maxCount {  // Clear termination condition
            print("Counter: \(counter)")
            counter += 1
        }
        print("Loop completed at \(counter)")
    }
    
    // FIX 2: Always update loop variable
    func properIncrement() {
        var i = 0
        while i < 10 {
            print("i = \(i)")
            i += 1  // Don't forget this!
        }
    }
    
    // FIX 3: Correct increment direction
    func correctCountdown() {
        var countdown = 10
        while countdown > 0 {
            print("Countdown: \(countdown)")
            countdown -= 1  // Correct direction
        }
        print("Blastoff! 🚀")
    }
    
    // FIX 4: Don't modify collection while iterating (or use different approach)
    func safeIteration() {
        let numbers = [1, 2, 3, 4, 5]
        var results: [Int] = []
        
        // Iterate over copy, modify separate array
        for (index, number) in numbers.enumerated() {
            print("Processing: \(number)")
            results.append(index * 10)
        }
        
        print("Results: \(results)")
    }
    
    // FIX 5: Floating-point comparison with tolerance
    func safeFloatingPoint() {
        var value = 0.0
        let target = 1.0
        let tolerance = 0.001
        
        while abs(value - target) > tolerance {
            value += 0.1
            print("Value: \(value)")
            
            // Safety: max iterations
            if value > 2.0 {
                print("Safety limit reached")
                break
            }
        }
        print("Final value: \(value)")
    }
    
    // Alternative: Use stride for floating point
    func betterFloatingPoint() {
        for value in stride(from: 0.0, through: 1.0, by: 0.1) {
            print("Value: \(value)")
        }
    }
    
    // FIX 6: Labeled statements for nested loops
    func correctNestedLoopBreak() {
        var found = false
        
        outerLoop: while !found {
            for i in 1...5 {
                print("Checking \(i)")
                if i == 3 {
                    found = true
                    break outerLoop  // Breaks outer loop!
                }
            }
        }
        print("Found!")
    }
    
    // BEST PRACTICE: Use for-in instead of while when possible
    func preferForIn() {
        // Instead of while with counter, use for-in
        for i in 0..<10 {
            print("i = \(i)")
        }
        // Guaranteed to terminate!
    }
    
    // SAFETY PATTERN: Add maximum iterations guard
    func withSafetyLimit() {
        var attempts = 0
        let maxAttempts = 1000
        var condition = true
        
        while condition && attempts < maxAttempts {
            // Do work
            attempts += 1
            
            // Your logic here
            if attempts > 5 {
                condition = false
            }
        }
        
        if attempts >= maxAttempts {
            print("⚠️  Safety limit reached - possible infinite loop!")
        }
    }
    
    // Pattern: Searching with guaranteed termination
    func findValue(in array: [Int], target: Int) -> Int? {
        var index = 0
        
        while index < array.count {  // Clear limit: array.count
            if array[index] == target {
                return index
            }
            index += 1
        }
        
        return nil  // Not found
    }
    
    // Better: Use built-in methods
    func findValueBetter(in array: [Int], target: Int) -> Int? {
        return array.firstIndex(of: target)
    }
}

// Advanced: Recursion that could be infinite
class RecursionExamples {
    
    // ❌ BAD: No base case
    func infiniteRecursion(_ n: Int) {
        print(n)
        infiniteRecursion(n + 1)  // No stop condition!
    }
    
    // ✅ GOOD: Clear base case
    func factorial(_ n: Int) -> Int {
        // Base case: stops recursion
        if n <= 1 {
            return 1
        }
        // Recursive case: makes progress toward base case
        return n * factorial(n - 1)
    }
    
    // ✅ GOOD: With depth limit for safety
    func recursiveSearch(_ value: Int, depth: Int = 0, maxDepth: Int = 100) -> Bool {
        guard depth < maxDepth else {
            print("⚠️  Max recursion depth reached")
            return false
        }
        
        // Base case
        if value == 0 {
            return true
        }
        
        // Recursive case
        return recursiveSearch(value - 1, depth: depth + 1, maxDepth: maxDepth)
    }
}

// Real-world example: Network retry logic
class NetworkManager {
    
    // ❌ BAD: Could retry forever
    func retryForeverBuggy(completion: @escaping (Bool) -> Void) {
        func attemptRequest() {
            // Simulate network request
            let success = Bool.random()
            
            if success {
                completion(true)
            } else {
                // Bug: keeps retrying forever!
                attemptRequest()
            }
        }
        
        attemptRequest()
    }
    
    // ✅ GOOD: Limited retries
    func retryWithLimit(maxRetries: Int = 3, completion: @escaping (Bool) -> Void) {
        var attempts = 0
        
        func attemptRequest() {
            attempts += 1
            
            // Simulate network request
            let success = Bool.random()
            
            if success {
                completion(true)
            } else if attempts < maxRetries {
                print("Retry \(attempts)/\(maxRetries)")
                attemptRequest()
            } else {
                print("Max retries reached")
                completion(false)
            }
        }
        
        attemptRequest()
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== FIXED LOOP EXAMPLES ===\n")
    
    let fixed = FixedLoopExamples()
    
    print("--- Correct while loop ---")
    fixed.correctWhileLoop()
    
    print("\n--- Countdown ---")
    fixed.correctCountdown()
    
    print("\n--- Safe iteration ---")
    fixed.safeIteration()
    
    print("\n--- Floating point with tolerance ---")
    fixed.safeFloatingPoint()
    
    print("\n--- Better floating point (stride) ---")
    fixed.betterFloatingPoint()
    
    print("\n--- Nested loop with labeled break ---")
    fixed.correctNestedLoopBreak()
    
    print("\n--- Finding value ---")
    let array = [5, 2, 8, 1, 9]
    if let index = fixed.findValue(in: array, target: 8) {
        print("Found 8 at index \(index)")
    }
    
    print("\n--- Recursion examples ---")
    let recursion = RecursionExamples()
    print("5! = \(recursion.factorial(5))")
    
    print("\n--- Network retry ---")
    let network = NetworkManager()
    network.retryWithLimit { success in
        print("Request \(success ? "succeeded" : "failed")")
    }
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. ALWAYS ensure loop conditions will eventually become false
 2. Prefer for-in over while when you know iteration count
 3. Add safety limits (max iterations) during development
 4. Be careful with floating-point equality
 5. Use labeled statements for nested loop breaks
 6. Don't modify collections while iterating over them
 7. Ensure recursive functions have clear base cases
 
 🎯 LOOP SAFETY CHECKLIST:
 
 ✓ Does the loop variable change toward the termination condition?
 ✓ Is the termination condition actually reachable?
 ✓ Are floating-point comparisons using tolerance?
 ✓ Is there a maximum iteration safety limit?
 ✓ For recursion: Is there a base case?
 ✓ Am I modifying the collection I'm iterating over?
 
 ⚠️  COMMON INFINITE LOOP CAUSES:
 
 1. Loop variable never updated
 2. Loop variable updated in wrong direction
 3. Condition can never be false
 4. Floating-point equality issues
 5. Collection growing during iteration
 6. Missing recursion base case
 7. Wrong break statement scope
 
 💡 BEST PRACTICES:
 
 // ❌ AVOID
 var i = 0
 while i < 10 {
     // ... might forget to increment i
 }
 
 // ✅ PREFER
 for i in 0..<10 {
     // Guaranteed to terminate
 }
 
 // ✅ WHILE with safety
 var attempts = 0
 while condition && attempts < MAX_ATTEMPTS {
     attempts += 1
     // ...
 }
 
 🛠️  DEBUGGING INFINITE LOOPS:
 
 1. Click "Pause" in Xcode when app hangs
 2. Look at the thread stack - you'll see the loop
 3. Check variable values in debugger
 4. Add print before loop: "Entering loop with condition..."
 5. Add print in loop: "Iteration \(i) of \(max)"
 6. Set breakpoint with condition and action
 
 ⚡ INTERVIEW PATTERNS:
 
 // Safe search pattern
 var index = 0
 while index < array.count {
     if array[index] == target {
         return index
     }
     index += 1  // Progress toward termination
 }
 
 // Safe countdown pattern
 var remaining = n
 while remaining > 0 {
     // work
     remaining -= 1  // Progress toward termination
 }
 
 // Safe retry pattern
 var attempts = 0
 while !success && attempts < maxAttempts {
     success = tryOperation()
     attempts += 1
 }
 
 🎓 ADVANCED CONSIDERATIONS:
 
 - Time complexity: O(n) vs O(n²) vs O(∞)
 - Termination proofs in algorithms
 - Loop invariants
 - Tail recursion optimization
 - Iterative vs recursive solutions
 */

// Run demonstrations
print("🐛 BUGGY VERSION:")
demonstrateBug()

print("\n" + String(repeating: "=", count: 50) + "\n")
demonstrateFix()
