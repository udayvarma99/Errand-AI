/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 4: THREAD SAFETY ISSUES
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Race conditions and synchronization
 Common Interview Question: "How do you handle thread safety in Swift?"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

class BankAccountBuggy {
    private var balance: Double = 1000.0
    
    // 🐛 Not thread-safe!
    func withdraw(amount: Double) {
        if balance >= amount {
            // Simulate some processing time
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("💰 Withdrew \(amount), balance: \(balance)")
        } else {
            print("⚠️  Insufficient funds")
        }
    }
    
    func getBalance() -> Double {
        return balance  // 🐛 Not thread-safe read
    }
}

// BUG: Race condition when multiple threads access simultaneously
func demonstrateRaceCondition() {
    let account = BankAccountBuggy()
    let queue = DispatchQueue(label: "com.example.account", attributes: .concurrent)
    
    // Multiple threads trying to withdraw simultaneously
    for i in 1...10 {
        queue.async {
            account.withdraw(amount: 200)  // 💥 Race condition!
        }
    }
    
    // Results are unpredictable:
    // - Balance might go negative
    // - Balance might be incorrect
    // - Some withdrawals might be lost
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 A race condition occurs when multiple threads access shared mutable
 state without proper synchronization. This leads to:
 
 1. Data corruption (incorrect values)
 2. Unpredictable behavior
 3. Crashes (especially with collections)
 4. Lost updates
 
 In this example:
 - Thread A checks balance (1000 >= 200) ✓
 - Thread B checks balance (1000 >= 200) ✓
 - Thread A withdraws 200 (balance = 800)
 - Thread B withdraws 200 (balance = 600... should be 800!)
 - Both think they have enough money
 - Account goes negative or loses transactions
 
 This is called a "check-then-act" race condition.
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Look for shared mutable state accessed from multiple threads
 2. Use Thread Sanitizer (Edit Scheme → Diagnostics → Thread Sanitizer)
 3. Add assertions to detect invalid states
 4. Use print statements with thread info
 5. Test with high concurrency
 
 Thread Sanitizer:
 - Detects data races at runtime
 - Shows exact line where race occurs
 - Reports both conflicting accesses
 - Purple warning icon in Xcode
 
 Print thread info:
 print("Thread: \(Thread.current)")
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Serial Dispatch Queue (most common)
class BankAccountFixed_SerialQueue {
    private var balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.example.account")
    
    func withdraw(amount: Double) {
        queue.sync {  // ✅ Serialize access
            if balance >= amount {
                Thread.sleep(forTimeInterval: 0.001)
                balance -= amount
                print("✅ Withdrew \(amount), balance: \(balance)")
            } else {
                print("⚠️  Insufficient funds")
            }
        }
    }
    
    func getBalance() -> Double {
        return queue.sync {
            return balance
        }
    }
}


// SOLUTION 2: NSLock (more traditional)
class BankAccountFixed_Lock {
    private var balance: Double = 1000.0
    private let lock = NSLock()
    
    func withdraw(amount: Double) {
        lock.lock()
        defer { lock.unlock() }  // ✅ Always unlock, even on early return
        
        if balance >= amount {
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("🔒 Withdrew \(amount), balance: \(balance)")
        } else {
            print("⚠️  Insufficient funds")
        }
    }
    
    func getBalance() -> Double {
        lock.lock()
        defer { lock.unlock() }
        return balance
    }
}


// SOLUTION 3: Actor (Swift 5.5+, Modern Approach)
@available(macOS 10.15, iOS 13.0, *)
actor BankAccountFixed_Actor {
    private var balance: Double = 1000.0
    
    // ✅ Actor automatically serializes access
    func withdraw(amount: Double) async {
        if balance >= amount {
            try? await Task.sleep(nanoseconds: 1_000_000)
            balance -= amount
            print("🎭 Withdrew \(amount), balance: \(balance)")
        } else {
            print("⚠️  Insufficient funds")
        }
    }
    
    func getBalance() -> Double {
        return balance
    }
}


// SOLUTION 4: Concurrent Queue with Barriers (read-write optimization)
class BankAccountFixed_Barrier {
    private var balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.example.account", 
                                       attributes: .concurrent)
    
    func withdraw(amount: Double) {
        queue.async(flags: .barrier) {  // ✅ Exclusive write access
            if self.balance >= amount {
                Thread.sleep(forTimeInterval: 0.001)
                self.balance -= amount
                print("🚧 Withdrew \(amount), balance: \(self.balance)")
            } else {
                print("⚠️  Insufficient funds")
            }
        }
    }
    
    func getBalance() -> Double {
        return queue.sync {  // ✅ Concurrent read access
            return balance
        }
    }
}


// 🚨 COMMON PITFALL: Collection Modifications
// ═══════════════════════════════════════════════════════════════════

class UserManagerBuggy {
    private var users: [String] = []
    
    // 🐛 Not thread-safe!
    func addUser(_ name: String) {
        users.append(name)  // 💥 Crash if modified from multiple threads
    }
}

class UserManagerFixed {
    private var users: [String] = []
    private let queue = DispatchQueue(label: "com.example.users")
    
    func addUser(_ name: String) {
        queue.async(flags: .barrier) {
            self.users.append(name)  // ✅ Thread-safe
        }
    }
    
    func getAllUsers() -> [String] {
        return queue.sync {
            return users  // Returns a copy
        }
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample04() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 4: THREAD SAFETY ISSUES")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Buggy version (may show race condition)
    print("Test Case 1: Buggy Version (Race Condition)")
    print("Initial balance: 1000")
    print("10 threads each withdrawing 200...\n")
    
    let buggyAccount = BankAccountBuggy()
    let group1 = DispatchGroup()
    
    for _ in 1...10 {
        group1.enter()
        DispatchQueue.global().async {
            buggyAccount.withdraw(amount: 200)
            group1.leave()
        }
    }
    
    group1.wait()
    print("Final balance (buggy): \(buggyAccount.getBalance())")
    print("Expected: -1000 (all withdrew) or 800 (only 1 succeeded)")
    print("⚠️  Result is unpredictable!\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Fixed version with serial queue
    print("Test Case 2: Fixed with Serial Queue")
    print("Initial balance: 1000")
    print("10 threads each withdrawing 200...\n")
    
    let fixedAccount = BankAccountFixed_SerialQueue()
    let group2 = DispatchGroup()
    
    for _ in 1...10 {
        group2.enter()
        DispatchQueue.global().async {
            fixedAccount.withdraw(amount: 200)
            group2.leave()
        }
    }
    
    group2.wait()
    print("\nFinal balance (fixed): \(fixedAccount.getBalance())")
    print("✅ Consistent result!\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Fixed with lock
    print("Test Case 3: Fixed with NSLock")
    let lockAccount = BankAccountFixed_Lock()
    let group3 = DispatchGroup()
    
    for _ in 1...5 {
        group3.enter()
        DispatchQueue.global().async {
            lockAccount.withdraw(amount: 200)
            group3.leave()
        }
    }
    
    group3.wait()
    print("Final balance: \(lockAccount.getBalance())\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Thread safety is about protecting shared mutable state
 
 2. Common synchronization tools:
    - Serial DispatchQueue (easiest, most common)
    - NSLock / NSRecursiveLock (traditional)
    - Actors (modern Swift, preferred)
    - Concurrent queue with barriers (optimization)
    - @Atomic property wrappers (custom)
 
 3. When to use each:
    - Serial Queue: Simple synchronization, async work
    - NSLock: Simple synchronization, sync work
    - Actor: Swift concurrency, async/await code
    - Barriers: Many reads, few writes
 
 4. Common race condition patterns:
    - Check-then-act (check balance, then withdraw)
    - Read-modify-write (count += 1)
    - Collection modifications
    - Lazy initialization
 
 5. Best practices:
    - Minimize shared mutable state
    - Use value types (structs) when possible
    - Prefer actors in modern Swift
    - Always use defer for unlocking
    - Avoid nested locks (deadlock risk)
 
 6. Testing:
    - Enable Thread Sanitizer
    - Test with high concurrency
    - Use assertions for invariants
    - Stress test in release builds
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between serial and concurrent queues?"
 A1: Serial queues execute one task at a time in order. Concurrent
     queues execute multiple tasks simultaneously. Use serial for
     synchronization, concurrent for parallelism.
 
 Q2: "What's a barrier in GCD?"
 A2: A barrier blocks other tasks on a concurrent queue. It waits for
     all current tasks to finish, executes exclusively, then allows
     new tasks. Useful for write operations in read-write scenarios.
 
 Q3: "When should you use sync vs async?"
 A3: Use async for background work to avoid blocking. Use sync when
     you need the result immediately (like getters) or for writes to
     prevent race conditions.
 
 Q4: "What's the difference between NSLock and NSRecursiveLock?"
 A4: NSLock deadlocks if the same thread tries to lock it twice.
     NSRecursiveLock allows the same thread to lock multiple times
     (must unlock the same number of times).
 
 Q5: "How do Swift actors prevent data races?"
 A5: Actors serialize all access to their mutable state. Each actor
     has an internal serial executor that ensures only one task
     accesses the actor's state at a time.
 
 Q6: "What's the main thread's purpose?"
 A6: The main thread handles UI updates and user interactions. All
     UIKit/SwiftUI updates MUST happen on the main thread. Use
     DispatchQueue.main.async to switch to it.
*/


// 💡 ADVANCED: Custom Property Wrapper for Thread Safety
// ═══════════════════════════════════════════════════════════════════

@propertyWrapper
struct Atomic<Value> {
    private var value: Value
    private let lock = NSLock()
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }
}

// Usage:
class Counter {
    @Atomic var count: Int = 0
    
    func increment() {
        count += 1  // Thread-safe!
    }
}


// Uncomment to run:
// runExample04()
