// =============================================================================
// EXAMPLE 6: Closure Capture Semantics in Loops
// =============================================================================
// Difficulty: Intermediate
// Topic:      Closures, Capture Lists, Value vs Reference Capture
//
// SCENARIO:
// You are building a button system where each button should print its own
// index number when tapped. But every button prints the SAME number!
// The bug is caused by closures capturing a variable by reference.
// =============================================================================

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

func createButtonHandlersBuggy() -> [() -> Void] {
    var handlers: [() -> Void] = []

    for i in 0..<5 {
        // BUG: The closure captures 'i' by REFERENCE.
        // By the time we call these closures, the loop has finished
        // and 'i' will be... well, let's see what happens.
        let index = i
        // Actually in Swift, 'let' in the loop creates a new constant each time,
        // so let's show the bug with a var instead:
        handlers.append {
            print("Button \(index) tapped")
        }
    }

    return handlers
}

// The above actually WORKS in Swift because 'let index = i' creates
// a new capture each time. Let's show the REAL bug with a mutable variable:

func createCountersBuggy() -> [() -> Int] {
    var counters: [() -> Int] = []
    var count = 0   // Single mutable variable shared by ALL closures

    for i in 0..<5 {
        count = i  // Update the shared variable
        // BUG: All closures capture the SAME 'count' variable by reference.
        // When called later, they all see count's final value (4).
        counters.append {
            return count
        }
    }

    return counters
}

func demoBuggy() {
    print("--- Buggy Counters ---")
    let counters = createCountersBuggy()
    for (i, counter) in counters.enumerated() {
        print("Counter \(i) returns: \(counter())")
    }
    // ALL print "4" instead of 0, 1, 2, 3, 4!
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// Closures in Swift capture variables by REFERENCE by default:
//   - The closure doesn't store a copy of the value at the time of creation.
//   - Instead, it stores a reference to the variable itself.
//   - When the closure executes later, it reads the variable's CURRENT value.
//
// In our loop:
//   - 'count' is a single var declared outside the loop.
//   - Each closure captures a reference to this same 'count'.
//   - After the loop, count = 4 (the last value assigned).
//   - When any closure executes, it reads count → 4.
//
// This is similar to the classic "var in a closure" bug in JavaScript.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Use a capture list to capture the VALUE
// ─────────────────────────────────────────────────────────────────────────────

// FIX APPROACH 1: Use a capture list [count]
func createCountersFixed1() -> [() -> Int] {
    var counters: [() -> Int] = []
    var count = 0

    for i in 0..<5 {
        count = i
        // FIX: [count] in the capture list creates a COPY of 'count'
        // at the time the closure is created.
        counters.append { [count] in
            return count
        }
    }

    return counters
}

// FIX APPROACH 2: Use a local 'let' constant inside the loop
func createCountersFixed2() -> [() -> Int] {
    var counters: [() -> Int] = []
    var count = 0

    for i in 0..<5 {
        count = i
        let capturedCount = count  // Create a new constant each iteration
        counters.append {
            return capturedCount   // Each closure captures its own constant
        }
    }

    return counters
}

// FIX APPROACH 3: Avoid the shared variable entirely — use the loop variable
func createCountersFixed3() -> [() -> Int] {
    var counters: [() -> Int] = []

    for i in 0..<5 {
        // 'i' is a new 'let' constant for each loop iteration in Swift!
        counters.append {
            return i
        }
    }

    return counters
}

func demoFixed() {
    print("--- Fix 1: Capture list [count] ---")
    let counters1 = createCountersFixed1()
    for (i, counter) in counters1.enumerated() {
        print("Counter \(i) returns: \(counter())")
    }

    print("\n--- Fix 2: Local let constant ---")
    let counters2 = createCountersFixed2()
    for (i, counter) in counters2.enumerated() {
        print("Counter \(i) returns: \(counter())")
    }

    print("\n--- Fix 3: Use loop variable directly ---")
    let counters3 = createCountersFixed3()
    for (i, counter) in counters3.enumerated() {
        print("Counter \(i) returns: \(counter())")
    }
    // All three correctly print 0, 1, 2, 3, 4
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Closures capture VARIABLES by REFERENCE by default.
//    They see the variable's current value when executed, not the value at
//    the time the closure was created.
//
// 2. Use CAPTURE LISTS [variableName] to capture a VALUE (copy) instead.
//    The copy is made at the time the closure is created.
//
// 3. Swift's for-in loop variable ('for i in ...') is a new 'let' constant
//    for each iteration. Closures capturing 'i' directly work correctly.
//
// 4. The bug appears when you capture a MUTABLE variable declared OUTSIDE
//    the loop that changes on each iteration.
//
// 5. This question tests your understanding of closures, scoping, and
//    value vs reference capture — all crucial for Apple interviews.
//
// 6. Capture list syntax:
//    { [capturedVar1, capturedVar2] (parameters) -> ReturnType in
//        // body
//    }
// ─────────────────────────────────────────────────────────────────────────────
