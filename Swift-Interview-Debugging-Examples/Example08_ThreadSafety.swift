// =============================================================================
// EXAMPLE 8: Thread Safety / Race Condition
// =============================================================================
// Difficulty: Advanced
// Topic:      Concurrency, GCD, Race Conditions, Serial Queues
//
// SCENARIO:
// You are building a bank account class that supports deposits and withdrawals
// from multiple threads (e.g., automatic payments happening simultaneously).
// The balance becomes incorrect because multiple threads read and write the
// balance at the same time without synchronization.
// =============================================================================

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

class BankAccountBuggy {
    var balance: Double

    init(balance: Double) {
        self.balance = balance
    }

    func deposit(amount: Double) {
        // BUG: No thread safety! If two threads call deposit simultaneously:
        //   Thread A reads balance = 100
        //   Thread B reads balance = 100
        //   Thread A writes balance = 100 + 50 = 150
        //   Thread B writes balance = 100 + 30 = 130  ← Thread A's deposit is LOST!
        let currentBalance = balance
        // Simulate some processing delay
        Thread.sleep(forTimeInterval: 0.001)
        balance = currentBalance + amount
    }

    func withdraw(amount: Double) -> Bool {
        // BUG: Same race condition as deposit.
        // Two threads could both read balance = 100, both see enough funds,
        // and both withdraw — resulting in a negative balance!
        guard balance >= amount else {
            print("Insufficient funds")
            return false
        }
        let currentBalance = balance
        Thread.sleep(forTimeInterval: 0.001)
        balance = currentBalance - amount
        return true
    }
}

func demoBuggy() {
    let account = BankAccountBuggy(balance: 1000.0)
    let group = DispatchGroup()

    // Make 10 deposits of $100 each from different threads
    for _ in 0..<10 {
        group.enter()
        DispatchQueue.global().async {
            account.deposit(amount: 100.0)
            group.leave()
        }
    }

    group.wait()
    // Expected balance: 1000 + (10 × 100) = 2000
    // Actual balance: UNPREDICTABLE! Could be 1100, 1200, 1300...
    print("Buggy balance (expected 2000): \(account.balance)\n")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// A RACE CONDITION occurs when multiple threads access shared mutable state
// without proper synchronization. The result depends on the unpredictable
// timing of thread execution.
//
// The sequence of events:
//   1. Thread A reads balance (1000)
//   2. Thread B reads balance (1000) — same value!
//   3. Thread A writes 1000 + 100 = 1100
//   4. Thread B writes 1000 + 100 = 1100 — Thread A's deposit is LOST!
//
// This is called a "lost update" problem. The final balance is wrong because
// the read-modify-write operation is not ATOMIC.
//
// In Apple interviews, thread safety is a critical topic because:
//   - UIKit is NOT thread-safe (UI updates must happen on the main thread)
//   - Core Data has thread-confined contexts
//   - Network callbacks happen on background threads
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Using a serial DispatchQueue for synchronization
// ─────────────────────────────────────────────────────────────────────────────

class BankAccountFixed {
    private var _balance: Double

    // A SERIAL queue ensures only ONE operation runs at a time.
    // This prevents concurrent access to _balance.
    private let queue = DispatchQueue(label: "com.bank.accountQueue")

    init(balance: Double) {
        self._balance = balance
    }

    // Thread-safe read access using sync
    var balance: Double {
        return queue.sync {
            return _balance
        }
    }

    func deposit(amount: Double) {
        // FIX: All balance modifications go through the serial queue.
        // Only one thread can execute this block at a time.
        queue.sync {
            let currentBalance = _balance
            // Even with a delay, no other thread can interfere
            Thread.sleep(forTimeInterval: 0.001)
            _balance = currentBalance + amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        return queue.sync {
            guard _balance >= amount else {
                print("Insufficient funds")
                return false
            }
            let currentBalance = _balance
            Thread.sleep(forTimeInterval: 0.001)
            _balance = currentBalance - amount
            return true
        }
    }
}

// ALTERNATIVE FIX: Using a concurrent queue with a barrier
class BankAccountBarrier {
    private var _balance: Double

    // A CONCURRENT queue allows multiple READS at the same time,
    // but a BARRIER flag forces exclusive access for WRITES.
    private let queue = DispatchQueue(
        label: "com.bank.accountBarrierQueue",
        attributes: .concurrent
    )

    init(balance: Double) {
        self._balance = balance
    }

    // Read: concurrent (multiple threads can read simultaneously)
    var balance: Double {
        return queue.sync {
            return _balance
        }
    }

    // Write: barrier (exclusive access — no other reads or writes)
    func deposit(amount: Double) {
        queue.sync(flags: .barrier) {
            _balance += amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        return queue.sync(flags: .barrier) {
            guard _balance >= amount else {
                print("Insufficient funds")
                return false
            }
            _balance -= amount
            return true
        }
    }
}

func demoFixed() {
    // Test with serial queue approach
    print("--- Serial Queue Approach ---")
    let account1 = BankAccountFixed(balance: 1000.0)
    let group1 = DispatchGroup()

    for _ in 0..<10 {
        group1.enter()
        DispatchQueue.global().async {
            account1.deposit(amount: 100.0)
            group1.leave()
        }
    }

    group1.wait()
    print("Fixed balance (expected 2000): \(account1.balance)")

    // Test with barrier approach
    print("\n--- Concurrent Queue + Barrier Approach ---")
    let account2 = BankAccountBarrier(balance: 1000.0)
    let group2 = DispatchGroup()

    for _ in 0..<10 {
        group2.enter()
        DispatchQueue.global().async {
            account2.deposit(amount: 100.0)
            group2.leave()
        }
    }

    group2.wait()
    print("Barrier balance (expected 2000): \(account2.balance)")
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. A RACE CONDITION happens when multiple threads access shared mutable
//    state without synchronization.
//
// 2. SERIAL QUEUE: Only one task runs at a time. Simple and safe.
//    Use when: most read/write operations are mixed.
//
// 3. CONCURRENT QUEUE + BARRIER: Allows multiple simultaneous reads,
//    but writes have exclusive access.
//    Use when: reads are much more frequent than writes (better performance).
//
// 4. NEVER modify shared state from multiple threads without protection.
//
// 5. Common Apple interview questions about thread safety:
//    - "Is UIKit thread-safe?" → No! Update UI only on the main thread.
//    - "How do you make a class thread-safe?" → Serial queue or locks.
//    - "What is a race condition?" → Explain the read-modify-write problem.
//
// 6. Swift's newer concurrency model (async/await, actors) provides
//    compile-time thread safety:
//    - actors: Like a class with a built-in serial queue.
//    - @MainActor: Guarantees code runs on the main thread.
//
// 7. DEBUGGING TIP: Use Xcode's Thread Sanitizer (TSan) to detect race
//    conditions: Product > Scheme > Edit Scheme > Diagnostics > Thread Sanitizer.
// ─────────────────────────────────────────────────────────────────────────────
