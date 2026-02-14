# Swift Debugging (Beginner Friendly) + 10 Fixing Examples

This folder is a **self-contained Swift Package (SwiftPM)** you can open in Xcode or run from terminal.

## Quick start

- **Xcode**: open `SwiftDebuggingExamples/Package.swift`
- **Terminal**:
  - `cd SwiftDebuggingExamples`
  - `swift test`
  - `swift run SwiftDebuggingExamplesCLI`

> Note: the cloud dev VM for this repo may not have Swift installed, but the code is standard Swift 5.9+ and should work on macOS with Xcode 15+.

---

## A repeatable debugging workflow (what interviewers want)

When something is wrong, your job is to **reduce uncertainty fast**.

- **Reproduce**: get a reliable reproduction (inputs, device state, network, OS, build config).
- **Classify**:
  - **Compile error**: type system / generics / optionals / access control.
  - **Runtime crash**: out-of-bounds, force-unwrap, bad cast, `fatalError`, threading.
  - **Logic bug**: wrong output but “works”.
  - **Performance/memory**: slow UI, spikes, leaks.
- **Read the signal first**:
  - Crash: exception + stack trace + the first app frame in the backtrace.
  - Wrong output: add a focused test and print intermediate invariants.
- **Minimize**: make the smallest code that still fails (often reveals the root cause).
- **Inspect state** (Xcode + LLDB):
  - **Breakpoints**: line breakpoints, **exception breakpoint**, conditional breakpoint, symbolic breakpoint.
  - **LLDB basics**:
    - `bt` (backtrace)
    - `frame variable` (locals)
    - `po someValue` (pretty print)
    - `p someValue` (debug print)
    - `expr -l swift -- someExpr` (evaluate Swift)
    - `thread return` / `thread step-in/out/over` (advanced)
  - **Watchpoints** (when a variable changes unexpectedly):
    - Debug navigator → right-click variable → Watchpoint (or LLDB watchpoint commands).
- **Fix with invariants**:
  - Replace “hope” with `guard`, `precondition`, `assert`, and tests.
  - Make illegal states unrepresentable (types > comments).
- **Lock in the fix**:
  - Add/adjust a unit test that failed before and passes now.
  - Consider regressions: edge cases, concurrency, performance.

---

## 10 examples (broken → how to debug → fixed)

Each example below includes:

- **Broken code** (common interview-style bug)
- **How to debug** (what to look at)
- **Fixed code** (implemented in `Sources/SwiftDebuggingExamples/`)

### 1) Optional crash: force-unwrapping `nil`

**Symptom**: crash like `Unexpectedly found nil while unwrapping an Optional value`.

**Broken**:

```swift
func port(from text: String) -> Int {
    return Int(text)!   // crashes if text isn't numeric
}
```

**Debug**:
- Add an **exception breakpoint** and re-run.
- Inspect the value: `po text`
- Look at the call site to see what input reached you.

**Fix**: return optional or provide a default.

See: `Example01_Optionals.swift`

---

### 2) `Index out of range`: unsafe array indexing

**Symptom**: crash: `Fatal error: Index out of range`.

**Broken**:

```swift
let item = items[i] // i might be invalid
```

**Debug**:
- Break on the line and inspect `i` and `items.count`.
- Add `precondition(i >= 0 && i < items.count)` temporarily to catch earlier.

**Fix**: safe subscript / guard.

See: `Example02_SafeIndexing.swift`

---

### 3) Memory leak: retain cycle with a stored closure

**Symptom**: object never deinitializes; Instruments → Leaks / Allocations shows growth.

**Broken**:

```swift
downloader.onProgress = { progress in
    self.progress = progress // closure captures self strongly
}
```

**Debug**:
- Put `deinit { print("deinit") }` and verify it never fires.
- Instruments → **Leaks** / **Allocations** → find the reference cycle.

**Fix**: capture `[weak self]` (or redesign ownership).

See: `Example03_RetainCycleClosures.swift`

---

### 4) Value semantics bug: “I changed it, but nothing happened”

**Symptom**: no crash, but state doesn’t update.

**Broken**:

```swift
func add(_ item: String, to bag: Bag) {
    var copy = bag
    copy.items.append(item)
    // caller expected bag to change; it won't
}
```

**Debug**:
- Step through and watch `bag` vs `copy`.
- In Swift, `struct` is a **value type**; you’re mutating a copy.

**Fix**: use `inout` or return a new value.

See: `Example04_ValueSemantics.swift`

---

### 5) Data race: updating shared state from multiple tasks

**Symptom**: flaky tests, inconsistent counts, “sometimes wrong”.

**Broken**:

```swift
final class Counter {
    var value = 0
    func inc() { value += 1 } // not thread-safe
}
```

**Debug**:
- Enable **Thread Sanitizer** in Xcode scheme and reproduce.
- Look for TSAN warnings pointing at the conflicting accesses.

**Fix**: use an `actor` (or locks/serial queue).

See: `Example05_ConcurrencyActor.swift`

---

### 6) Off-by-one: binary search returns wrong index

**Symptom**: correct for many cases, wrong for edges (first/last element, missing value).

**Broken** (classic):

```swift
while low < high { ... } // wrong loop condition for some implementations
```

**Debug**:
- Create tests for edges: empty, 1 element, target < min, target > max.
- Print `low`, `high`, `mid` each iteration or use breakpoints with log actions.

**Fix**: correct invariants for bounds.

See: `Example06_BinarySearch.swift`

---

### 7) Performance bug: \(O(n^2)\) membership checks

**Symptom**: slow on large inputs.

**Broken**:

```swift
for x in a {
    if b.contains(x) { ... } // contains on Array is O(n)
}
```

**Debug**:
- Use Instruments → **Time Profiler**.
- Look for hot spots like repeated `Array.contains`.

**Fix**: convert to `Set` for average \(O(1)\) lookup.

See: `Example07_PerformanceSet.swift`

---

### 8) Date parsing bug: locale/timezone dependent formatter

**Symptom**: works on your machine, fails for other locales/time zones.

**Broken**:

```swift
let f = DateFormatter()
f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
return f.date(from: text) // can fail depending on locale settings
```

**Debug**:
- Print current locale: `po Locale.current`
- Unit test with forced locale/time zone.

**Fix**: set `locale = en_US_POSIX` and a fixed time zone when parsing fixed-format strings.

See: `Example08_DateParsing.swift`

---

### 9) Timer keeps object alive (leak-ish) + unexpected behavior

**Symptom**: view model never deallocates; timer continues firing.

**Broken**:

```swift
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    self.tick() // strong capture
}
```

**Debug**:
- Confirm `deinit` never runs.
- Instruments → Allocations; look for `NSTimer` / `Timer` retaining your object.

**Fix**: `[weak self]` + invalidate timer when done.

See: `Example09_Timer.swift`

---

### 10) Codable decoding fails: JSON keys don’t match Swift names

**Symptom**: decoding throws `keyNotFound` or values come out `nil`.

**Broken**:

```swift
struct User: Decodable {
    let userName: String // JSON is "user_name"
}
```

**Debug**:
- Print the raw JSON and compare keys.
- Catch and inspect the error: `do/catch` then `print(error)`.

**Fix**: define `CodingKeys` (or custom decode).

See: `Example10_CodableKeys.swift`

---

## Where the fixed implementations live

- `Sources/SwiftDebuggingExamples/` – fixed code + comments explaining the “broken” version
- `Sources/SwiftDebuggingExamplesCLI/main.swift` – runs a small demo
- `Tests/SwiftDebuggingExamplesTests/` – unit tests that lock in the fixes

