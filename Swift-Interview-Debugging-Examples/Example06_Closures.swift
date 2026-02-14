// ============================================================================
// EXAMPLE 6: Closure Capture List Bugs
// Difficulty: Intermediate
// Topic: How closures capture variables, capture lists, escaping closures
// ============================================================================

// ============================================================================
// WHAT ARE CLOSURES?
// ============================================================================
// A closure is a self-contained block of code that can be passed around and
// used in your code. Think of it as an unnamed function you can store in a
// variable or pass as an argument.
//
//   let greet = { (name: String) -> String in
//       return "Hello, \(name)!"
//   }
//   print(greet("Alice"))  // "Hello, Alice!"
//
// The tricky part: closures CAPTURE variables from their surrounding scope.
// This means they "remember" and can modify those variables even after the
// original scope has ended.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Closure captures variable by REFERENCE, not by value
var counter = 0
var closures: [() -> Void] = []

for i in 0..<5 {
    closures.append {
        print(i)  // BUG: Captures `i` by reference!
    }
}

// Developer expects: 0, 1, 2, 3, 4
for closure in closures {
    closure()  // Actually prints: 4, 4, 4, 4, 4 — Wait, this is wrong!
}
// Note: In Swift, for-loop variables are actually rebound each iteration,
// so this specific case works correctly. BUT the pattern below doesn't:

var value = 0
var closures2: [() -> Void] = []

for _ in 0..<5 {
    closures2.append {
        print(value)  // Captures `value` by reference
    }
    value += 1
}
// Developer expects: 0, 1, 2, 3, 4
for closure in closures2 {
    closure()  // Actually prints: 5, 5, 5, 5, 5  — BUG!
}


// Bug 2: Modifying captured variable unexpectedly
var greeting = "Hello"

let printGreeting = {
    print(greeting)
}

greeting = "Goodbye"  // Changed AFTER creating the closure

printGreeting()  // Prints "Goodbye", not "Hello"!
// BUG: Developer expected the closure to capture "Hello"


// Bug 3: Escaping closure accessing deallocated self
class DataManager {
    var data: [String] = []

    func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            // Simulate network delay
            sleep(2)
            self.data = ["Item 1", "Item 2"]  // BUG: strong capture of self
            completion()
        }
    }

    deinit {
        print("DataManager deallocated")
    }
}

var manager: DataManager? = DataManager()
manager?.fetchData {
    print("Data loaded!")
}
manager = nil
// DataManager is NOT deallocated until the async work completes!
// This might cause unexpected behavior if the view is dismissed.


// Bug 4: Closure used as a callback doesn't update the UI on main thread
class ViewController {
    var label: String = ""

    func loadData() {
        DispatchQueue.global().async {
            let data = "Fetched data"
            // BUG: Updating UI from background thread!
            self.label = data  // This should be on the main thread!
            print("Label updated to: \(self.label)")
        }
    }
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Closures capture variables BY REFERENCE. All closures share the
//         same `value` variable. By the time they execute, `value` is 5.
//
// Bug 2: Same issue — the closure captures the VARIABLE `greeting`, not its
//         VALUE at the time of creation. When `greeting` changes, the closure
//         sees the new value.
//
// Bug 3: The escaping closure holds a strong reference to `self`. Even after
//         `manager` is set to nil, the closure keeps the object alive.
//
// Bug 4: UIKit/SwiftUI require all UI updates on the main thread. Updating
//         from a background thread causes undefined behavior or crashes.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Use a capture list to capture the VALUE at creation time
var value = 0
var closures: [() -> Void] = []

for _ in 0..<5 {
    closures.append { [capturedValue = value] in  // Capture current value!
        print(capturedValue)
    }
    value += 1
}

for closure in closures {
    closure()  // Prints: 0, 1, 2, 3, 4  — Correct!
}


// Fix 2: Use a capture list to snapshot the variable's value
var greeting = "Hello"

let printGreeting = { [greeting] in  // Captures the VALUE "Hello"
    print(greeting)
}

greeting = "Goodbye"

printGreeting()  // Prints "Hello" — captured at creation time!


// Fix 3: Use [weak self] for escaping closures
class DataManager {
    var data: [String] = []

    func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in  // Weak capture!
            // Simulate network delay
            sleep(1)

            guard let self = self else {
                print("DataManager was deallocated, skipping work")
                return
            }
            self.data = ["Item 1", "Item 2"]
            completion()
        }
    }

    deinit {
        print("DataManager deallocated")
    }
}

// Now if the manager is set to nil, the closure won't prevent deallocation
var manager: DataManager? = DataManager()
manager?.fetchData {
    print("Data loaded!")
}
// If manager = nil before the async work completes, deinit IS called!


// Fix 4: Always dispatch UI updates to the main thread
class ViewController {
    var label: String = ""

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            let data = "Fetched data"

            // Switch to main thread for UI updates!
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.label = data
                print("Label updated to: \(self.label)")
            }
        }
    }
}

let vc = ViewController()
vc.loadData()


// ============================================================================
// BONUS: Understanding @escaping vs non-escaping closures
// ============================================================================

// Non-escaping (default): Closure is called BEFORE the function returns.
// The closure cannot outlive the function.
func performImmediately(action: () -> Void) {
    action()  // Called right here, right now
}

// @escaping: Closure might be called AFTER the function returns.
// Must be explicitly marked with @escaping.
func performLater(action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        action()  // Called 1 second later — after performLater has returned
    }
}

// Why it matters: @escaping closures need capture lists to avoid retain cycles.
// Non-escaping closures are safe because they can't outlive the current scope.


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "How do closures capture variables?"
//    Answer: By reference by default. The closure can read and modify the
//    original variable. Use a capture list `[x]` to capture by value.
//
// 2. "What's the difference between @escaping and non-escaping?"
//    Answer: Non-escaping closures are called before the function returns
//    (default). @escaping closures may be stored and called later. Escaping
//    closures require `self.` when accessing instance properties.
//
// 3. "How do you prevent retain cycles in closures?"
//    Answer: Use `[weak self]` or `[unowned self]` in the capture list.
//    `weak self` is safer because it becomes nil if the object is freed.
//
// 4. "Why must UI updates be on the main thread?"
//    Answer: UIKit is not thread-safe. All drawing and view hierarchy changes
//    must happen on the main thread to avoid undefined behavior and crashes.
// ============================================================================
