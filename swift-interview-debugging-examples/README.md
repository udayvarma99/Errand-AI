# Swift Debugging for Interviews (Beginner Friendly)

This guide is for beginners who want to **debug and fix Swift code** in an interview setting (including Apple-style rounds).

## How to think while debugging

Use this simple loop:

1. Reproduce the bug reliably.
2. Read the crash or wrong output carefully.
3. Form one hypothesis ("I think this line fails because...").
4. Verify with breakpoint, print, or unit test.
5. Fix only one thing at a time.
6. Re-run and confirm no new regressions.

In interviews, say your thought process out loud:
- "I can reproduce this with input X."
- "The failure suggests an out-of-range index."
- "I will add a guard and test edge cases."

## Xcode debugger tools you should use

- **Breakpoints**: stop on suspicious lines.
- **Step Over / Into / Out**: follow execution path.
- **Debug Area variables**: inspect values quickly.
- **LLDB commands**:
  - `po variableName` (print object/value)
  - `bt` (backtrace / call stack)
  - `thread list` (thread debugging)
- **Exception breakpoint**: catches crashes at throw point.

---

## 10 interview-style Swift bug fixing examples

Each example has:
- Buggy code
- What is wrong
- Fixed code
- Why interviewers like it

---

### 1) Crash from force unwrap (`!`)

**Buggy code**

```swift
func uppercaseFirstLetter(_ text: String?) -> String {
    return String(text!.first!).uppercased() + text!.dropFirst()
}
```

**What is wrong**
- Crashes when `text` is `nil` or empty (`""`).

**Fixed code**

```swift
func uppercaseFirstLetter(_ text: String?) -> String {
    guard let text, let first = text.first else { return "" }
    return String(first).uppercased() + text.dropFirst()
}
```

**Why interviewers like it**
- Tests optionals + defensive coding.

---

### 2) Index out of range

**Buggy code**

```swift
func thirdElement(_ arr: [Int]) -> Int {
    return arr[2]
}
```

**What is wrong**
- Crashes when array has fewer than 3 elements.

**Fixed code**

```swift
func thirdElement(_ arr: [Int]) -> Int? {
    guard arr.indices.contains(2) else { return nil }
    return arr[2]
}
```

**Why interviewers like it**
- Shows safe collection access and edge-case handling.

---

### 3) Off-by-one in loop

**Buggy code**

```swift
func sum(_ nums: [Int]) -> Int {
    var total = 0
    for i in 0...nums.count { // bug
        total += nums[i]
    }
    return total
}
```

**What is wrong**
- Closed range `0...nums.count` includes invalid index `nums.count`.

**Fixed code**

```swift
func sum(_ nums: [Int]) -> Int {
    var total = 0
    for i in 0..<nums.count {
        total += nums[i]
    }
    return total
}
```

Better:

```swift
func sum(_ nums: [Int]) -> Int {
    nums.reduce(0, +)
}
```

**Why interviewers like it**
- Very common bug under pressure.

---

### 4) Retain cycle with closure (`self` captured strongly)

**Buggy code**

```swift
final class ProfileViewModel {
    var onUpdate: (() -> Void)?

    func bind() {
        onUpdate = {
            self.refreshUI()
        }
    }

    func refreshUI() {}
}
```

**What is wrong**
- `self` is strongly captured by a closure property on `self`.
- Causes memory leak.

**Fixed code**

```swift
final class ProfileViewModel {
    var onUpdate: (() -> Void)?

    func bind() {
        onUpdate = { [weak self] in
            self?.refreshUI()
        }
    }

    func refreshUI() {}
}
```

**Why interviewers like it**
- Tests ARC, closures, iOS memory behavior.

---

### 5) UI update from background thread

**Buggy code**

```swift
func fetchName(label: UILabel) {
    Task {
        let name = await loadNameFromAPI()
        label.text = name // possible background thread update
    }
}
```

**What is wrong**
- UI updates should happen on the main thread.

**Fixed code**

```swift
@MainActor
func fetchName(label: UILabel) {
    Task {
        let name = await loadNameFromAPI()
        label.text = name
    }
}
```

Alternative:

```swift
Task {
    let name = await loadNameFromAPI()
    await MainActor.run {
        label.text = name
    }
}
```

**Why interviewers like it**
- Checks concurrency correctness for iOS apps.

---

### 6) Data race on shared state

**Buggy code**

```swift
final class Counter {
    private(set) var value = 0

    func increment() {
        value += 1 // unsafe if called from multiple threads
    }
}
```

**What is wrong**
- Multiple threads can mutate `value` at the same time.

**Fixed code (actor)**

```swift
actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
```

**Why interviewers like it**
- Modern Swift concurrency + thread safety.

---

### 7) Wrong dictionary counting logic

**Buggy code**

```swift
func frequency(_ words: [String]) -> [String: Int] {
    var map: [String: Int] = [:]
    for w in words {
        map[w] = 1 // resets every time
    }
    return map
}
```

**What is wrong**
- Count resets to 1 for repeated words.

**Fixed code**

```swift
func frequency(_ words: [String]) -> [String: Int] {
    var map: [String: Int] = [:]
    for w in words {
        map[w, default: 0] += 1
    }
    return map
}
```

**Why interviewers like it**
- Simple but easy-to-miss logic bug.

---

### 8) Binary search infinite loop / missed target

**Buggy code**

```swift
func binarySearch(_ nums: [Int], target: Int) -> Int {
    var left = 0, right = nums.count - 1
    while left < right {
        let mid = (left + right) / 2
        if nums[mid] == target { return mid }
        if nums[mid] < target {
            left = mid // bug
        } else {
            right = mid // bug
        }
    }
    return -1
}
```

**What is wrong**
- `left = mid` and `right = mid` can repeat same `mid` forever.

**Fixed code**

```swift
func binarySearch(_ nums: [Int], target: Int) -> Int {
    var left = 0, right = nums.count - 1
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

**Why interviewers like it**
- Classic algorithm correctness test.

---

### 9) Strong reference cycle between two classes

**Buggy code**

```swift
final class Person {
    var apartment: Apartment?
}

final class Apartment {
    var tenant: Person? // strong + strong cycle
}
```

**What is wrong**
- `Person` and `Apartment` hold each other strongly.
- Neither gets deallocated.

**Fixed code**

```swift
final class Person {
    var apartment: Apartment?
}

final class Apartment {
    weak var tenant: Person?
}
```

**Why interviewers like it**
- Core ARC knowledge for iOS engineers.

---

### 10) Mutating copy confusion with structs

**Buggy code**

```swift
struct Cart {
    var items: [String]
}

func addItem(_ cart: Cart, item: String) {
    var copy = cart
    copy.items.append(item)
}
```

**What is wrong**
- Structs are value types. Function modifies a local copy only.

**Fixed code**

```swift
struct Cart {
    var items: [String]
}

func addItem(_ cart: inout Cart, item: String) {
    cart.items.append(item)
}
```

Usage:

```swift
var cart = Cart(items: [])
addItem(&cart, item: "iPhone Case")
```

**Why interviewers like it**
- Tests value semantics and `inout`.

---

## How to practice for interview rounds

1. Copy one buggy snippet into Xcode Playground.
2. Reproduce the issue with a small test.
3. Fix and explain:
   - root cause,
   - why your fix works,
   - time/space impact if algorithmic.
4. Add edge-case tests (empty input, nil, single element, duplicates, large input).

If you can explain all 10 clearly, you are preparing at a strong interview level.
