# Swift Debugging Examples for Apple Interview Prep

A collection of **10 hands-on Swift debugging examples** designed for beginners preparing for Apple-level iOS/Swift interviews. Each example follows a consistent format:

1. **Buggy Code** — A realistic code snippet with a hidden bug
2. **Explanation** — A clear breakdown of what the bug is and why it happens
3. **Fixed Code** — The corrected version with multiple approaches where applicable
4. **Tests** — Verification that the fix works
5. **Apple Interview Question** — A related question you might get asked in an interview

---

## Examples Overview

| # | File | Topic | Difficulty | Key Concept |
|---|------|-------|------------|-------------|
| 1 | `Example01_OptionalUnwrapping.swift` | Optional Unwrapping | Beginner | Force unwrap nil crash, if-let, guard-let, nil-coalescing |
| 2 | `Example02_ArrayIndexOutOfBounds.swift` | Array Safety | Beginner | Index out of range, safe subscript extension, prefix |
| 3 | `Example03_StrongReferenceCycle.swift` | Memory Management | Intermediate | ARC, retain cycles, weak vs unowned |
| 4 | `Example04_ValueVsReferenceTypes.swift` | Value vs Reference | Beginner-Intermediate | Struct vs Class, mutating keyword, copy semantics |
| 5 | `Example05_ClosureCaptureRetainCycle.swift` | Closures & Memory | Intermediate | [weak self], capture lists, retain cycles in closures |
| 6 | `Example06_ProtocolConformance.swift` | Protocols | Beginner-Intermediate | Delegate pattern, protocol extensions, AnyObject |
| 7 | `Example07_EnumSwitchExhaustiveness.swift` | Enums & Switch | Beginner-Intermediate | Exhaustive switch, associated values, raw values |
| 8 | `Example08_ConcurrencyRaceCondition.swift` | Concurrency | Intermediate-Advanced | Race conditions, GCD, serial queues, actors |
| 9 | `Example09_EquatableHashable.swift` | Equality & Hashing | Intermediate | Hashable contract, Set/Dictionary bugs, custom equality |
| 10 | `Example10_GuardVsIfLet.swift` | Guard vs If-Let | Beginner | Pyramid of doom, early exit, multiple optional binding |

---

## How to Study These Examples

### Step 1: Read the Buggy Code First
Each file starts with a commented-out `BUGGY CODE` section. Try to spot the bug yourself before reading the explanation. This trains your "bug radar."

### Step 2: Understand WHY It's a Bug
The `WHY IS THIS A BUG?` section explains the root cause. Don't just memorize the fix — understand the underlying Swift behavior that causes the issue.

### Step 3: Study the Fixed Code
Each example provides one or more fix approaches. Understand the trade-offs between them.

### Step 4: Run the Tests
Copy the fixed code into a Swift Playground (Xcode) or use an online Swift compiler to see the output.

### Step 5: Practice the Interview Question
Each file ends with a realistic Apple interview question. Practice answering it out loud as if you're in an interview.

---

## Study Order (Recommended for Beginners)

If you're new to Swift, study the examples in this order:

1. **Example 01** — Optionals (most fundamental Swift concept)
2. **Example 10** — Guard vs If-Let (builds on optionals)
3. **Example 02** — Array Safety (common crash)
4. **Example 04** — Value vs Reference Types (struct vs class)
5. **Example 07** — Enums & Switch (very "Swifty" topic)
6. **Example 06** — Protocols (backbone of Swift design)
7. **Example 03** — Strong Reference Cycles (memory management)
8. **Example 05** — Closure Capture (most common memory leak)
9. **Example 09** — Equatable/Hashable (subtle but important)
10. **Example 08** — Concurrency (advanced but essential)

---

## Top Apple Interview Topics Covered

These examples cover the topics most frequently asked in Apple iOS/Swift interviews:

- **Memory Management (ARC)** — Examples 3, 5
- **Optionals & Safety** — Examples 1, 2, 10
- **Value Types vs Reference Types** — Example 4
- **Protocol-Oriented Programming** — Example 6
- **Closures** — Example 5
- **Enumerations** — Example 7
- **Concurrency** — Example 8
- **Swift Standard Library** — Example 9
- **Code Readability** — Example 10

---

## Quick Reference: Swift Safety Checklist

Before submitting code in an interview (or in production), check:

- [ ] No force-unwrapping (`!`) unless absolutely justified
- [ ] All array accesses are bounds-checked
- [ ] Delegates are `weak` to avoid retain cycles
- [ ] Closures use `[weak self]` when capturing self in stored closures
- [ ] Switch statements handle all enum cases (avoid `default` on your own enums)
- [ ] Hashable contract is maintained (equal objects have equal hashes)
- [ ] UI updates happen on the main thread
- [ ] Shared mutable state is protected from race conditions
- [ ] Functions use `guard` for validation/early exit (not nested if-let)
- [ ] Structs are preferred over classes unless you need reference semantics

---

## Running the Examples

### Option 1: Xcode Playground (Recommended)
1. Open Xcode
2. File > New > Playground
3. Copy-paste any example file's code into the playground
4. Press the Play button to run

### Option 2: Swift REPL (Command Line)
```bash
swift ExampleXX_Name.swift
```

### Option 3: Online Compilers
- [SwiftFiddle](https://swiftfiddle.com)
- [Online Swift Playground](https://online.swiftplayground.run)

---

## License

These examples are free to use for learning and interview preparation. Good luck with your Apple interview!
