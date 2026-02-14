// =============================================================================
// EXAMPLE 5: Closure Capture List Bug
// Topic: Closures capture variables by reference, leading to unexpected values
// Difficulty: Intermediate
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

// BUG 1: Closure captures the variable 'i' by REFERENCE
var closures: [() -> Int] = []
for i in 0..<5 {
    closures.append {
        return i  // Captures 'i' by reference — all closures share the same 'i'
    }
}

// Expected: 0, 1, 2, 3, 4
// Actual:   4, 4, 4, 4, 4  (all return the FINAL value of i)
for closure in closures {
    print(closure())
}


// BUG 2: Retain cycle with closure capturing 'self'
class ViewController {
    var name = "Main Screen"
    var onButtonTap: (() -> Void)?

    func setupButton() {
        onButtonTap = {
            // BUG: Strong capture of 'self' → retain cycle
            // self → onButtonTap (strong)
            // onButtonTap closure → self (strong)
            print("Button tapped on \(self.name)")
        }
    }

    deinit {
        print("\(name) is being deinitialized")  // NEVER called!
    }
}

var vc: ViewController? = ViewController()
vc?.setupButton()
vc?.onButtonTap?()
vc = nil  // deinit NEVER runs — memory leak!

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: In Swift, closures capture variables by REFERENCE, not by value.
//         When the for-loop ends, all closures share the same variable 'i',
//         which has its final value. So all closures return the same number.
//
// Bug 2: When a closure stored as a property captures 'self', it creates a
//         retain cycle:
//           self --strong--> closure (stored property)
//           closure --strong--> self (captured in closure body)
//         Neither can be deallocated → memory leak.
//

// =============================================================================
// FIXED CODE
// =============================================================================

// --- Fix 1: Use a capture list to capture the VALUE of 'i' ---

print("=== Fix 1: Closure capture list ===")

var closures: [() -> Int] = []
for i in 0..<5 {
    closures.append { [i] in   // FIX: [i] captures the CURRENT value of i
        return i
    }
}

// Now correctly prints: 0, 1, 2, 3, 4
for closure in closures {
    print(closure(), terminator: " ")
}
print()  // newline

// Alternative fix: Use a local constant (also captures by value)
var closures2: [() -> Int] = []
for i in 0..<5 {
    let capturedI = i  // Local constant captures current value
    closures2.append {
        return capturedI
    }
}

print("Alternative: ", terminator: "")
for closure in closures2 {
    print(closure(), terminator: " ")
}
print()

// --- Fix 2: Use [weak self] in closures to prevent retain cycles ---

class ViewController {
    var name = "Main Screen"
    var onButtonTap: (() -> Void)?

    func setupButton() {
        // FIX: [weak self] prevents the retain cycle
        onButtonTap = { [weak self] in
            // 'self' is now an Optional — must unwrap safely
            guard let self = self else {
                print("ViewController was already deallocated")
                return
            }
            print("Button tapped on \(self.name)")
        }
    }

    deinit {
        print("\(name) is being deinitialized")  // NOW this gets called!
    }
}

print("\n=== Fix 2: [weak self] in closures ===")
var vc: ViewController? = ViewController()
vc?.setupButton()
vc?.onButtonTap?()   // "Button tapped on Main Screen"
vc = nil              // "Main Screen is being deinitialized" — no memory leak!

// =============================================================================
// BONUS: Understanding capture semantics
// =============================================================================

print("\n=== Bonus: Capture by reference vs value ===")

var number = 10
let captureByReference = { print("By reference: \(number)") }
let captureByValue = { [number] in print("By value: \(number)") }

number = 99  // Change after closures are created

captureByReference()  // "By reference: 99" — sees the change
captureByValue()      // "By value: 10"     — locked to the original value

// =============================================================================
// BONUS: [weak self] vs [unowned self]
// =============================================================================

print("\n=== Bonus: weak vs unowned self ===")

class NetworkManager {
    var name = "NetworkManager"

    // Use [weak self] when the closure might outlive self
    func fetchDataSafe(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            print("\(self.name) fetched data safely")
            completion()
        }
    }

    deinit { print("\(name) deinitialized") }
}

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Closures capture variables by REFERENCE by default.
// Use capture lists [x] to capture by VALUE.
// Use [weak self] to prevent retain cycles with stored closures.
//
// In interviews, Apple engineers look for:
//   1. Understanding closure capture semantics (reference vs value)
//   2. Identifying retain cycles caused by closures
//   3. Knowing when to use [weak self] vs [unowned self]
//   4. Safely unwrapping weak self with guard let
//   5. Understanding @escaping vs non-escaping closures
//
// When to use what:
//   [weak self]    — closure may outlive self (most common, safest)
//   [unowned self] — you're certain self will always be alive when closure runs
//   no capture     — only for non-escaping closures that don't cause cycles
// =============================================================================
