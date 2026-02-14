# 10 Swift Debugging + Fixing Examples (Interview Style)

Each example below has:

- **Buggy code**: what a candidate might inherit
- **Symptom**: crash / wrong output / flaky behavior
- **How to debug**: what to look at first in Xcode / LLDB
- **Fix**: correct, interview-ready code
- **Takeaway**: the pattern to remember

> Note: some “buggy” snippets intentionally **do not compile** (that’s common in interviews). The *fixed* implementations you can run live in `Sources/DebugExamples/`.

---

## 1) Optional crash from `!`

### Buggy code

```swift
func parseAge(_ input: String) -> Int {
    return Int(input)!   // crashes on "abc"
}
```

### Symptom

- App crashes with: “Unexpectedly found nil while unwrapping an Optional value”

### How to debug

- Look at the **top frame** in the crash log / debugger.
- Inspect the value: `po input`
- Check why `Int(input)` is `nil`.

### Fix

Use a safe parse and return `nil` (or throw) for invalid input.

```swift
func parseAge(_ input: String) -> Int? {
    guard let age = Int(input), age >= 0 else { return nil }
    return age
}
```

### Takeaway

- `!` is a promise. If you can’t prove it, don’t use it.

---

## 2) Off-by-one range crash

### Buggy code

```swift
func sum(_ numbers: [Int]) -> Int {
    var total = 0
    for i in 0...numbers.count {      // count is out of bounds
        total += numbers[i]
    }
    return total
}
```

### Symptom

- “Index out of range” crash when `i == numbers.count`

### How to debug

- Add a breakpoint inside the loop.
- Inspect `i` and `numbers.count`.
- In LLDB: `po i`, `po numbers.count`

### Fix

```swift
func sum(_ numbers: [Int]) -> Int {
    var total = 0
    for i in 0..<numbers.count {
        total += numbers[i]
    }
    return total
}
```

### Takeaway

- Use `..<` for arrays. `...` includes the end.
- Even better: iterate values directly: `for x in numbers { total += x }`

---

## 3) Retain cycle in closure

### Buggy code

```swift
final class ViewModel {
    var onUpdate: (() -> Void)?

    func start() {
        onUpdate = {
            self.refreshUI() // self captured strongly
        }
    }

    func refreshUI() { /* ... */ }
}
```

### Symptom

- `ViewModel` never deallocates (memory leak)

### How to debug

- Add `deinit { print("deinit") }` and see it never prints.
- Use Xcode Memory Graph (retain cycle view).

### Fix

```swift
final class ViewModel {
    var onUpdate: (() -> Void)?

    func start() {
        onUpdate = { [weak self] in
            self?.refreshUI()
        }
    }

    func refreshUI() { /* ... */ }
}
```

### Takeaway

- Closures capture strongly by default. Use `[weak self]` when the closure is stored.

---

## 4) Data race / flaky counter

### Buggy code

```swift
final class Counter {
    var value = 0
    func increment() { value += 1 }
}
```

### Symptom

- Under concurrency, final value is sometimes wrong.

### How to debug

- If you can reproduce, enable **Thread Sanitizer** (Xcode Scheme → Diagnostics).
- Look for “data race” reports.

### Fix (Swift Concurrency)

```swift
actor Counter {
    private var value = 0
    func increment() { value += 1 }
    func get() -> Int { value }
}
```

### Takeaway

- Shared mutable state needs isolation (actor/lock/queue).

---

## 5) `Hashable`/`Equatable` contract bug

### Buggy code

```swift
struct User: Hashable {
    let id: Int
    let name: String

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name) // inconsistent with ==
    }
}
```

### Symptom

- `Set<User>` behaves strangely: duplicates, missing lookups, etc.

### How to debug

- Write a tiny repro with a `Set` and print counts.
- Check the rule: if `a == b` then `a.hashValue == b.hashValue` must be true.

### Fix

```swift
struct User: Hashable {
    let id: Int
    let name: String

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
```

### Takeaway

- Equality and hashing must use the **same identity fields**.

---

## 6) Sort comparator bug

### Buggy code

```swift
struct Player { let name: String; let score: Int }

func sortPlayers(_ players: [Player]) -> [Player] {
    players.sorted { $0.score < $1.score } // wants highest score first
}
```

### Symptom

- Output ordering is reversed from requirements.

### How to debug

- Print before/after.
- Add a unit test with a known expected order.

### Fix

```swift
func sortPlayers(_ players: [Player]) -> [Player] {
    players.sorted {
        if $0.score != $1.score { return $0.score > $1.score }
        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
    }
}
```

### Takeaway

- Make comparators reflect requirements and handle ties deterministically.

---

## 7) Date parsing bug (locale/timezone/thread-safety)

### Buggy code

```swift
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd"

func parse(_ s: String) -> Date? {
    formatter.date(from: s) // DateFormatter is not thread-safe
}
```

### Symptom

- Rare, hard-to-repro parsing issues when called from multiple threads.

### How to debug

- Add logging around inputs/outputs.
- Under concurrency, suspect shared mutable formatters.

### Fix

Create a formatter **per call** and pin `locale`/`timeZone` so parsing is deterministic.

```swift
func parseYYYYMMDD(_ s: String) -> Date? {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0)
    f.dateFormat = "yyyy-MM-dd"
    return f.date(from: s)
}
```

### Takeaway

- Don’t share `DateFormatter` across threads without protection.

---

## 8) JSON decoding mismatch (snake_case keys)

### Buggy code

```swift
struct APIUser: Decodable {
    let userId: Int
    let displayName: String
}
```

JSON:

```json
{ "user_id": 1, "display_name": "Sam" }
```

### Symptom

- Decoding throws `keyNotFound(...)`

### How to debug

- Print the raw JSON you’re decoding.
- Read the thrown decoding error (it includes a coding path).

### Fix

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let user = try decoder.decode(APIUser.self, from: data)
```

### Takeaway

- Match your model keys to the API: `CodingKeys` or decoding strategy.

---

## 9) Integer overflow

### Buggy code

```swift
func area(width: Int, height: Int) -> Int {
    width * height // can overflow for large inputs
}
```

### Symptom

- Wrong/negative values in production for large numbers.

### How to debug

- Add a test with big inputs.
- Use `multipliedReportingOverflow`.

### Fix

```swift
enum MathError: Error { case overflow }

func area(width: Int, height: Int) throws -> Int {
    let (result, overflow) = width.multipliedReportingOverflow(by: height)
    if overflow { throw MathError.overflow }
    return result
}
```

### Takeaway

- For “real” apps, treat overflow as an error or constrain inputs.

---

## 10) Hidden \(O(n^2)\) performance bug

### Buggy code

```swift
func intersection(_ a: [Int], _ b: [Int]) -> [Int] {
    var result: [Int] = []
    for x in a {
        if b.contains(x) { result.append(x) } // O(n) inside O(n)
    }
    return result
}
```

### Symptom

- Works in small tests but becomes slow with large arrays.

### How to debug

- Time it with large inputs.
- Use Time Profiler (Xcode Instruments) or quick timing prints.

### Fix

```swift
func intersection(_ a: [Int], _ b: [Int]) -> [Int] {
    let setB = Set(b)
    return a.filter { setB.contains($0) }
}
```

### Takeaway

- Recognize “contains in a loop” as a common \(O(n^2)\) smell.

