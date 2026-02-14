/*
 ============================================
 EXAMPLE 4: RACE CONDITIONS & CONCURRENCY
 ============================================
 
 Common Issue: Unsafe concurrent access to shared mutable state
 Apple Interview Focus: Thread safety, GCD, async/await, actors
 */

import Foundation

// ❌ BUGGY CODE - Race Condition!

class BuggyBankAccount {
    var balance: Int = 1000
    
    func withdraw(_ amount: Int) {
        // 🐛 BUG: Not thread-safe - race condition!
        if balance >= amount {
            // Simulate some processing time
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("💸 Withdrew \(amount), balance: \(balance)")
        } else {
            print("❌ Insufficient funds")
        }
    }
    
    func deposit(_ amount: Int) {
        // 🐛 BUG: Not thread-safe
        Thread.sleep(forTimeInterval: 0.001)
        balance += amount
        print("💰 Deposited \(amount), balance: \(balance)")
    }
}

class BuggyCounter {
    var count = 0
    
    func increment() {
        // 🐛 BUG: count++ is not atomic - race condition!
        // Multiple threads can read the same value and write back
        let temp = count
        Thread.sleep(forTimeInterval: 0.0001)
        count = temp + 1
    }
}

// Example of race condition:
func demonstrateBug() {
    print("=== RACE CONDITION DEMO ===")
    
    let account = BuggyBankAccount()
    let queue = DispatchQueue.global()
    
    print("Starting balance: \(account.balance)")
    
    // Multiple threads trying to withdraw simultaneously
    for i in 1...5 {
        queue.async {
            account.withdraw(200)  // 5 threads × $200 = $1000
        }
    }
    
    // Wait a bit to see the results
    Thread.sleep(forTimeInterval: 0.1)
    print("Final balance: \(account.balance)")
    print("Expected: 0, but likely negative due to race condition!\n")
    
    // Counter example
    let counter = BuggyCounter()
    let group = DispatchGroup()
    
    for _ in 1...100 {
        group.enter()
        queue.async {
            counter.increment()
            group.leave()
        }
    }
    
    group.wait()
    print("Counter final value: \(counter.count)")
    print("Expected: 100, but likely less due to race condition!")
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Use Thread Sanitizer in Xcode (Edit Scheme → Diagnostics)
 2. Add print statements with Thread.current
 3. Use breakpoints with thread info
 4. Enable "Pause on issues" in Thread Sanitizer
 5. Look for data races in runtime issues navigator
 6. Use assertions to check thread: assert(Thread.isMainThread)
 */

// ✅ FIXED CODE - Thread Safe Solutions

// SOLUTION 1: Serial DispatchQueue
class FixedBankAccountWithQueue {
    private var balance: Int = 1000
    private let queue = DispatchQueue(label: "com.bank.account.queue")
    
    func withdraw(_ amount: Int) {
        queue.sync {  // Synchronous to ensure thread-safe access
            if balance >= amount {
                Thread.sleep(forTimeInterval: 0.001)
                balance -= amount
                print("💸 Withdrew \(amount), balance: \(balance)")
            } else {
                print("❌ Insufficient funds")
            }
        }
    }
    
    func deposit(_ amount: Int) {
        queue.sync {
            Thread.sleep(forTimeInterval: 0.001)
            balance += amount
            print("💰 Deposited \(amount), balance: \(balance)")
        }
    }
    
    func getBalance() -> Int {
        return queue.sync { balance }
    }
}

// SOLUTION 2: NSLock
class FixedBankAccountWithLock {
    private var balance: Int = 1000
    private let lock = NSLock()
    
    func withdraw(_ amount: Int) {
        lock.lock()
        defer { lock.unlock() }  // Ensures unlock even if error occurs
        
        if balance >= amount {
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("💸 Withdrew \(amount), balance: \(balance)")
        } else {
            print("❌ Insufficient funds")
        }
    }
    
    func deposit(_ amount: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        Thread.sleep(forTimeInterval: 0.001)
        balance += amount
        print("💰 Deposited \(amount), balance: \(balance)")
    }
}

// SOLUTION 3: Actors (Swift 5.5+) - Modern approach!
actor ActorBankAccount {
    private var balance: Int = 1000
    
    func withdraw(_ amount: Int) async {
        if balance >= amount {
            try? await Task.sleep(nanoseconds: 1_000_000)
            balance -= amount
            print("💸 Withdrew \(amount), balance: \(balance)")
        } else {
            print("❌ Insufficient funds")
        }
    }
    
    func deposit(_ amount: Int) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        balance += amount
        print("💰 Deposited \(amount), balance: \(balance)")
    }
    
    func getBalance() -> Int {
        return balance
    }
}

// SOLUTION 4: Atomic operations with OSAtomic (for simple counters)
import os.lock

class FixedCounter {
    private var _count: Int32 = 0
    private let lock = OSAllocatedUnfairLock()
    
    var count: Int {
        lock.withLock { Int(_count) }
    }
    
    func increment() {
        lock.withLock {
            _count += 1
        }
    }
}

// SOLUTION 5: Concurrent queue with barriers (for read-heavy operations)
class ThreadSafeCache {
    private var cache: [String: String] = [:]
    private let queue = DispatchQueue(label: "com.cache.queue", attributes: .concurrent)
    
    // Multiple threads can read simultaneously
    func getValue(for key: String) -> String? {
        return queue.sync {
            return cache[key]
        }
    }
    
    // Only one thread can write, blocks all reads during write
    func setValue(_ value: String, for key: String) {
        queue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }
}

// Modern async/await example
class DataManager {
    private var data: [String] = []
    private let queue = DispatchQueue(label: "com.data.queue")
    
    func addData(_ item: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.data.append(item)
                continuation.resume()
            }
        }
    }
    
    func getData() async -> [String] {
        await withCheckedContinuation { continuation in
            queue.sync {
                continuation.resume(returning: self.data)
            }
        }
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("\n=== FIXED VERSION WITH QUEUE ===")
    
    let account = FixedBankAccountWithQueue()
    let queue = DispatchQueue.global()
    let group = DispatchGroup()
    
    print("Starting balance: \(account.getBalance())")
    
    for _ in 1...5 {
        group.enter()
        queue.async {
            account.withdraw(200)
            group.leave()
        }
    }
    
    group.wait()
    print("Final balance: \(account.getBalance())")
    print("Expected: 0 ✅\n")
    
    // Counter example
    print("=== FIXED COUNTER ===")
    let counter = FixedCounter()
    let counterGroup = DispatchGroup()
    
    for _ in 1...100 {
        counterGroup.enter()
        queue.async {
            counter.increment()
            counterGroup.leave()
        }
    }
    
    counterGroup.wait()
    print("Counter final value: \(counter.count)")
    print("Expected: 100 ✅")
}

// Actor example
func demonstrateActor() async {
    print("\n=== ACTOR EXAMPLE ===")
    
    let account = ActorBankAccount()
    
    print("Starting balance: \(await account.getBalance())")
    
    // Concurrent operations are automatically serialized by the actor
    await withTaskGroup(of: Void.self) { group in
        for _ in 1...5 {
            group.addTask {
                await account.withdraw(200)
            }
        }
    }
    
    print("Final balance: \(await account.getBalance())")
    print("Expected: 0 ✅")
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. SHARED MUTABLE STATE + CONCURRENCY = RACE CONDITIONS
 2. Use serial DispatchQueue for synchronization
 3. Use NSLock/NSRecursiveLock for critical sections
 4. Actors are the modern, safe way (Swift 5.5+)
 5. Always use defer { lock.unlock() } to prevent deadlocks
 6. Concurrent queues with barriers for read-heavy scenarios
 7. UI updates MUST be on main thread
 
 🎯 THREAD SAFETY PATTERNS:
 
 - Serial Queue: Simple, effective, prevents concurrent access
 - Locks: Fine-grained control, use with caution
 - Actors: Modern, compiler-enforced thread safety
 - Concurrent Queue + Barriers: Optimize read-heavy workloads
 - Immutability: Best solution - no shared mutable state
 
 ⚠️  COMMON CONCURRENCY MISTAKES:
 
 1. Forgetting to unlock (use defer!)
 2. Accessing shared state without synchronization
 3. Updating UI from background thread
 4. Nested locks causing deadlocks
 5. Using async when you need sync
 6. Not understanding async/await execution model
 
 💡 MAIN THREAD RULE:
 
 // ❌ WRONG
 DispatchQueue.global().async {
     self.label.text = "Done"  // UI update on background thread!
 }
 
 // ✅ CORRECT
 DispatchQueue.global().async {
     let result = self.doHeavyWork()
     DispatchQueue.main.async {
         self.label.text = result  // UI update on main thread
     }
 }
 
 // ✅ MODERN (async/await)
 Task {
     let result = await doHeavyWork()
     await MainActor.run {
         label.text = result
     }
 }
 
 🛠️  DEBUGGING RACE CONDITIONS:
 
 1. Enable Thread Sanitizer (catches most issues)
 2. Use print with Thread.current.description
 3. Add assertions: assert(Thread.isMainThread)
 4. Use breakpoints with thread information
 5. Xcode → Debug Navigator → View threads
 
 ⚡ INTERVIEW TIPS:
 
 - Explain why race conditions occur
 - Know difference between sync/async dispatch
 - Understand when to use serial vs concurrent queues
 - Be familiar with modern async/await and actors
 - Always mention main thread for UI updates
 - Discuss trade-offs: locks are fast but error-prone, actors are safe but require Swift 5.5+
 
 🎓 ADVANCED CONCEPTS:
 
 - @MainActor for main thread-bound code
 - Sendable protocol for safe cross-actor data
 - Task groups for structured concurrency
 - AsyncSequence for async data streams
 - Detached tasks vs child tasks
 */

// Run demonstrations
print("🐛 BUGGY VERSION (Race Conditions):")
demonstrateBug()

print("\n" + String(repeating: "=", count: 50))
demonstrateFix()

// Uncomment to run actor example (requires async context)
// Task {
//     await demonstrateActor()
// }
