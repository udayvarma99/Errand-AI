# Swift Debugging and Fixing Guide (Beginner -> Apple-style Interview)

This guide gives you a practical way to debug Swift code and 10 interview-style bug fixing examples.

## A simple debugging workflow you can reuse

1. Reproduce the bug consistently.
2. Read the crash message or failing test first.
3. Add breakpoints near the failure point.
4. Inspect values (`po`, `p`, `bt` in LLDB) and assumptions.
5. Fix one thing at a time, then rerun.

Helpful LLDB commands:

- `po variableName` -> print object/value
- `p variableName` -> print primitive
- `bt` -> stack trace (backtrace)
- `thread list` -> inspect threads

---

## 1) Crash from force unwrapping an Optional

### Broken code

```swift
func username(from dict: [String: Any]) -> String {
    return dict["username"] as! String
}
```

### Why it fails

If the key is missing or not a `String`, app crashes at runtime.

### How to debug

- Set a breakpoint on this function.
- Inspect `dict` with `po dict`.
- Confirm whether `username` exists and type matches.

### Fixed code

```swift
func username(from dict: [String: Any]) -> String? {
    return dict["username"] as? String
}
```

Interview point: Prefer safe casts and explicit handling over `as!`.

---

## 2) Array index out of range

### Broken code

```swift
let numbers = [10, 20, 30]
for i in 0...numbers.count {
    print(numbers[i])
}
```

### Why it fails

`0...numbers.count` includes `count`, which is out of bounds.

### How to debug

- Crash says "Index out of range".
- Add breakpoint in loop and inspect `i` right before crash.

### Fixed code

```swift
let numbers = [10, 20, 30]
for i in 0..<numbers.count {
    print(numbers[i])
}
```

Interview point: Use half-open ranges (`..<`) for indices.

---

## 3) Off-by-one bug in binary search

### Broken code

```swift
func binarySearch(_ nums: [Int], target: Int) -> Int {
    var left = 0
    var right = nums.count - 1

    while left < right {
        let mid = (left + right) / 2
        if nums[mid] == target { return mid }
        if nums[mid] < target {
            left = mid
        } else {
            right = mid - 1
        }
    }

    return -1
}
```

### Why it fails

`left = mid` can get stuck forever when `left + 1 == right`.

### How to debug

- Step through with a small input.
- Watch `left`, `right`, `mid` values.
- Notice values stop changing.

### Fixed code

```swift
func binarySearch(_ nums: [Int], target: Int) -> Int {
    var left = 0
    var right = nums.count - 1

    while left <= right {
        let mid = left + (right - left) / 2
        if nums[mid] == target { return mid }
        if nums[mid] < target {
            left = mid + 1
        } else {
            right = mid - 1
        }
    }

    return -1
}
```

Interview point: Clearly define loop invariant and boundary updates.

---

## 4) Retain cycle with closure capture

### Broken code

```swift
final class ProfileViewController: UIViewController {
    var onDataLoaded: (() -> Void)?

    func bind() {
        onDataLoaded = {
            self.title = "Loaded"
        }
    }
}
```

### Why it fails

`self` strongly captures closure and closure is stored on `self` -> cycle.

### How to debug

- Use Xcode Memory Graph.
- Navigate away and verify controller is not deallocated.

### Fixed code

```swift
final class ProfileViewController: UIViewController {
    var onDataLoaded: (() -> Void)?

    func bind() {
        onDataLoaded = { [weak self] in
            self?.title = "Loaded"
        }
    }
}
```

Interview point: Be deliberate with capture lists (`[weak self]`, `[unowned self]`).

---

## 5) UI update from background thread

### Broken code

```swift
func loadProfile() {
    DispatchQueue.global().async {
        let name = "Taylor"
        self.nameLabel.text = name
    }
}
```

### Why it fails

UIKit must be updated on main thread.

### How to debug

- Enable Main Thread Checker in scheme diagnostics.
- Set breakpoint on line that updates label.
- Check thread info with `thread list`.

### Fixed code

```swift
func loadProfile() {
    DispatchQueue.global().async {
        let name = "Taylor"
        DispatchQueue.main.async {
            self.nameLabel.text = name
        }
    }
}
```

Interview point: Concurrency correctness is as important as algorithm correctness.

---

## 6) Data race in shared mutable state

### Broken code

```swift
final class Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func current() -> Int {
        value
    }
}
```

### Why it fails

If called from multiple threads, `value += 1` is not atomic.

### How to debug

- Run with Thread Sanitizer enabled.
- Reproduce with concurrent queue calls.

### Fixed code (using actor)

```swift
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func current() -> Int {
        value
    }
}
```

Interview point: Prefer `actor` for shared mutable state in modern Swift.

---

## 7) Wrong value semantics assumption

### Broken code

```swift
struct CartItem {
    var quantity: Int
}

func increase(_ item: CartItem) {
    var copy = item
    copy.quantity += 1
}

var item = CartItem(quantity: 1)
increase(item)
print(item.quantity) // expected 2, got 1
```

### Why it fails

`struct` is value type; function changes a copy.

### How to debug

- Add breakpoints inside and outside function.
- Compare addresses/values and track mutation path.

### Fixed code

```swift
struct CartItem {
    var quantity: Int
}

func increase(_ item: inout CartItem) {
    item.quantity += 1
}

var item = CartItem(quantity: 1)
increase(&item)
print(item.quantity) // 2
```

Interview point: Explain value vs reference semantics clearly.

---

## 8) `Codable` decode fails due to key mismatch

### Broken code

```swift
struct User: Decodable {
    let userId: Int
    let fullName: String
}
```

JSON:

```json
{
  "user_id": 42,
  "full_name": "Chris Lee"
}
```

### Why it fails

Swift property names do not match snake_case JSON keys.

### How to debug

- Catch decode error and print it.
- Inspect coding path from `DecodingError`.

### Fixed code

```swift
struct User: Decodable {
    let userId: Int
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case fullName = "full_name"
    }
}
```

Interview point: Model API contracts explicitly and safely.

---

## 9) Incorrect `Equatable` logic causes wrong deduping

### Broken code

```swift
struct Employee: Equatable {
    let id: Int
    let name: String

    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.name == rhs.name
    }
}
```

### Why it fails

Two different employees with same name are treated as equal.

### How to debug

- Write a unit test for two employees with same name, different id.
- Trace where `contains`/`Set` behaves unexpectedly.

### Fixed code

```swift
struct Employee: Equatable, Hashable {
    let id: Int
    let name: String

    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
```

Interview point: Equality should represent logical identity, not convenience.

---

## 10) Cancellation not handled in async task

### Broken code

```swift
func fetchLargeReport() async throws -> Data {
    let url = URL(string: "https://example.com/report")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

### Why it fails

If task is cancelled, expensive work may continue and UI may update late.

### How to debug

- Create a task, cancel quickly, observe behavior.
- Use breakpoints/logging before and after network call.

### Fixed code

```swift
func fetchLargeReport() async throws -> Data {
    try Task.checkCancellation()
    let url = URL(string: "https://example.com/report")!
    let (data, _) = try await URLSession.shared.data(from: url)
    try Task.checkCancellation()
    return data
}
```

Interview point: Show that you design for cancellation and responsiveness.

---

## How to practice for interview rounds

1. For each example, try to explain:
   - root cause
   - how you reproduced it
   - why your fix is correct
   - time/space/concurrency tradeoffs
2. Write 1 unit test per bug to prevent regressions.
3. Practice saying your debugging process out loud in 60-90 seconds.

If you want, next step I can create a second file with 10 "broken-only" exercises plus hidden solutions so you can practice as a mock interview.
