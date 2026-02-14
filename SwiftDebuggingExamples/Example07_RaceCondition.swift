// =============================================================================
// EXAMPLE 7: Race Condition / Thread Safety Bug
// Topic: Multiple threads accessing shared mutable state without synchronization
// Difficulty: Advanced
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

class BankAccount {
    var balance: Double = 1000.0  // BUG: Not thread-safe!

    func deposit(amount: Double) {
        // BUG: Read-modify-write is NOT atomic
        let currentBalance = balance
        // Another thread could read the same balance here!
        balance = currentBalance + amount
    }

    func withdraw(amount: Double) -> Bool {
        // BUG: Check-then-act is NOT atomic
        if balance >= amount {
            // Another thread could withdraw between this check and the next line!
            balance -= amount
            return true
        }
        return false
    }
}

let account = BankAccount()

// Simulate 100 concurrent deposits of $10 each
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

for _ in 0..<100 {
    group.enter()
    queue.async {
        account.deposit(amount: 10.0)
        group.leave()
    }
}

group.wait()

// Expected: 1000 + (100 * 10) = 2000.0
// Actual: Unpredictable! Could be 1070, 1540, 1980, etc.
print("Final balance: \(account.balance)")  // NOT always 2000!

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// A RACE CONDITION occurs when two or more threads access shared data
// simultaneously, and at least one of them modifies it.
//
// The deposit() method has three steps:
//   1. Read the current balance
//   2. Add the amount
//   3. Write the new balance
//
// If Thread A reads balance = 1000 and Thread B reads balance = 1000
// at the same time, they both compute 1010 and write 1010.
// We lost one deposit! The balance should be 1020.
//
// This is called a "lost update" or "race condition" and is a critical
// bug in concurrent programming.
//

// =============================================================================
// FIXED CODE - Three approaches to thread safety
// =============================================================================

// --- Fix 1: Using a serial DispatchQueue (most common in iOS) ---

class BankAccountFix1 {
    private var _balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.bank.account.queue")

    var balance: Double {
        return queue.sync { _balance }
    }

    func deposit(amount: Double) {
        queue.sync {
            _balance += amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        return queue.sync {
            if _balance >= amount {
                _balance -= amount
                return true
            }
            return false
        }
    }
}

// --- Fix 2: Using NSLock ---

class BankAccountFix2 {
    private var _balance: Double = 1000.0
    private let lock = NSLock()

    var balance: Double {
        lock.lock()
        defer { lock.unlock() }
        return _balance
    }

    func deposit(amount: Double) {
        lock.lock()
        defer { lock.unlock() }  // Ensures unlock even if an error occurs
        _balance += amount
    }

    func withdraw(amount: Double) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if _balance >= amount {
            _balance -= amount
            return true
        }
        return false
    }
}

// --- Fix 3: Using a concurrent queue with barrier (best for read-heavy workloads) ---

class BankAccountFix3 {
    private var _balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.bank.account.queue",
                                       attributes: .concurrent)

    var balance: Double {
        // Multiple threads can READ simultaneously
        return queue.sync { _balance }
    }

    func deposit(amount: Double) {
        // Barrier ensures exclusive access for WRITES
        queue.sync(flags: .barrier) {
            _balance += amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        return queue.sync(flags: .barrier) {
            if _balance >= amount {
                _balance -= amount
                return true
            }
            return false
        }
    }
}

// --- Test Fix 1 ---
print("=== Fix 1: Serial DispatchQueue ===")
let account1 = BankAccountFix1()
let group1 = DispatchGroup()

for _ in 0..<100 {
    group1.enter()
    DispatchQueue.global().async {
        account1.deposit(amount: 10.0)
        group1.leave()
    }
}

group1.wait()
print("Final balance: \(account1.balance)")  // Always 2000.0

// --- Test Fix 2 ---
print("\n=== Fix 2: NSLock ===")
let account2 = BankAccountFix2()
let group2 = DispatchGroup()

for _ in 0..<100 {
    group2.enter()
    DispatchQueue.global().async {
        account2.deposit(amount: 10.0)
        group2.leave()
    }
}

group2.wait()
print("Final balance: \(account2.balance)")  // Always 2000.0

// --- Test Fix 3 ---
print("\n=== Fix 3: Concurrent queue with barrier ===")
let account3 = BankAccountFix3()
let group3 = DispatchGroup()

for _ in 0..<100 {
    group3.enter()
    DispatchQueue.global().async {
        account3.deposit(amount: 10.0)
        group3.leave()
    }
}

group3.wait()
print("Final balance: \(account3.balance)")  // Always 2000.0

// =============================================================================
// BONUS: Swift Actors (Swift 5.5+ / Modern Concurrency)
// =============================================================================
//
// In modern Swift, the BEST way to handle shared mutable state is with actors:
//
//   actor BankAccount {
//       var balance: Double = 1000.0
//
//       func deposit(amount: Double) {
//           balance += amount  // Automatically thread-safe!
//       }
//
//       func withdraw(amount: Double) -> Bool {
//           if balance >= amount {
//               balance -= amount
//               return true
//           }
//           return false
//       }
//   }
//
//   // Usage (must be in async context):
//   let account = BankAccount()
//   await account.deposit(amount: 50.0)
//   let currentBalance = await account.balance
//
// Actors guarantee that only one task accesses their mutable state at a time.
// This is the future of Swift concurrency and very relevant for Apple interviews.
//

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Race conditions occur when shared mutable state is accessed by multiple
// threads without synchronization.
//
// In interviews, Apple engineers look for:
//   1. Identifying race conditions in code
//   2. Knowledge of synchronization mechanisms:
//      - Serial DispatchQueue (most common in iOS)
//      - NSLock / os_unfair_lock
//      - Concurrent queue + barrier
//      - Actors (modern Swift concurrency)
//   3. Understanding of GCD (Grand Central Dispatch)
//   4. Knowledge of async/await and structured concurrency
//   5. Understanding of main thread vs background thread
//      (UI updates must ALWAYS be on the main thread)
//
// Common interview question:
//   "How do you ensure a property is thread-safe in Swift?"
//   Answer: Use a serial queue, a lock, or make it an actor property.
// =============================================================================
