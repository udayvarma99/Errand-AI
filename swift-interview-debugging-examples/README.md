# Swift Debugging Guide for Apple Interview Prep

A beginner-friendly guide to debugging and fixing Swift code, with 10 real examples commonly seen in Apple-level technical interviews.

## 🎯 Debugging Mindset

1. **Read the error message** – Swift's compiler is helpful; it often tells you exactly what's wrong
2. **Use breakpoints** – Pause execution and inspect variables in Xcode (⌘\)
3. **Print debugging** – `print()` or `dump()` to trace values
4. **Think step-by-step** – What did you expect vs. what actually happened?

## 🛠 Key Swift Debugging Tools

| Tool | When to Use |
|------|-------------|
| **LLDB** | Step through code, inspect variables at runtime |
| **breakpoint** | Pause at specific line to inspect state |
| **po variable** | In debugger console: print object description |
| **Assertions** | `assert()`, `precondition()` for catching invalid states |

## 📁 Example Structure

Each example has:
- `Example_X_Broken.swift` – Code with a bug (try to find it!)
- `Example_X_Fixed.swift` – The corrected version
- Brief explanation of the fix

## 🐛 10 Common Swift Bugs (Apple Interview Level)

| # | Topic | What You'll Learn |
|---|-------|-------------------|
| 1 | Force Unwrap Crash | Safe optional handling |
| 2 | Array Index Out of Bounds | Bounds checking |
| 3 | Retain Cycle (Memory Leak) | `weak`/`unowned` in closures |
| 4 | Value vs Reference Type | `struct` mutation, `let` vs `var` |
| 5 | Optional Chaining Pitfall | When `?.` returns `nil` |
| 6 | Protocol Type Requirement | Associated types, `Self` |
| 7 | Closure Capturing | Escaping vs non-escaping |
| 8 | Async/Await Mistake | Main actor, UI updates |
| 9 | Switch Exhaustiveness | Handling all enum cases |
| 10 | Thread Safety | Data races, `@MainActor` |

Run examples with: `swift Example_X_Broken.swift` (or open in Xcode/Playgrounds)

---

## 📋 Quick Reference: Fix Checklist

| Bug | Quick Fix |
|-----|-----------|
| **Force unwrap (!)** | Use `??`, `if let`, or `guard let` |
| **Index out of bounds** | `guard !array.isEmpty` before `array[0]` |
| **Retain cycle** | Add `[weak self]` in closures capturing self |
| **Can't mutate struct** | Change `let` to `var` or create new instance |
| **Optional chaining silent fail** | Check `if x != nil` before assigning through `?.` |
| **Self in protocol** | Use `type(of: self).init(...)` + `required init` |
| **Closure storage error** | Add `@escaping` to closure parameter |
| **UI update crash** | Use `@MainActor` or `MainActor.run` |
| **Switch not exhaustive** | Add missing cases or `default` |
| **Data race** | Use `actor`, serial `DispatchQueue`, or lock |

Good luck with your interviews! 🍎
