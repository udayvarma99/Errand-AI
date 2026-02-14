/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 6: RACE CONDITION
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Advanced
 Topic: Thread Safety and Concurrency
 Common In: 60% of Swift interviews (Critical for iOS apps)
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - RACE CONDITION
// ═══════════════════════════════════════════════════════════════

class BankAccountBuggy {
    var balance: Double = 1000.0
    
    // 🐛 BUG: Not thread-safe!
    func withdraw(amount: Double) {
        // Multiple threads can access this simultaneously
        if balance >= amount {
            // ⚠️ RACE CONDITION: Another thread might change balance here
            Thread.sleep(forTimeInterval: 0.001) // Simulate processing
            balance -= amount
            print("Withdrew \(amount). New balance: \(balance)")
        } else {
            print("Insufficient funds")
        }
    }
    
    func deposit(amount: Double) {
        // 🐛 BUG: Not thread-safe!
        Thread.sleep(forTimeInterval: 0.001)
        balance += amount
        print("Deposited \(amount). New balance: \(balance)")
    }
}

class CounterBuggy {
    var count = 0
    
    // 🐛 BUG: ++ operation is not atomic
    func increment() {
        // This is actually three operations:
        // 1. Read count
        // 2. Add 1
        // 3. Write count
        // Race condition if multiple threads call this!
        count += 1
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. RACE CONDITION:
    - Multiple threads access/modify same data simultaneously
    - No synchronization mechanism
    - Results are unpredictable and non-deterministic
 
 2. CHECK-THEN-ACT PROBLEM:
    - Thread A checks: balance >= amount ✓
    - Thread B checks: balance >= amount ✓
    - Thread A withdraws
    - Thread B withdraws
    - Result: Account overdrawn!
 
 3. NON-ATOMIC OPERATIONS:
    - count += 1 is not atomic
    - Can lead to lost updates
    - 1000 increments might result in < 1000
 
 4. HARD TO DEBUG:
    - Only occurs under specific timing
    - Tests might pass, production might fail
    - "Heisenbugs" - disappear when debugging
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Serial Dispatch Queue
// ═══════════════════════════════════════════════════════════════

class BankAccountFixed1 {
    private var balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.bank.account")
    
    func withdraw(amount: Double) {
        // ✅ Serialize access with queue
        queue.sync {
            if self.balance >= amount {
                Thread.sleep(forTimeInterval: 0.001)
                self.balance -= amount
                print("Withdrew \(amount). New balance: \(self.balance)")
            } else {
                print("Insufficient funds")
            }
        }
    }
    
    func deposit(amount: Double) {
        queue.sync {
            Thread.sleep(forTimeInterval: 0.001)
            self.balance += amount
            print("Deposited \(amount). New balance: \(self.balance)")
        }
    }
    
    func getBalance() -> Double {
        return queue.sync { self.balance }
    }
}


// ✅ FIXED CODE - SOLUTION 2: NSLock
// ═══════════════════════════════════════════════════════════════

class BankAccountFixed2 {
    private var balance: Double = 1000.0
    private let lock = NSLock()
    
    func withdraw(amount: Double) {
        lock.lock()
        defer { lock.unlock() }  // ✅ Always unlock, even if error
        
        if balance >= amount {
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("Withdrew \(amount). New balance: \(balance)")
        } else {
            print("Insufficient funds")
        }
    }
    
    func deposit(amount: Double) {
        lock.lock()
        defer { lock.unlock() }
        
        Thread.sleep(forTimeInterval: 0.001)
        balance += amount
        print("Deposited \(amount). New balance: \(balance)")
    }
    
    func getBalance() -> Double {
        lock.lock()
        defer { lock.unlock() }
        return balance
    }
}


// ✅ FIXED CODE - SOLUTION 3: Actor (Modern Swift 5.5+)
// ═══════════════════════════════════════════════════════════════

actor BankAccountFixed3 {
    private var balance: Double = 1000.0
    
    // ✅ Actor automatically serializes access!
    func withdraw(amount: Double) async {
        if balance >= amount {
            try? await Task.sleep(nanoseconds: 1_000_000)
            balance -= amount
            print("Withdrew \(amount). New balance: \(balance)")
        } else {
            print("Insufficient funds")
        }
    }
    
    func deposit(amount: Double) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        balance += amount
        print("Deposited \(amount). New balance: \(balance)")
    }
    
    func getBalance() -> Double {
        return balance
    }
}


// ✅ FIXED CODE - SOLUTION 4: Atomic Operations with OSAtomic
// ═══════════════════════════════════════════════════════════════

class Counter {
    private var _count: Int = 0
    private let lock = NSLock()
    
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return _count
    }
    
    func increment() {
        lock.lock()
        defer { lock.unlock() }
        _count += 1
    }
    
    func decrement() {
        lock.lock()
        defer { lock.unlock() }
        _count -= 1
    }
}


// ✅ ADVANCED: Concurrent Reads, Exclusive Writes
// ═══════════════════════════════════════════════════════════════

class ThreadSafeArray<T> {
    private var array: [T] = []
    private let queue = DispatchQueue(
        label: "com.threadsafe.array",
        attributes: .concurrent  // ✅ Allow concurrent reads
    )
    
    func append(_ element: T) {
        queue.async(flags: .barrier) {  // ✅ Exclusive write
            self.array.append(element)
        }
    }
    
    func get(at index: Int) -> T? {
        return queue.sync {  // ✅ Concurrent read
            guard index < array.count else { return nil }
            return array[index]
        }
    }
    
    var count: Int {
        return queue.sync { array.count }
    }
    
    func getAll() -> [T] {
        return queue.sync { array }
    }
}


// ✅ ADVANCED: MainActor for UI Updates
// ═══════════════════════════════════════════════════════════════

@MainActor
class ViewModel: ObservableObject {
    @Published var items: [String] = []
    
    // ✅ Automatically runs on main thread
    func updateItems() async {
        // Some async work
        try? await Task.sleep(nanoseconds: 1_000_000)
        
        // UI update - guaranteed on main thread
        items.append("New Item")
    }
    
    nonisolated func backgroundWork() {
        // This can run on any thread
        print("Background work")
    }
}


// ✅ REAL-WORLD EXAMPLE: Thread-Safe Cache
// ═══════════════════════════════════════════════════════════════

actor Cache<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]
    private var accessCount: [Key: Int] = [:]
    
    func get(_ key: Key) -> Value? {
        accessCount[key, default: 0] += 1
        return storage[key]
    }
    
    func set(_ key: Key, value: Value) {
        storage[key] = value
    }
    
    func remove(_ key: Key) {
        storage.removeValue(forKey: key)
        accessCount.removeValue(forKey: key)
    }
    
    func clear() {
        storage.removeAll()
        accessCount.removeAll()
    }
    
    func mostAccessed() -> Key? {
        return accessCount.max { $0.value < $1.value }?.key
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. THREAD SAFETY SOLUTIONS:
    - Serial DispatchQueue: Simple, effective
    - NSLock: Traditional, fine-grained control
    - Actor: Modern Swift, recommended for new code
    - @MainActor: For UI-related code
 
 2. DISPATCH QUEUE PATTERNS:
    - sync: Wait for completion (use for getters)
    - async: Don't wait (use for setters)
    - .barrier: Exclusive access in concurrent queue
    - .concurrent: Allow multiple reads
 
 3. ACTORS (Swift 5.5+):
    - Automatically serialize access
    - State isolation by default
    - Async/await integration
    - Preferred modern solution
 
 4. COMMON PITFALLS:
    - Forgetting to synchronize getters
    - Deadlocks from nested sync calls
    - Using async when sync is needed
    - Not using defer with locks
 
 5. PERFORMANCE:
    - Locking has overhead
    - Concurrent reads + exclusive writes = best balance
    - Actors have minimal overhead
    - Profile before optimizing
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "This code has a race condition because multiple threads can access the 
    balance simultaneously without synchronization."
 
 2. "The check-then-act pattern is problematic - the balance could change 
    between the check and the withdrawal."
 
 3. "I'd use a serial DispatchQueue to serialize all access to the balance, 
    ensuring only one thread can modify it at a time."
 
 4. "In modern Swift, I'd use an Actor which provides automatic isolation and 
    integrates well with async/await."
 
 5. "For better performance, I could use a concurrent queue with barriers - 
    allowing concurrent reads but exclusive writes."
 
 BONUS POINTS:
 ✅ Discuss different synchronization mechanisms
 ✅ Mention data races vs race conditions
 ✅ Know about Thread Sanitizer in Xcode
 ✅ Understand MainActor for UI code
 ✅ Discuss async/await and structured concurrency
 
 RED FLAGS:
 ❌ "Thread safety isn't important in iOS"
 ❌ Not knowing what a race condition is
 ❌ Using global locks for everything
 ❌ Not understanding the difference between sync and async
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What's the difference between a data race and a race condition?"
 A: "A data race is simultaneous access to memory with at least one write. 
     A race condition is when timing affects correctness. Data races are 
     undefined behavior; race conditions are logic bugs."
 
 Q: "When would you use NSLock vs DispatchQueue?"
 A: "DispatchQueue for most cases - simpler API, better integration. NSLock 
     for fine-grained control or when you need tryLock functionality."
 
 Q: "What's the benefit of Actors over manual locking?"
 A: "Actors provide compile-time safety, automatic isolation, better async 
     integration, and are harder to misuse (no forgetting to unlock)."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample6() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 6: RACE CONDITION")
    print("═══════════════════════════════════════════════════════\n")
    
    print("❌ BUGGY VERSION (Race condition - results vary):")
    let buggyAccount = BankAccountBuggy()
    let group1 = DispatchGroup()
    
    for _ in 1...5 {
        DispatchQueue.global().async(group: group1) {
            buggyAccount.withdraw(amount: 100)
        }
    }
    
    group1.wait()
    print("Final balance (buggy): \(buggyAccount.balance)")
    print("^ Notice: Balance might be negative!\n")
    
    print("✅ FIXED VERSION 1 (DispatchQueue):")
    let fixedAccount1 = BankAccountFixed1()
    let group2 = DispatchGroup()
    
    for _ in 1...5 {
        DispatchQueue.global().async(group: group2) {
            fixedAccount1.withdraw(amount: 100)
        }
    }
    
    group2.wait()
    print("Final balance: \(fixedAccount1.getBalance())")
    print("^ Balance is correct!\n")
    
    print("✅ FIXED VERSION 2 (NSLock):")
    let fixedAccount2 = BankAccountFixed2()
    let group3 = DispatchGroup()
    
    for _ in 1...5 {
        DispatchQueue.global().async(group: group3) {
            fixedAccount2.withdraw(amount: 100)
        }
    }
    
    group3.wait()
    print("Final balance: \(fixedAccount2.getBalance())\n")
    
    print("✅ THREAD-SAFE ARRAY:")
    let safeArray = ThreadSafeArray<Int>()
    let group4 = DispatchGroup()
    
    for i in 1...10 {
        DispatchQueue.global().async(group: group4) {
            safeArray.append(i)
        }
    }
    
    group4.wait()
    print("Array count: \(safeArray.count)")
    print("All items: \(safeArray.getAll().sorted())\n")
}

// Uncomment to run:
// runExample6()
