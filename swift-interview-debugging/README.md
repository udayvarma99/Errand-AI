# Swift Debugging Guide for Apple Interviews

A beginner-friendly guide to debugging and fixing Swift code, with **10 real examples** commonly seen in Apple-level interviews.

---

## 🎯 Core Debugging Concepts

### 1. **Read the Error Message**
Swift has excellent error messages. Look for:
- **Line numbers** – where did it break?
- **Error type** – crash, compile error, or logic bug?
- **Thread** – main thread vs background?

### 2. **Use Print & Breakpoints**
```swift
print("Debug: value = \(value)")
// Or use breakpoints and LLDB: po variableName
```

### 3. **Common Swift Bug Categories**
| Category | What to check |
|----------|---------------|
| Optionals | Force unwrap `!` causing crashes |
| Closures | Retain cycles, wrong capture list |
| Threading | UI updates off main thread |
| Arrays | Index out of bounds |
| Types | Value vs reference (struct vs class) |

---

## 📋 The 10 Examples

Each example has:
- **Bug** – Code that fails or behaves wrongly
- **Fix** – Corrected version
- **Interview tip** – What Apple interviewers look for

| # | Topic | File |
|---|-------|------|
| 1 | Optional force unwrap crash | `Example01_ForceUnwrap.swift` |
| 2 | Retain cycle in closures | `Example02_RetainCycle.swift` |
| 3 | Array index out of bounds | `Example03_ArrayBounds.swift` |
| 4 | Main thread UI update | `Example04_MainThread.swift` |
| 5 | Value vs reference type bug | `Example05_ValueVsReference.swift` |
| 6 | Async/await ordering | `Example06_AsyncAwait.swift` |
| 7 | Wrong optional binding | `Example07_OptionalBinding.swift` |
| 8 | Weak vs strong in delegate | `Example08_DelegateRetainCycle.swift` |
| 9 | Incorrect type casting | `Example09_TypeCasting.swift` |
| 10 | Off-by-one & logic errors | `Example10_LogicError.swift` |

---

## 🚀 How to Use This Guide

1. **Read the BUG section** – Try to spot the issue yourself
2. **Understand the FIX** – See the correct approach
3. **Practice** – Fix similar problems in your own code

Good luck with your Apple interview! 🍎
