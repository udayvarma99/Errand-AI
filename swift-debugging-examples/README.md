# Swift Debugging Guide for Apple Interviews 🍎

A beginner-friendly guide to debugging and fixing Swift code, with 10 practical examples common in Apple-level interviews.

## How to Debug Swift Code (Beginner's Guide)

### 1. **Use Print Statements**
```swift
print("Value of x: \(x)")  // Basic debugging
```

### 2. **Use Breakpoints in Xcode**
- Click on the line number gutter to add a breakpoint
- Run with Debug (⌘Y to toggle breakpoints)
- Use **Debug Console** to inspect variables with `po variableName`

### 3. **LLDB Commands** (when paused at breakpoint)
- `po variable` - Print object description
- `p variable` - Print raw value
- `frame variable` - See all local variables
- `continue` or `c` - Continue execution

### 4. **Common Error Types**
| Error | What it means |
|-------|---------------|
| Force unwrap crash | You used `!` on nil |
| Index out of range | Array access beyond bounds |
| Optional unwrapping | Forgot to handle nil with `if let` or `guard` |

---

## 10 Swift Debugging Examples

Each example folder contains:
- `buggy.swift` - Code with intentional bugs
- `fixed.swift` - Corrected version
- `explanation.md` - What was wrong and how to fix it

### Example Topics (Apple Interview Favorites)

1. **Optional Handling** - Force unwrap crashes, nil coalescing
2. **Array Bounds** - Index out of range errors
3. **Retain Cycles** - Memory leaks with closures
4. **Value vs Reference** - Struct vs Class gotchas
5. **Thread Safety** - Main thread UI updates
6. **Protocol Conformance** - Missing requirements
7. **Closure Capture** - `[weak self]` and `[unowned self]`
8. **Equality & Hashable** - Custom type comparison bugs
9. **String Indices** - Swift's tricky string indexing
10. **Async/Await** - Concurrency and actor isolation

---

## Quick Debugging Checklist

- [ ] Is it nil? Add `if let` or `guard let`
- [ ] Is the index valid? Check `array.indices.contains(index)`
- [ ] Are you on main thread for UI? Use `DispatchQueue.main.async`
- [ ] Memory leak? Check for `[weak self]` in closures
- [ ] Read the error message - Swift's compiler is helpful!

---

## How to Practice

1. **Open each example** - Start with `buggy.swift` and try to find the bug yourself
2. **Run it** (optional) - Use Xcode or `swift buggy.swift` to see the error
3. **Compare** - Look at `fixed.swift` and `explanation.md` after you've tried
4. **Memorize patterns** - guard let, [weak self], DispatchQueue.main.async - these appear constantly!

### Run from Terminal (if Swift installed)
```bash
cd swift-debugging-examples/01-optional-handling
swift buggy.swift   # See the crash
swift fixed.swift   # See it work
```

---

Good luck with your Apple interview! 🚀
