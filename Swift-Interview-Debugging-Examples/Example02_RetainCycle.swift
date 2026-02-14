// =============================================================================
// EXAMPLE 2: Retain Cycle / Memory Leak in Closures
// =============================================================================
// Difficulty: Beginner-Intermediate
// Topic:      ARC (Automatic Reference Counting), Closures, Memory Management
//
// SCENARIO:
// You are building a network manager that fetches data from an API. It stores
// a completion handler closure. The closure captures 'self', creating a strong
// reference cycle — neither object can ever be deallocated (memory leak).
// =============================================================================

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

class NetworkManagerBuggy {
    var onDataReceived: (() -> Void)?

    deinit {
        print("NetworkManagerBuggy deallocated")
    }
}

class ViewControllerBuggy {
    var networkManager = NetworkManagerBuggy()
    var data: String = ""

    func fetchData() {
        // BUG: This closure captures 'self' strongly.
        // self -> networkManager -> onDataReceived closure -> self
        // This creates a RETAIN CYCLE. Neither object will ever be freed.
        networkManager.onDataReceived = {
            self.data = "Fetched data"
            print("Data: \(self.data)")
        }
    }

    deinit {
        print("ViewControllerBuggy deallocated")
    }
}

func demoBuggy() {
    var vc: ViewControllerBuggy? = ViewControllerBuggy()
    vc?.fetchData()
    vc?.networkManager.onDataReceived?()
    vc = nil
    // PROBLEM: You will NOT see "ViewControllerBuggy deallocated" printed!
    // The retain cycle keeps both objects alive forever = MEMORY LEAK.
    print("demoBuggy finished — notice deinit was NOT called!\n")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// Swift uses ARC (Automatic Reference Counting) to manage memory:
//   - Each object has a "reference count."
//   - When the count reaches 0, the object is deallocated.
//
// The problem:
//   ViewControllerBuggy has a strong reference to NetworkManagerBuggy.
//   NetworkManagerBuggy.onDataReceived (a closure) has a strong reference
//   back to ViewControllerBuggy (through 'self').
//
//   self ──strong──▶ networkManager ──strong──▶ closure ──strong──▶ self
//        ◀──────────────────────────────────────────────────────────┘
//
//   This is a CYCLE. Neither reference count can ever reach 0.
//
// In Apple interviews, retain cycles are one of the MOST commonly tested
// topics. You MUST know how to spot and fix them.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Using [weak self] in the closure capture list
// ─────────────────────────────────────────────────────────────────────────────

class NetworkManagerFixed {
    var onDataReceived: (() -> Void)?

    deinit {
        print("NetworkManagerFixed deallocated")
    }
}

class ViewControllerFixed {
    var networkManager = NetworkManagerFixed()
    var data: String = ""

    func fetchData() {
        // FIX: Add [weak self] to the closure's capture list.
        // 'weak' means the closure does NOT increase the reference count.
        // 'self' becomes an optional inside the closure.
        networkManager.onDataReceived = { [weak self] in
            // Since self is now optional, we use 'guard let' to safely unwrap.
            guard let self = self else {
                print("self was already deallocated — skipping.")
                return
            }
            self.data = "Fetched data"
            print("Data: \(self.data)")
        }
    }

    deinit {
        print("ViewControllerFixed deallocated")
    }
}

func demoFixed() {
    var vc: ViewControllerFixed? = ViewControllerFixed()
    vc?.fetchData()
    vc?.networkManager.onDataReceived?()
    vc = nil
    // NOW you will see both "deallocated" messages printed!
    print("demoFixed finished — deinit WAS called!\n")
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// BONUS: [weak self] vs [unowned self]
// ─────────────────────────────────────────────────────────────────────────────
//
// [weak self]
//   - self becomes Optional (self?)
//   - Safe: if self is deallocated, it becomes nil (no crash)
//   - USE WHEN: the closure may outlive self
//
// [unowned self]
//   - self is NOT optional (no need to unwrap)
//   - DANGEROUS: if self is deallocated, accessing it CRASHES
//   - USE WHEN: you are 100% sure self will always outlive the closure
//
// INTERVIEW TIP: Default to [weak self]. Only use [unowned self] if you
// can explain exactly why self is guaranteed to be alive.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. A RETAIN CYCLE occurs when two objects hold strong references to each
//    other, preventing either from being deallocated.
//
// 2. Closures can create retain cycles when they capture 'self' strongly.
//
// 3. Fix with [weak self] in the closure's capture list.
//
// 4. Always check: "Does this closure outlive the object that created it?"
//    If yes, use [weak self].
//
// 5. Use Xcode's Memory Graph Debugger to find retain cycles in real apps.
//
// 6. Common places where retain cycles hide:
//    - Completion handlers stored as properties
//    - NotificationCenter observers (pre-iOS 9)
//    - Timer callbacks
//    - Delegation (if delegate is not 'weak')
// ─────────────────────────────────────────────────────────────────────────────
