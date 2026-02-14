# Swift Interview Debugging Examples

A collection of **10 beginner-friendly Swift debugging exercises** designed to prepare you for Apple-level iOS/macOS developer interviews.

Each example contains:

- **Buggy Code** — the broken version you need to debug
- **What Goes Wrong** — a clear explanation of the bug
- **Fixed Code** — the corrected version with comments
- **Key Takeaway** — the interview concept being tested

---

## Examples at a Glance

| # | File | Topic | Difficulty |
|---|------|-------|------------|
| 1 | `Example01_OptionalUnwrapping.swift` | Force-unwrapping nil optionals | Beginner |
| 2 | `Example02_ArrayIndexOutOfBounds.swift` | Accessing invalid array indices | Beginner |
| 3 | `Example03_RetainCycle.swift` | Strong reference cycles & memory leaks | Intermediate |
| 4 | `Example04_ProtocolConformance.swift` | Missing protocol requirements | Intermediate |
| 5 | `Example05_ClosureCapture.swift` | Closure capture semantics | Intermediate |
| 6 | `Example06_ValueVsReference.swift` | Struct vs Class mutation behavior | Intermediate |
| 7 | `Example07_RaceCondition.swift` | Thread-safety & data races | Advanced |
| 8 | `Example08_EnumSwitch.swift` | Switch exhaustiveness & associated values | Beginner |
| 9 | `Example09_DelegatePattern.swift` | Weak delegates & retain cycles | Intermediate |
| 10 | `Example10_Generics.swift` | Generic constraints & type erasure | Advanced |

---

## How to Use These Examples

1. **Read the buggy code first** — try to spot the bug on your own before reading the explanation.
2. **Think about what happens at runtime** — will it crash? produce wrong output? leak memory?
3. **Read the explanation** — understand *why* it breaks.
4. **Study the fix** — understand the Swift concept behind the solution.
5. **Practice explaining it out loud** — interviewers love candidates who can articulate bugs clearly.

---

## How to Run

You can paste any example into:
- **Xcode Playground** (recommended for beginners)
- **Swift REPL** (`swift` in Terminal on macOS)
- **Online Swift compiler** (e.g., [SwiftFiddle](https://swiftfiddle.com))

---

## Core Swift Concepts Covered

- Optionals and safe unwrapping
- Collection safety
- ARC (Automatic Reference Counting) and memory management
- Protocols and protocol-oriented programming
- Closures and capture lists
- Value types vs reference types
- Concurrency and thread safety
- Enumerations and pattern matching
- Delegation pattern
- Generics and type constraints

These topics frequently appear in Apple iOS/macOS developer interviews.

---

## Tips for Apple Interviews

1. **Always explain your thought process** — Apple values how you think, not just the answer.
2. **Know ARC deeply** — memory management questions are almost guaranteed.
3. **Understand value vs reference semantics** — this is fundamental to Swift.
4. **Practice with Xcode Instruments** — know how to profile for leaks and performance.
5. **Be comfortable with protocols** — Swift is protocol-oriented, and Apple loves this.

Good luck with your preparation!
