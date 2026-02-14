# Swift Debugging and Code Fixing for Interview Practice

This guide is for beginners who want to debug Swift code like an interview candidate.
It is practical, not theory-heavy.

Use this loop every time:

1. Reproduce the bug consistently.
2. Add breakpoints and inspect state.
3. Form one hypothesis.
4. Change one thing.
5. Re-run and verify.
6. Add a tiny test (or at least a repeatable check) so the bug does not return.

## Fast Xcode and LLDB cheat sheet

- Breakpoint: click the gutter next to a line.
- Step Over: `F6`
- Step Into: `F7`
- Step Out: `F8`
- Print value in debugger: `po variableName`
- Print type: `p type(of: variableName)`
- Backtrace on crash: `bt`
- Add symbolic breakpoint for all Swift fatal errors:
  - Symbol: `swift_willThrow` or `fatalError`

---

## Example 1: Crash from force unwrap

### Buggy code
```swift
func greeting(nameText: String?) -> String {
    return "Hello, \(nameText!)"
}
```

### Symptom
App crashes when `nameText` is `nil`.

### Debug
- Add breakpoint inside `greeting`.
- Run with `nameText = nil`.
- In debugger: `po nameText` shows `nil`.

### Fixed code
```swift
func greeting(nameText: String?) -> String {
    let safeName = nameText?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let name = safeName, !name.isEmpty else {
        return "Hello, Guest"
    }
    return "Hello, \(name)"
}
```

Interview point: explain why `guard let` is safer than `!`.

---

## Example 2: Index out of range

### Buggy code
```swift
let numbers = [10, 20, 30]
for i in 0...numbers.count {
    print(numbers[i])
}
```

### Symptom
Crash at last iteration with "Index out of range".

### Debug
- Breakpoint in loop body.
- Watch `i` and `numbers.count`.
- See that loop reaches `i == numbers.count`.

### Fixed code
```swift
let numbers = [10, 20, 30]
for i in 0..<numbers.count {
    print(numbers[i])
}
// or better:
for value in numbers {
    print(value)
}
```

Interview point: `..<` is half-open range, avoids upper-bound access.

---

## Example 3: Retain cycle in closure

### Buggy code
```swift
final class ProfileViewModel {
    var onUpdate: (() -> Void)?

    func load() {
        API.fetchProfile { result in
            self.onUpdate?()
        }
    }
}
```

### Symptom
`ProfileViewModel` is never deallocated.

### Debug
- Add `deinit { print("deinit") }`.
- Navigate away from screen and back.
- `deinit` never prints.

### Fixed code
```swift
final class ProfileViewModel {
    var onUpdate: (() -> Void)?

    func load() {
        API.fetchProfile { [weak self] result in
            guard let self else { return }
            self.onUpdate?()
        }
    }
}
```

Interview point: explain strong reference cycle with escaping closures.

---

## Example 4: UI update on background thread

### Buggy code
```swift
func loadTitle() {
    DispatchQueue.global().async {
        let title = expensiveCompute()
        self.titleLabel.text = title
    }
}
```

### Symptom
Random UI warnings, flicker, or inconsistent UI behavior.

### Debug
- Add breakpoint on UI update line.
- In debugger: `po Thread.isMainThread` is `false`.

### Fixed code
```swift
func loadTitle() {
    DispatchQueue.global().async {
        let title = expensiveCompute()
        DispatchQueue.main.async {
            self.titleLabel.text = title
        }
    }
}
```

Interview point: all UIKit updates must happen on main thread.

---

## Example 5: Data race with shared mutable state

### Buggy code
```swift
final class Counter {
    var value = 0
}

let counter = Counter()
await withTaskGroup(of: Void.self) { group in
    for _ in 0..<1000 {
        group.addTask {
            counter.value += 1
        }
    }
}
print(counter.value)
```

### Symptom
Final value is often less than 1000.

### Debug
- Re-run many times.
- Observe nondeterministic result.
- This indicates a race condition.

### Fixed code (actor isolation)
```swift
actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}

let counter = Counter()
await withTaskGroup(of: Void.self) { group in
    for _ in 0..<1000 {
        group.addTask {
            await counter.increment()
        }
    }
}
print(await counter.value)
```

Interview point: use `actor` for concurrent mutable state in Swift Concurrency.

---

## Example 6: Timer causes memory leak

### Buggy code
```swift
final class SessionController {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.pingServer()
        }
    }

    private func pingServer() {}
}
```

### Symptom
`SessionController` never deallocates.

### Debug
- Add `deinit` print.
- Open and close screen repeatedly.
- Memory grows, `deinit` not called.

### Fixed code
```swift
final class SessionController {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pingServer()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }

    private func pingServer() {}
}
```

Interview point: timers retain their target/closure strongly.

---

## Example 7: Codable decoding failure

### Buggy code
```swift
struct User: Decodable {
    let id: Int
    let isPremium: Bool
}
```

JSON:
```json
{
  "id": "42",
  "isPremium": "true"
}
```

### Symptom
Decoding throws type mismatch error.

### Debug
- Wrap decode in `do/catch`.
- Print exact error:
  ```swift
  do {
      let user = try JSONDecoder().decode(User.self, from: data)
      print(user)
  } catch {
      print(error)
  }
  ```

### Fixed code (custom decoding)
```swift
struct User: Decodable {
    let id: Int
    let isPremium: Bool

    enum CodingKeys: String, CodingKey {
        case id, isPremium
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let idString = try container.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "id is not a valid Int string"
            )
        }
        self.id = id

        let premiumString = try container.decode(String.self, forKey: .isPremium)
        self.isPremium = (premiumString as NSString).boolValue
    }
}
```

Interview point: robust parsing when backend contracts are inconsistent.

---

## Example 8: Binary search infinite loop

### Buggy code
```swift
func binarySearch(_ nums: [Int], _ target: Int) -> Int {
    var left = 0
    var right = nums.count - 1

    while left < right {
        let mid = (left + right) / 2
        if nums[mid] < target {
            left = mid
        } else {
            right = mid
        }
    }
    return nums[left] == target ? left : -1
}
```

### Symptom
Can loop forever for some inputs.

### Debug
- Test `nums = [1, 3]`, `target = 3`.
- Observe `left` gets stuck at `0`.
- Problem: bounds do not shrink.

### Fixed code
```swift
func binarySearch(_ nums: [Int], _ target: Int) -> Int {
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

Interview point: be explicit about loop invariant and boundary updates.

---

## Example 9: Mutating struct inside array does not persist

### Buggy code
```swift
struct Task {
    var title: String
    var done: Bool
}

var tasks = [Task(title: "Read", done: false)]

for task in tasks {
    if task.title == "Read" {
        var copy = task
        copy.done = true
    }
}

print(tasks[0].done) // false
```

### Symptom
Looks updated in loop, but original array is unchanged.

### Debug
- Understand value semantics: `task` is a copy.
- Print before and after loop to confirm no mutation.

### Fixed code
```swift
struct Task {
    var title: String
    var done: Bool
}

var tasks = [Task(title: "Read", done: false)]

if let idx = tasks.firstIndex(where: { $0.title == "Read" }) {
    tasks[idx].done = true
}

print(tasks[0].done) // true
```

Interview point: Swift structs are value types unless wrapped in reference semantics.

---

## Example 10: Stale async search results override new query

### Buggy code
```swift
final class SearchViewModel {
    var results: [String] = []

    func search(query: String) async {
        let newResults = await API.search(query)
        self.results = newResults
    }
}
```

### Symptom
User types quickly: older request returns late and overwrites newer results.

### Debug
- Log query and response arrival order.
- Reproduce with artificial delay in API.

### Fixed code (cancel previous task and track latest query)
```swift
@MainActor
final class SearchViewModel {
    private var searchTask: Task<Void, Never>?
    private var latestQuery: String = ""
    private(set) var results: [String] = []

    func search(query: String) {
        latestQuery = query
        searchTask?.cancel()

        searchTask = Task { [query] in
            let newResults = await API.search(query)
            guard !Task.isCancelled, query == self.latestQuery else { return }
            self.results = newResults
        }
    }
}
```

Interview point: discuss cancellation and out-of-order async responses.

---

## 2-week practice plan (beginner to interview-ready)

- Day 1-2: Examples 1-2 (optionals, bounds).
- Day 3-4: Examples 3 and 6 (memory management, retain cycles).
- Day 5-6: Examples 4-5 (threads, actors, concurrency).
- Day 7-8: Example 7 (Codable, error handling).
- Day 9-10: Example 8 (binary search invariants).
- Day 11-12: Examples 9-10 (value semantics, async correctness).
- Day 13-14: Redo all from memory and explain each fix out loud in under 2 minutes.

If you want, next I can generate:

1. A mock Apple-style Swift interview set (45 minutes),
2. A scoring rubric, and
3. Model answers with common mistakes.
