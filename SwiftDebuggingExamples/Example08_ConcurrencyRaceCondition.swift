// =============================================================================
// EXAMPLE 8: Concurrency & Race Conditions
// =============================================================================
//
// DIFFICULTY: Intermediate-Advanced
// TOPIC: GCD, Thread Safety, Race Conditions, Actors (Swift 5.5+)
// APPLE INTERVIEW TIP: Concurrency is one of the hardest topics in iOS
//   development. Apple has invested heavily in Swift Concurrency (async/await,
//   actors). Showing you understand both old (GCD) and new (async/await)
//   patterns will set you apart.
//
// WHAT YOU WILL LEARN:
//   - What a race condition is and why it's dangerous
//   - How to use serial queues to protect shared state
//   - Modern Swift Concurrency with actors
//   - Why UI updates must happen on the main thread
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

import Foundation

class BankAccount {
    var balance: Double = 1000.0  // BUG: Not thread-safe!
    
    func withdraw(_ amount: Double) -> Bool {
        // BUG: Race condition! Multiple threads can read balance simultaneously
        // Thread A reads balance: 1000
        // Thread B reads balance: 1000
        // Thread A: 1000 >= 900? Yes! → balance = 100
        // Thread B: 1000 >= 900? Yes! → balance = 100
        // Both withdrawals succeed but only one was deducted!
        if balance >= amount {
            // Simulate some processing time
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            return true
        }
        return false
    }
    
    func deposit(_ amount: Double) {
        // Also not thread-safe
        balance += amount
    }
}

let account = BankAccount()

// Two threads try to withdraw simultaneously
DispatchQueue.global().async {
    let success = account.withdraw(900)
    print("Thread 1 withdraw: \(success), balance: \(account.balance)")
}

DispatchQueue.global().async {
    let success = account.withdraw(900)
    print("Thread 2 withdraw: \(success), balance: \(account.balance)")
}

// POSSIBLE BUG OUTPUT:
// Thread 1 withdraw: true, balance: 100.0
// Thread 2 withdraw: true, balance: -800.0  ← Negative balance! 💥
// Both withdrawals succeeded because they both read balance as 1000!

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// A RACE CONDITION occurs when multiple threads access shared data
// simultaneously and at least one thread modifies it. The result depends
// on the unpredictable timing of thread execution.
//
// The withdraw() method has a classic TOCTOU (Time-Of-Check-To-Time-Of-Use)
// bug:
//   1. Thread checks: balance >= amount (reads balance)
//   2. Time passes (other thread can modify balance)
//   3. Thread acts: balance -= amount (writes balance)
//
// Between step 1 and 3, another thread can change the balance, making the
// check invalid. This is especially dangerous with financial data.
//
// Race conditions are:
//   - Hard to reproduce (depend on timing)
//   - Hard to debug (may only happen under load)
//   - Can cause data corruption, crashes, or security vulnerabilities
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE — Three approaches
// ---------------------------------------------------------------------------

import Foundation

// APPROACH 1: Serial DispatchQueue (GCD — Grand Central Dispatch)
// All access to shared state goes through a single serial queue
class BankAccountGCD {
    private var _balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.example.bankaccount")
    
    // Thread-safe property using sync access
    var balance: Double {
        return queue.sync { _balance }
    }
    
    func withdraw(_ amount: Double) -> Bool {
        return queue.sync {
            // Only one thread can execute this block at a time
            if _balance >= amount {
                _balance -= amount
                return true
            }
            return false
        }
    }
    
    func deposit(_ amount: Double) {
        queue.sync {
            _balance += amount
        }
    }
}


// APPROACH 2: NSLock (Traditional locking)
class BankAccountLock {
    private var _balance: Double = 1000.0
    private let lock = NSLock()
    
    var balance: Double {
        lock.lock()
        defer { lock.unlock() }  // defer ensures unlock even if something throws
        return _balance
    }
    
    func withdraw(_ amount: Double) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if _balance >= amount {
            _balance -= amount
            return true
        }
        return false
    }
    
    func deposit(_ amount: Double) {
        lock.lock()
        defer { lock.unlock() }
        _balance += amount
    }
}


// APPROACH 3: Swift Actor (Modern Swift Concurrency — Swift 5.5+)
// Actors are the recommended way to protect shared mutable state
actor BankAccountActor {
    private var _balance: Double
    
    var balance: Double { _balance }
    
    init(balance: Double = 1000.0) {
        _balance = balance
    }
    
    // Actor methods are automatically thread-safe
    // Only one task can execute actor code at a time
    func withdraw(_ amount: Double) -> Bool {
        if _balance >= amount {
            _balance -= amount
            return true
        }
        return false
    }
    
    func deposit(_ amount: Double) {
        _balance += amount
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify thread safety
// ---------------------------------------------------------------------------

print("=== Approach 1: Serial DispatchQueue ===")

let accountGCD = BankAccountGCD()
let group1 = DispatchGroup()

// Try 10 concurrent withdrawals of 200 each (total 2000, but only 1000 available)
for i in 1...10 {
    group1.enter()
    DispatchQueue.global().async {
        let success = accountGCD.withdraw(200)
        print("  GCD Thread \(i): withdraw \(success ? "succeeded" : "failed")")
        group1.leave()
    }
}

group1.wait()
print("  Final GCD balance: \(accountGCD.balance)")
// Exactly 5 should succeed (5 x 200 = 1000), balance should be 0.0


print("\n=== Approach 2: NSLock ===")

let accountLock = BankAccountLock()
let group2 = DispatchGroup()

for i in 1...10 {
    group2.enter()
    DispatchQueue.global().async {
        let success = accountLock.withdraw(200)
        print("  Lock Thread \(i): withdraw \(success ? "succeeded" : "failed")")
        group2.leave()
    }
}

group2.wait()
print("  Final Lock balance: \(accountLock.balance)")


// APPROACH 3 requires async context
print("\n=== Approach 3: Actor (Modern Swift) ===")

// Note: In a real app, you'd use this in an async context:
//
// let account = BankAccountActor()
//
// await withTaskGroup(of: Bool.self) { group in
//     for _ in 1...10 {
//         group.addTask {
//             await account.withdraw(200)
//         }
//     }
// }
//
// let finalBalance = await account.balance
// print("Actor balance: \(finalBalance)")

print("  (Actor example requires async context — see code comments)")


// ---------------------------------------------------------------------------
// IMPORTANT: Main Thread UI Updates
// ---------------------------------------------------------------------------

// Another common concurrency bug: updating UI from a background thread

/*

// BUGGY: Updating UI from background thread
URLSession.shared.dataTask(with: url) { data, response, error in
    // This closure runs on a BACKGROUND thread!
    self.label.text = "Loaded"  // BUG: UIKit is not thread-safe!
    self.tableView.reloadData() // BUG: Will crash or cause visual glitches
}.resume()

// FIXED: Dispatch to main thread for UI updates
URLSession.shared.dataTask(with: url) { data, response, error in
    DispatchQueue.main.async {
        self.label.text = "Loaded"    // Now safe
        self.tableView.reloadData()    // Now safe
    }
}.resume()

// MODERN FIX: Use @MainActor
@MainActor
func updateUI(with data: [String]) {
    // Guaranteed to run on the main thread
    self.label.text = "Loaded"
    self.tableView.reloadData()
}

*/

print("\n(See code comments for UI thread safety examples)")


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "Explain the difference between serial and concurrent queues in GCD.
//     When would you use each?"
//
// A:
//   SERIAL QUEUE:
//   - Executes tasks one at a time, in order (FIFO)
//   - Only one task runs at a time
//   - Use for: protecting shared resources, ensuring order
//   - Example: DispatchQueue(label: "serial")
//
//   CONCURRENT QUEUE:
//   - Can execute multiple tasks simultaneously
//   - Tasks start in FIFO order but can finish in any order
//   - Use for: independent tasks that can run in parallel
//   - Example: DispatchQueue(label: "concurrent", attributes: .concurrent)
//   - Also: DispatchQueue.global() (system concurrent queue)
//
//   MAIN QUEUE:
//   - Special serial queue that runs on the main thread
//   - ALL UI updates must happen here
//   - Example: DispatchQueue.main.async { /* UI work */ }
//
//   Modern approach (Swift 5.5+):
//   - Use async/await instead of completion handlers
//   - Use actors instead of manual locking
//   - Use @MainActor instead of DispatchQueue.main
//   - Use TaskGroup instead of DispatchGroup
// ---------------------------------------------------------------------------
