# Swift Debugging + Fixing Code (10 Interview-Style Examples)

This folder is a **self-contained Swift Package** that teaches beginner-friendly debugging skills using **10 realistic “bug → debug → fix” examples** you’d see in iOS/macOS interviews.

Even if you’re brand new to Swift, you can work through these in order.

## How to run

### Option A: Xcode (recommended)

1. Open Xcode
2. `File → Open…` and select this folder (`SwiftDebuggingInterviewExamples/`)
3. Set the scheme to `Runner`
4. Run (`⌘R`) and use breakpoints / debugger console

### Option B: Command line (macOS or Linux with Swift installed)

```bash
cd SwiftDebuggingInterviewExamples
swift test
swift run Runner
```

## Debugging workflow (what interviewers want to see)

When you hit a bug, narrate a tight loop:

1. **Reproduce**: smallest input that fails.
2. **Observe**: exact symptom (crash? wrong output? slow? flaky?).
3. **Localize**: where is the state first “wrong”?
4. **Inspect**: print/breakpoints + check invariants.
5. **Fix**: make the smallest correct change.
6. **Prevent**: add a unit test and a guard/assert.

## LLDB / Debugger essentials (Xcode)

- `po someValue` prints Swift values nicely
- `bt` shows the call stack (backtrace)
- `thread backtrace all` for multi-thread issues
- Add **symbolic breakpoints** (e.g. `swift_willThrow`, `swift_fatalError`)

## The 10 examples

All examples are documented in `docs/10-examples.md` and the **fixed** implementations live in `Sources/DebugExamples/`.

1. Optional crash (`!`) → safe parsing + `guard`
2. Off-by-one (`0...count`) → correct ranges (`..<`)
3. Retain cycle in closure → `[weak self]`
4. Data race on shared state → `actor`
5. `Hashable`/`Equatable` contract bug → consistent hashing/equality
6. Sort comparator bug → stable, correct ordering
7. Date parsing bug (formatter/thread-safety/timezone) → safer parsing
8. JSON decoding mismatch → `CodingKeys` / `convertFromSnakeCase`
9. Integer overflow → `multipliedReportingOverflow`
10. Hidden \(O(n^2)\) → `Set`-based \(O(n)\)

