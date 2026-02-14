# Swift Interview Debugging Examples

## 10 Hands-On Bug-Fixing Exercises for Apple-Level Interviews

Welcome! This repository contains **10 real-world Swift debugging examples** designed to help beginners prepare for Apple-level iOS/macOS developer interviews. Each example presents **buggy code** alongside the **fixed version** with detailed explanations.

---

## How to Use This Guide

1. **Read the buggy code first** — try to spot the bug yourself before looking at the fix.
2. **Understand the explanation** — each example explains *why* the bug happens and *how* to fix it.
3. **Practice in Xcode** — copy the code into a Swift Playground or Xcode project and run it.
4. **Repeat** — the more you practice, the faster you will spot bugs in interviews.

---

## Table of Contents

| # | File | Topic | Difficulty |
|---|------|-------|------------|
| 1 | [Example01_ForceUnwrappingNil.swift](Example01_ForceUnwrappingNil.swift) | Force Unwrapping a Nil Optional | Beginner |
| 2 | [Example02_RetainCycle.swift](Example02_RetainCycle.swift) | Retain Cycle / Memory Leak in Closures | Beginner-Intermediate |
| 3 | [Example03_ArrayIndexOutOfBounds.swift](Example03_ArrayIndexOutOfBounds.swift) | Array Index Out of Bounds | Beginner |
| 4 | [Example04_ValueVsReferenceType.swift](Example04_ValueVsReferenceType.swift) | Value Type vs Reference Type Mutation | Intermediate |
| 5 | [Example05_ProtocolConformance.swift](Example05_ProtocolConformance.swift) | Protocol Conformance Issue | Intermediate |
| 6 | [Example06_ClosureCaptureInLoops.swift](Example06_ClosureCaptureInLoops.swift) | Closure Capture Semantics in Loops | Intermediate |
| 7 | [Example07_EquatableHashable.swift](Example07_EquatableHashable.swift) | Equatable/Hashable for Custom Types | Intermediate |
| 8 | [Example08_ThreadSafety.swift](Example08_ThreadSafety.swift) | Thread Safety / Race Condition | Advanced |
| 9 | [Example09_DelegatePattern.swift](Example09_DelegatePattern.swift) | Delegate Pattern Bug (Weak Reference) | Intermediate |
| 10 | [Example10_StringHandling.swift](Example10_StringHandling.swift) | String and Substring Handling | Intermediate |

---

## Key Swift Concepts Covered

- **Optionals** — safe unwrapping, nil coalescing, optional binding
- **Memory Management** — ARC, retain cycles, weak/unowned references
- **Collections** — safe indexing, bounds checking
- **Value vs Reference Types** — structs vs classes, copy-on-write
- **Protocols** — conformance, default implementations, associated types
- **Closures** — capture lists, escaping, value/reference capture
- **Hashable/Equatable** — custom implementations, Set/Dictionary behavior
- **Concurrency** — GCD, thread safety, serial queues
- **Delegation** — protocol-based communication, weak delegates
- **Strings** — Unicode, indexing, substrings

---

## Tips for Apple Interviews

1. **Always handle optionals safely** — never force-unwrap unless you are 100% certain.
2. **Think about memory** — who owns what? Are there cycles?
3. **Know value vs reference semantics** — structs copy, classes share.
4. **Understand closures deeply** — capture lists, escaping, and retain cycles.
5. **Thread safety matters** — Apple apps are multi-threaded; know GCD basics.
6. **Test edge cases** — empty arrays, nil values, Unicode strings.
7. **Read compiler errors carefully** — Swift's compiler is very helpful.
8. **Explain your thinking** — interviewers want to see your debugging process.

---

## Requirements

- **Swift 5.0+**
- **Xcode 14+** (or any Swift Playground)
- Each file is self-contained — just copy into a Playground and run!

Happy debugging! Good luck with your interview preparation!
