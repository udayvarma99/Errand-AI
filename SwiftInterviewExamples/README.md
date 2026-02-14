# Swift Debugging Guide for Apple Interviews 🍎

A beginner-friendly guide to debugging Swift code, with 10 interview-ready examples.

## Quick Debugging Tips for Beginners

### 1. **Use Print Statements**
```swift
print("Value of x: \(x)")
```
Simple but effective—see values at different points in your code.

### 2. **Use LLDB Breakpoints in Xcode**
- Click in the gutter (left of line numbers) to add a breakpoint
- Run with ⌘+B or Debug → Run
- Use `po variableName` in the console to inspect values

### 3. **Common Error Types to Watch For**
| Error | Cause | Fix |
|-------|-------|-----|
| `nil` unwrapping crash | Force unwrapping `!` on optional that's nil | Use `if let` or `guard let` |
| Index out of bounds | Accessing array index that doesn't exist | Check `index < array.count` |
| Retain cycle | Strong references between closures and self | Use `[weak self]` in closures |
| Wrong type | Type mismatch | Use proper casting or fix types |

### 4. **Swift-Specific Debugging Patterns**
- **Optionals**: Always ask "could this be nil?" before using `!`
- **Value vs Reference**: Structs are copied; classes are referenced
- **Closures**: Watch for `self` capture—use `[weak self]` when needed

### 5. **Interview Strategy**
1. **Read the error message**—Swift errors often point to the exact line
2. **Trace the data flow**—where does the buggy value come from?
3. **Test edge cases**—empty arrays, nil, single element
4. **Explain your fix**—interviewers want to see your reasoning

---

## The 10 Examples

Each example has:
- **Buggy Code** (`ExampleX_Buggy.swift`) — Code with intentional bugs
- **Fixed Code** (`ExampleX_Fixed.swift`) — Corrected version
- **Explanation** — What went wrong and why

Run them in Xcode or Swift Playground to practice!

| # | Topic | Difficulty |
|---|-------|------------|
| 1 | Optional Unwrapping | ⭐ Easy |
| 2 | Array Index Bounds | ⭐ Easy |
| 3 | Force Unwrap Crash | ⭐ Easy |
| 4 | Mutating in Loop | ⭐⭐ Medium |
| 5 | Closure Capture | ⭐⭐ Medium |
| 6 | Retain Cycle | ⭐⭐ Medium |
| 7 | Equatable / Reference Comparison | ⭐⭐ Medium |
| 8 | Dictionary Key Handling | ⭐⭐ Medium |
| 9 | Async/Thread Safety | ⭐⭐⭐ Hard |
| 10 | Protocol Conformance | ⭐⭐⭐ Hard |

---

## How to Practice

1. **Open each `*_Buggy.swift` file** — Try to spot the bug before running
2. **Run the code** — See the crash or unexpected behavior
3. **Compare with `*_Fixed.swift`** — Understand the correct approach
4. **Read [EXPLANATIONS.md](EXPLANATIONS.md)** — Deeper dive into each bug

## Apple Interview Focus Areas

These examples cover patterns Apple interviewers often test:

- **Optional safety** (Examples 1, 2, 3, 8) — Very common in iOS codebases
- **Memory management** (Examples 5, 6) — Critical for production apps
- **Concurrency** (Example 9) — Important for performant apps
- **Protocols & generics** (Example 10) — Swift's type system
