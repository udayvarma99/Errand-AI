# Swift Interview Debugging Examples (Apple-Level)

Welcome! This guide contains **10 real-world Swift debugging examples** designed to help beginners prepare for Apple-level iOS/macOS interviews. Each example presents **buggy code**, explains **what's wrong**, shows **how to debug it**, and provides the **corrected code**.

---

## How to Use This Guide

1. **Read the buggy code first** — try to spot the bug yourself before reading the explanation.
2. **Understand WHY it's a bug** — the explanation teaches you the underlying Swift concept.
3. **Study the fix** — see the corrected code and understand the pattern.
4. **Practice** — try writing similar code and debugging it yourself.

---

## Table of Contents

| # | Topic | File | Difficulty |
|---|-------|------|------------|
| 1 | Optionals & Force Unwrapping | [Example01_Optionals.swift](Example01_Optionals.swift) | Beginner |
| 2 | Retain Cycles & Memory Leaks | [Example02_RetainCycles.swift](Example02_RetainCycles.swift) | Intermediate |
| 3 | Array Index Out of Bounds | [Example03_ArrayBounds.swift](Example03_ArrayBounds.swift) | Beginner |
| 4 | Value Types vs Reference Types | [Example04_ValueVsReference.swift](Example04_ValueVsReference.swift) | Intermediate |
| 5 | Protocol Conformance Issues | [Example05_Protocols.swift](Example05_Protocols.swift) | Intermediate |
| 6 | Closure Capture List Bugs | [Example06_Closures.swift](Example06_Closures.swift) | Intermediate |
| 7 | Concurrency & Race Conditions | [Example07_Concurrency.swift](Example07_Concurrency.swift) | Advanced |
| 8 | String & Character Handling | [Example08_Strings.swift](Example08_Strings.swift) | Beginner |
| 9 | Enum & Switch Statement Pitfalls | [Example09_Enums.swift](Example09_Enums.swift) | Beginner |
| 10 | Delegation Pattern Mistakes | [Example10_Delegation.swift](Example10_Delegation.swift) | Intermediate |

---

## Key Debugging Tips for Apple Interviews

1. **Read compiler errors carefully** — Swift's error messages are very descriptive.
2. **Use `print()` statements** — Quick way to inspect values at runtime.
3. **Use Xcode breakpoints** — Set breakpoints and step through code line by line.
4. **Use `po` in LLDB** — Type `po variableName` in the debugger console to print objects.
5. **Check for `nil`** — Most crashes in Swift come from force-unwrapping nil optionals.
6. **Use Instruments** — Profile your app for memory leaks, CPU usage, and more.
7. **Read the stack trace** — When your app crashes, the stack trace tells you exactly where.

---

## Prerequisites

- Basic understanding of Swift syntax
- Xcode installed (or any Swift playground environment)
- You can paste these examples into an Xcode Playground to test them

Happy debugging! 🍎
