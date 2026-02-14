# Swift Debugging Examples - Apple Interview Preparation

Welcome! This repository contains **10 comprehensive debugging examples** designed to help beginners master Swift debugging for Apple-level interviews.

## 🎯 What You'll Learn

- How to identify and fix common Swift bugs
- Essential debugging techniques and tools
- Best practices for writing safe Swift code
- Interview-level problem-solving approaches

## 📚 Table of Contents

### Example 1: Optional Unwrapping Crashes
**File:** `Example1_OptionalUnwrapping.swift`  
**Concepts:** Force unwrapping, nil coalescing, optional binding, guard statements

### Example 2: Array Index Out of Bounds
**File:** `Example2_ArrayIndexCrash.swift`  
**Concepts:** Safe array access, bounds checking, array validation

### Example 3: Memory Leaks (Retain Cycles)
**File:** `Example3_RetainCycle.swift`  
**Concepts:** Strong references, weak/unowned, closure capture lists

### Example 4: Race Conditions & Concurrency
**File:** `Example4_RaceCondition.swift`  
**Concepts:** Thread safety, DispatchQueue, actors, @MainActor

### Example 5: Type Casting Issues
**File:** `Example5_TypeCasting.swift`  
**Concepts:** as?, as!, type checking, safe downcasting

### Example 6: Infinite Loops
**File:** `Example6_InfiniteLoop.swift`  
**Concepts:** Loop conditions, break statements, algorithm debugging

### Example 7: Dictionary Access Crashes
**File:** `Example7_DictionaryAccess.swift`  
**Concepts:** Safe dictionary access, default values, optional chaining

### Example 8: String Manipulation Bugs
**File:** `Example8_StringManipulation.swift`  
**Concepts:** String indexing, character iteration, Unicode handling

### Example 9: Protocol Conformance Issues
**File:** `Example9_ProtocolConformance.swift`  
**Concepts:** Protocol requirements, associated types, extensions

### Example 10: Closure Capture Problems
**File:** `Example10_ClosureCapture.swift`  
**Concepts:** Capture lists, reference vs value types, escaping closures

## 🛠️ Debugging Tools & Techniques

### 1. **Xcode Debugger (LLDB)**
- Set breakpoints
- Step through code (Step Over, Step Into, Step Out)
- Inspect variables in the Debug Area
- Use `po` (print object) command

### 2. **Print Debugging**
```swift
print("Debug: variable value = \(value)")
debugPrint("Detailed output")
```

### 3. **Assertions**
```swift
assert(array.count > 0, "Array should not be empty")
precondition(index >= 0, "Index must be non-negative")
```

### 4. **Memory Debugging**
- Memory Graph Debugger in Xcode
- Instruments (Leaks, Allocations)
- Enable zombie objects

### 5. **Static Analysis**
- Compiler warnings (don't ignore them!)
- SwiftLint for code quality
- Enable strict concurrency checking

## 📖 How to Use This Repository

1. **Read each example file** - Start with Example 1 and work your way through
2. **Identify the bug** - Try to spot the issue before reading the explanation
3. **Understand the fix** - Study why the bug occurs and how to prevent it
4. **Practice debugging** - Run the code in a Swift Playground or Xcode project
5. **Apply the techniques** - Use these patterns in your own code

## 💡 Interview Tips

1. **Always handle optionals safely** - Avoid force unwrapping in production code
2. **Think about edge cases** - Empty arrays, nil values, boundary conditions
3. **Consider memory management** - Especially with closures and delegates
4. **Be thread-aware** - Know when you're dealing with concurrent code
5. **Read compiler errors carefully** - They often tell you exactly what's wrong
6. **Use guard statements** - For early returns and cleaner code
7. **Write defensive code** - Validate inputs and handle errors gracefully
8. **Test thoroughly** - Edge cases are where bugs hide
9. **Explain your thought process** - In interviews, talking through debugging is key
10. **Know your tools** - Familiarity with Xcode debugger is essential

## 🚀 Next Steps

After mastering these examples:
- Practice on LeetCode and HackerRank
- Build small projects applying these debugging techniques
- Read Apple's Swift Programming Guide
- Study iOS frameworks (UIKit, SwiftUI)
- Learn about app architecture patterns (MVVM, MVI, Clean Architecture)

## 📝 Additional Resources

- [Swift.org Documentation](https://swift.org/documentation/)
- [Apple's Swift Book](https://docs.swift.org/swift-book/)
- [WWDC Sessions on Debugging](https://developer.apple.com/videos/)
- [Ray Wenderlich Tutorials](https://www.raywenderlich.com/)

---

**Good luck with your Apple interview preparation! 🍎**

Remember: The best debuggers aren't those who never create bugs, but those who can quickly identify and fix them!
