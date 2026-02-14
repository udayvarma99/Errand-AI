# Swift Debugging Examples - Apple Interview Preparation

Welcome to this comprehensive guide on debugging Swift code! This repository contains 10 real-world examples of common bugs you might encounter in Swift development, especially useful for Apple-level interviews.

## 🎯 Learning Objectives

By working through these examples, you'll learn:
- How to identify common Swift bugs
- Debugging techniques and best practices
- Memory management and retain cycles
- Thread safety and concurrency
- Optional handling and type safety
- Protocol-oriented programming pitfalls

## 📚 How to Use This Guide

Each example follows this structure:
1. **Buggy Code** - The code with issues
2. **Problem Description** - What's wrong and why
3. **Debugging Steps** - How to identify the issue
4. **Fixed Code** - The corrected version
5. **Key Takeaways** - Important lessons

## 🐛 The 10 Debugging Examples

### Example 1: Optional Unwrapping
**File**: `Example01_OptionalUnwrapping.swift`
**Topic**: Force unwrapping vs safe unwrapping
**Difficulty**: Beginner

### Example 2: Array Index Out of Bounds
**File**: `Example02_ArrayIndexOutOfBounds.swift`
**Topic**: Safe array access patterns
**Difficulty**: Beginner

### Example 3: Memory Leaks with Retain Cycles
**File**: `Example03_RetainCycles.swift`
**Topic**: Strong reference cycles and memory management
**Difficulty**: Intermediate

### Example 4: Thread Safety Issues
**File**: `Example04_ThreadSafety.swift`
**Topic**: Race conditions and synchronization
**Difficulty**: Intermediate

### Example 5: Value vs Reference Types
**File**: `Example05_ValueVsReference.swift`
**Topic**: Struct vs Class behavior
**Difficulty**: Intermediate

### Example 6: Protocol Conformance
**File**: `Example06_ProtocolConformance.swift`
**Topic**: Protocol requirements and extensions
**Difficulty**: Intermediate

### Example 7: Closures and Capture Lists
**File**: `Example07_ClosureCaptures.swift`
**Topic**: Capture semantics and weak/unowned
**Difficulty**: Intermediate

### Example 8: Type Casting
**File**: `Example08_TypeCasting.swift`
**Topic**: Safe downcasting and type checking
**Difficulty**: Beginner

### Example 9: Dictionary Type Mismatches
**File**: `Example09_DictionaryTypes.swift`
**Topic**: Working with dictionary optionals
**Difficulty**: Beginner

### Example 10: Async/Await Concurrency
**File**: `Example10_AsyncAwait.swift`
**Topic**: Modern Swift concurrency patterns
**Difficulty**: Advanced

## 🔧 Debugging Tools & Techniques

### 1. **LLDB Debugger**
- Set breakpoints with `breakpoint set`
- Inspect variables with `po` (print object)
- Step through code with `step`, `next`, `continue`

### 2. **Print Debugging**
```swift
print("Value: \(variable)")
debugPrint(complexObject)
dump(structInstance)
```

### 3. **Assertions**
```swift
assert(array.count > 0, "Array should not be empty")
precondition(index >= 0, "Index must be positive")
```

### 4. **Memory Graph Debugger**
- Detect retain cycles in Xcode
- View object relationships
- Find leaked objects

### 5. **Instruments**
- Leaks instrument for memory issues
- Time Profiler for performance
- Allocations for memory usage

## 💡 Common Swift Interview Topics

1. **Optionals** - nil handling, unwrapping techniques
2. **Memory Management** - ARC, retain cycles, weak/unowned
3. **Value vs Reference** - Struct vs Class, copy semantics
4. **Protocols** - POP, protocol extensions, associated types
5. **Closures** - Capture lists, escaping vs non-escaping
6. **Concurrency** - GCD, async/await, actors
7. **Error Handling** - try/catch, throwing functions
8. **Generics** - Type constraints, associated types
9. **Collections** - Arrays, Sets, Dictionaries, subscripts
10. **Type System** - Type inference, type casting, Any/AnyObject

## 🚀 Getting Started

1. Clone this repository
2. Start with Example 1 if you're a beginner
3. Read the buggy code and try to spot the issue yourself
4. Check the debugging steps and solution
5. Compile and run the fixed code
6. Move to the next example

## 📖 Additional Resources

- [Swift Programming Language Guide](https://docs.swift.org/swift-book/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Swift Evolution Proposals](https://github.com/apple/swift-evolution)
- [Ray Wenderlich Swift Tutorials](https://www.raywenderlich.com/ios/paths/learn)

## 🎓 Interview Preparation Tips

1. **Understand the fundamentals** - Master optionals, memory management, and protocols
2. **Practice debugging** - Don't just read code, actually debug it
3. **Know the tools** - Be familiar with Xcode, LLDB, and Instruments
4. **Write clean code** - Follow Swift naming conventions and best practices
5. **Think aloud** - In interviews, explain your debugging process
6. **Test edge cases** - Always consider nil, empty collections, and boundary conditions

## 📝 Running the Examples

Each example can be run independently in:
- **Xcode Playground** - Copy the code into a new playground
- **Command Line** - Save as .swift file and run with `swift filename.swift`
- **Xcode Project** - Add files to a new iOS/macOS project

## ⚠️ Common Mistakes to Avoid

1. Force unwrapping optionals with `!`
2. Not using capture lists in closures
3. Ignoring thread safety in multi-threaded code
4. Assuming structs are always better than classes
5. Not handling errors properly
6. Inefficient array operations
7. Memory leaks from retain cycles
8. Not using `defer` for cleanup
9. Misunderstanding value semantics
10. Blocking the main thread

---

**Happy Debugging! 🐛➡️✨**

*This guide is designed for educational purposes to help developers prepare for Apple interviews and improve their Swift debugging skills.*
