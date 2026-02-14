// ============================================================================
// EXAMPLE 7: Concurrency & Race Conditions
// Difficulty: Advanced
// Topic: Thread safety, race conditions, DispatchQueue, actors
// ============================================================================

// ============================================================================
// WHAT IS A RACE CONDITION?
// ============================================================================
// A race condition happens when two or more threads access the same data at
// the same time, and at least one of them is writing. The result depends on
// which thread "wins the race" — making the behavior unpredictable.
//
// Example of real life: Two people editing the same cell in a spreadsheet
// at the same time. Whoever saves last "wins" and the other's work is lost.
//
// In iOS, this can cause:
//   - Corrupted data
//   - Random crashes
//   - UI glitches
//   - Bugs that are nearly impossible to reproduce
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

import Foundation

// Bug 1: Race condition on a shared variable
class BankAccount {
    var balance: Double = 1000.0

    func withdraw(amount: Double) {
        if balance >= amount {
            // Thread A reads balance: 1000
            // Thread B reads balance: 1000  (at the same time!)
            // Thread A: 1000 >= 500 ✓
            // Thread B: 1000 >= 800 ✓
            balance -= amount
            // Thread A writes: balance = 500
            // Thread B writes: balance = 200
            // But wait — we only had 1000! We withdrew 1300! BUG!
        }
    }
}

let account = BankAccount()

DispatchQueue.global().async {
    account.withdraw(amount: 500)  // Thread A
}

DispatchQueue.global().async {
    account.withdraw(amount: 800)  // Thread B — should fail, but might not!
}

// After both complete, balance could be negative! 💥


// Bug 2: Updating a shared array from multiple threads
var results: [Int] = []

DispatchQueue.concurrentPerform(iterations: 100) { i in
    results.append(i)  // BUG: Array is not thread-safe!
    // Multiple threads appending simultaneously = CRASH or data corruption
}

print("Count: \(results.count)")  // Might not be 100! Could crash!


// Bug 3: Deadlock — waiting on yourself
let queue = DispatchQueue(label: "my.serial.queue")

queue.sync {
    print("Outer block")
    queue.sync {  // 💥 DEADLOCK! The queue is waiting for itself to finish!
        print("Inner block")  // Never reached
    }
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Two threads read the balance simultaneously, both see 1000, both
//         proceed with withdrawal. Neither knows the other is also withdrawing.
//         Result: overdraft! This is a classic "check-then-act" race condition.
//
// Bug 2: Swift arrays are NOT thread-safe. Multiple threads calling append()
//         simultaneously can corrupt the array's internal memory, causing
//         crashes or lost data.
//
// Bug 3: A serial queue processes one task at a time. If task A is running
//         on the queue and it dispatches task B to the SAME queue with `sync`
//         (wait until done), task A is waiting for B, but B can't start until
//         A finishes. Neither can proceed = deadlock.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

import Foundation

// Fix 1: Use a serial queue to protect shared state
class BankAccount {
    private var _balance: Double = 1000.0
    private let queue = DispatchQueue(label: "bankaccount.queue")

    var balance: Double {
        return queue.sync { _balance }  // Thread-safe read
    }

    func withdraw(amount: Double) -> Bool {
        return queue.sync {  // Only one thread can execute this at a time
            if _balance >= amount {
                _balance -= amount
                print("Withdrew \(amount). New balance: \(_balance)")
                return true
            } else {
                print("Insufficient funds. Balance: \(_balance), Requested: \(amount)")
                return false
            }
        }
    }
}

let account = BankAccount()

let group = DispatchGroup()

group.enter()
DispatchQueue.global().async {
    let success = account.withdraw(amount: 500)
    print("Withdrawal of 500: \(success ? "Success" : "Failed")")
    group.leave()
}

group.enter()
DispatchQueue.global().async {
    let success = account.withdraw(amount: 800)
    print("Withdrawal of 800: \(success ? "Success" : "Failed")")
    group.leave()
}

group.wait()
print("Final balance: \(account.balance)")
// One withdrawal succeeds, the other fails. Balance never goes negative!


// Fix 2: Use a concurrent queue with a barrier for thread-safe array
class ThreadSafeArray<T> {
    private var array: [T] = []
    private let queue = DispatchQueue(label: "threadsafe.array",
                                       attributes: .concurrent)

    func append(_ item: T) {
        queue.async(flags: .barrier) {  // Barrier = exclusive write access
            self.array.append(item)
        }
    }

    var count: Int {
        return queue.sync { array.count }  // Concurrent reads are fine
    }

    var allItems: [T] {
        return queue.sync { array }
    }
}

let safeResults = ThreadSafeArray<Int>()

DispatchQueue.concurrentPerform(iterations: 100) { i in
    safeResults.append(i)  // Thread-safe!
}

// Wait a moment for barriers to complete
Thread.sleep(forTimeInterval: 0.1)
print("Count: \(safeResults.count)")  // Always 100!


// Fix 3: Avoid deadlocks — never sync to the same queue you're already on
let queue = DispatchQueue(label: "my.serial.queue")

queue.async {  // Use async instead for the outer block
    print("Outer block")

    // Option A: Use async for the inner block too
    DispatchQueue.global().async {
        print("Inner block on different queue")
    }
}

// Wait for demo
Thread.sleep(forTimeInterval: 0.5)


// ============================================================================
// BONUS: Modern Swift Concurrency with actors (Swift 5.5+)
// ============================================================================

// Actors are the modern way to handle shared mutable state in Swift.
// They automatically protect their properties from data races.

actor SafeBankAccount {
    var balance: Double = 1000.0

    func withdraw(amount: Double) -> Bool {
        // No manual locking needed! The actor handles it.
        if balance >= amount {
            balance -= amount
            print("Actor: Withdrew \(amount). Balance: \(balance)")
            return true
        }
        print("Actor: Insufficient funds.")
        return false
    }

    func deposit(amount: Double) {
        balance += amount
        print("Actor: Deposited \(amount). Balance: \(balance)")
    }
}

// Usage with async/await:
// Task {
//     let account = SafeBankAccount()
//     await account.deposit(amount: 500)      // Must use `await`
//     let success = await account.withdraw(amount: 200)
//     let currentBalance = await account.balance
//     print("Balance: \(currentBalance)")
// }


// ============================================================================
// BONUS: DispatchGroup for coordinating multiple async tasks
// ============================================================================

func fetchAllData() {
    let group = DispatchGroup()
    var userData: String?
    var postData: String?

    group.enter()
    DispatchQueue.global().async {
        Thread.sleep(forTimeInterval: 0.1)  // Simulate network call
        userData = "John Doe"
        group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
        Thread.sleep(forTimeInterval: 0.2)  // Simulate network call
        postData = "Hello World post"
        group.leave()
    }

    // Called when ALL tasks are done
    group.notify(queue: .main) {
        print("User: \(userData ?? "none"), Post: \(postData ?? "none")")
    }
}

fetchAllData()
Thread.sleep(forTimeInterval: 0.5)


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "What is a race condition?"
//    Answer: When multiple threads access shared data simultaneously and at
//    least one is writing, causing unpredictable results.
//
// 2. "How do you make code thread-safe in Swift?"
//    Answer: Use serial DispatchQueues, concurrent queues with barriers,
//    NSLock, or (modern Swift) actors. Each has trade-offs.
//
// 3. "What is a deadlock?"
//    Answer: Two or more threads waiting for each other to finish, so neither
//    can proceed. Common cause: sync dispatching to a queue you're already on.
//
// 4. "What are actors in Swift?"
//    Answer: A reference type (like class) that automatically serializes
//    access to its mutable state. You must use `await` to access actor
//    properties from outside, ensuring thread safety.
//
// 5. "What's the difference between sync and async dispatch?"
//    Answer: `sync` blocks the current thread until the work completes.
//    `async` submits the work and returns immediately.
// ============================================================================
