# Swift Debugging Guide for Beginners
## Master Swift Debugging for Apple-Level Interviews

Welcome! This guide will teach you how to debug Swift code like a pro. Each example demonstrates a common bug you might encounter in Apple interviews, how to identify it, and how to fix it.

## 🎯 What You'll Learn

- How to identify and fix crashes
- Memory management and avoiding leaks
- Thread safety and concurrency
- Optional handling best practices
- Performance optimization
- Protocol-oriented programming pitfalls
- Modern Swift async/await patterns

## 📚 The 10 Examples

### 1. **Optional Unwrapping Crashes**
Learn how to safely unwrap optionals and avoid the dreaded "Fatal error: Unexpectedly found nil"

### 2. **Memory Leaks with Retain Cycles**
Understand strong reference cycles and how to break them with `weak` and `unowned`

### 3. **Array Index Out of Bounds**
Prevent crashes from accessing invalid array indices

### 4. **Thread Safety and Race Conditions**
Write thread-safe code using GCD and actors

### 5. **Protocol and Type Mismatches**
Master protocol conformance and type casting

### 6. **Async/Await and Concurrency Issues**
Handle modern Swift concurrency correctly

### 7. **Weak Self in Closures**
Avoid retain cycles in closures and understand capture lists

### 8. **Value vs Reference Type Confusion**
Understand when to use structs vs classes

### 9. **JSON Decoding Failures**
Handle Codable errors and debug decoding issues

### 10. **Performance Issues with Collections**
Optimize collection operations for better performance

## 🚀 How to Use This Guide

Each example folder contains:
- `Buggy.swift` - The broken code with the bug
- `Fixed.swift` - The corrected version
- `Explanation.md` - Detailed explanation of the bug and fix
- `DebuggingTips.md` - How to identify and debug similar issues

## 🛠 Debugging Tools You Should Know

1. **Xcode Debugger** - Set breakpoints, inspect variables
2. **LLDB Commands** - `po`, `p`, `v`, `bt` for stack traces
3. **Instruments** - Profile memory leaks, performance
4. **Print Debugging** - `print()`, `dump()`, `debugPrint()`
5. **Assertions** - `assert()`, `precondition()`, `fatalError()`

## 💡 General Debugging Tips

1. **Read the error message carefully** - Swift errors are descriptive
2. **Use breakpoints** - Don't just print everything
3. **Check the call stack** - Understand the flow of execution
4. **Isolate the problem** - Comment out code to narrow down the issue
5. **Use type inference carefully** - Explicit types can prevent bugs
6. **Enable strict concurrency checking** - Catch threading issues early
7. **Use sanitizers** - Address Sanitizer, Thread Sanitizer

## 📖 Apple Interview Tips

- Always consider edge cases (nil, empty arrays, etc.)
- Think about memory management
- Consider thread safety
- Write defensive code
- Use Swift's type system to prevent bugs
- Understand the difference between value and reference types
- Know when to use protocols vs inheritance
- Be familiar with modern Swift features (async/await, actors)

## 🎓 Next Steps

1. Go through each example in order
2. Try to identify the bug before looking at the fix
3. Run the code in Xcode to see the actual errors
4. Practice fixing similar bugs in your own projects
5. Review Apple's Swift documentation and WWDC videos

---

**Ready to start?** Begin with Example 1: Optional Unwrapping Crashes!
