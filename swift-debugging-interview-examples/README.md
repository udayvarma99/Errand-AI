# Swift Debugging for Beginners (Interview Style)

This guide teaches you a practical way to debug Swift and fix bugs like interviewers expect.
Each example below has:

- broken code
- symptom
- root cause
- fixed code
- interview talking points

Use this in Xcode Playground or a small iOS sample app.

---

## A simple debugging workflow you can repeat

1. **Reproduce** the bug consistently.
2. **Read the exact error/crash** (do not guess).
3. **Add a breakpoint** near the failure point.
4. **Inspect runtime values** (`po variableName` in LLDB).
5. **Form one hypothesis** about root cause.
6. **Patch one thing**.
7. **Re-run and verify** with at least one normal case and one edge case.

### Xcode tools to use in interviews

- Breakpoints
- Debug area console
- LLDB commands: `po`, `p`, `bt`, `frame variable`
- Thread Sanitizer (for race conditions)
- Memory Graph (for retain cycles)

---

## Example 1: Crash from force unwrapping optional

### Broken code

```swift
func parseAge(_ text: String) -> Int {
    return Int(text)! // crashes for "abc"
}

let age = parseAge("abc")
print(age)
```

### Symptom

App crashes with: `Unexpectedly found nil while unwrapping an Optional value`.

### Root cause

`Int("abc")` returns `nil`, but `!` force unwraps it.

### Fixed code

```swift
enum ParseError: Error {
    case invalidAge
}

func parseAge(_ text: String) throws -> Int {
    guard let age = Int(text), age >= 0 else {
        throw ParseError.invalidAge
    }
    return age
}
```

### Interview talking point

Prefer `guard let` and explicit error handling over force unwraps in production code.

---

## Example 2: Array index out of range

### Broken code

```swift
let names = ["Ana", "Ben", "Chris"]

for i in 0...names.count { // includes names.count
    print(names[i])
}
```

### Symptom

Crash: `Index out of range`.

### Root cause

`0...names.count` includes the last value (`count`), which is not a valid index.

### Fixed code

```swift
let names = ["Ana", "Ben", "Chris"]

for i in 0..<names.count {
    print(names[i])
}
```

### Interview talking point

Know the difference between closed range (`...`) and half-open range (`..<`).

---

## Example 3: Retain cycle in closure

### Broken code

```swift
final class ProfileViewModel {
    var onSaved: (() -> Void)?
}

final class ProfileViewController {
    let viewModel = ProfileViewModel()

    func bind() {
        viewModel.onSaved = {
            self.showBanner() // strong capture of self
        }
    }

    func showBanner() {
        print("Saved")
    }
}
```

### Symptom

`ProfileViewController` never deallocates (memory leak).

### Root cause

`viewModel` holds closure strongly, closure holds `self` strongly -> retain cycle.

### Fixed code

```swift
final class ProfileViewModel {
    var onSaved: (() -> Void)?
}

final class ProfileViewController {
    let viewModel = ProfileViewModel()

    func bind() {
        viewModel.onSaved = { [weak self] in
            self?.showBanner()
        }
    }

    func showBanner() {
        print("Saved")
    }
}
```

### Interview talking point

Use `[weak self]` for escaping closures when `self` should not own callback lifetime.

---

## Example 4: UI updated on background thread

### Broken code

```swift
import UIKit

final class UserVC: UIViewController {
    @IBOutlet private weak var nameLabel: UILabel!

    func loadUser() {
        DispatchQueue.global().async {
            let name = "Taylor"
            self.nameLabel.text = name // background thread UI update
        }
    }
}
```

### Symptom

Main Thread Checker warning, random UI behavior.

### Root cause

UIKit must be updated on main thread.

### Fixed code

```swift
import UIKit

final class UserVC: UIViewController {
    @IBOutlet private weak var nameLabel: UILabel!

    func loadUser() {
        DispatchQueue.global().async {
            let name = "Taylor"
            DispatchQueue.main.async {
                self.nameLabel.text = name
            }
        }
    }
}
```

### Interview talking point

State clearly: "All UI mutations must happen on main thread."

---

## Example 5: Race condition on shared state

### Broken code

```swift
final class Counter {
    private var value = 0

    func increment() {
        value += 1 // unsafe if called from multiple threads
    }

    func read() -> Int {
        value
    }
}
```

### Symptom

Incorrect final count under concurrency.

### Root cause

Non-atomic read/write on shared mutable state.

### Fixed code (using actor)

```swift
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func read() -> Int {
        value
    }
}
```

### Interview talking point

For Swift concurrency, `actor` is a clean fix for data races.

---

## Example 6: Wrong Equatable logic

### Broken code

```swift
struct Product: Equatable {
    let id: String
    let name: String

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.name == rhs.name // wrong identity check
    }
}
```

### Symptom

Different products with same name are treated as equal.

### Root cause

Equality should use stable identity (`id`) for this domain.

### Fixed code

```swift
struct Product: Equatable {
    let id: String
    let name: String

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}
```

### Interview talking point

Define equality from business rules, not convenience.

---

## Example 7: Binary search infinite loop

### Broken code

```swift
func binarySearch(_ arr: [Int], target: Int) -> Int? {
    var left = 0
    var right = arr.count - 1

    while left < right {
        let mid = (left + right) / 2
        if arr[mid] < target {
            left = mid // bug: can get stuck
        } else {
            right = mid
        }
    }

    return arr[left] == target ? left : nil
}
```

### Symptom

Sometimes hangs or misses valid target.

### Root cause

Bounds do not move past `mid`, so loop can stop making progress.

### Fixed code

```swift
func binarySearch(_ arr: [Int], target: Int) -> Int? {
    var left = 0
    var right = arr.count - 1

    while left <= right {
        let mid = left + (right - left) / 2
        if arr[mid] == target {
            return mid
        } else if arr[mid] < target {
            left = mid + 1
        } else {
            right = mid - 1
        }
    }

    return nil
}
```

### Interview talking point

In binary search, always prove loop progress and termination.

---

## Example 8: `map` used instead of `compactMap`

### Broken code

```swift
let raw = ["1", "x", "3"]
let numbers = raw.map { Int($0) }   // [Int?]
let sum = numbers.reduce(0, +)      // compile error
print(sum)
```

### Symptom

Type mismatch at compile time.

### Root cause

`map` keeps optionals. You need to drop failed conversions.

### Fixed code

```swift
let raw = ["1", "x", "3"]
let numbers = raw.compactMap { Int($0) } // [Int]
let sum = numbers.reduce(0, +)
print(sum) // 4
```

### Interview talking point

Know standard library transforms deeply (`map`, `compactMap`, `flatMap`).

---

## Example 9: Unexpected shared mutation (class vs struct)

### Broken code

```swift
final class CartItem {
    var quantity: Int
    init(quantity: Int) { self.quantity = quantity }
}

let a = CartItem(quantity: 1)
let b = a
b.quantity = 10

print(a.quantity) // 10 (unexpected for many beginners)
```

### Symptom

Editing one variable changes another.

### Root cause

Classes are reference types; both variables point to same instance.

### Fixed code

```swift
struct CartItem {
    var quantity: Int
}

var a = CartItem(quantity: 1)
var b = a
b.quantity = 10

print(a.quantity) // 1
```

### Interview talking point

Use `struct` by default unless shared identity/reference semantics are required.

---

## Example 10: Deadlock with nested `sync`

### Broken code

```swift
let queue = DispatchQueue(label: "com.example.worker")

queue.sync {
    print("outer start")
    queue.sync { // deadlock
        print("inner")
    }
    print("outer end")
}
```

### Symptom

Code freezes forever.

### Root cause

A serial queue cannot execute inner `sync` while outer `sync` is still running.

### Fixed code

```swift
let queue = DispatchQueue(label: "com.example.worker")

queue.async {
    print("outer start")
    queue.async { // schedule separately
        print("inner")
    }
    print("outer end")
}
```

### Interview talking point

Be explicit about queue type (serial/concurrent) and sync/async behavior.

---

## 7-day practice routine (beginner-friendly)

- **Day 1-2:** Examples 1-3 (optionals, arrays, memory)
- **Day 3-4:** Examples 4-5 (threading + concurrency)
- **Day 5:** Examples 6-8 (correctness + stdlib)
- **Day 6:** Examples 9-10 (semantics + deadlocks)
- **Day 7:** Re-solve all 10 without reading fixes first

If you can explain the root cause out loud in under 60 seconds per bug, you are interview-ready at a strong beginner/intermediate level.
