# Swift Debugging & Interview Preparation Guide

Welcome to your Swift debugging journey! This repository contains 10 carefully crafted debugging examples to help you master common Swift issues you'll encounter in Apple-level interviews.

## 🎯 What You'll Learn

- How to identify and fix common Swift bugs
- Memory management and retain cycles
- Optional handling best practices
- Protocol and generic issues
- Concurrency and async/await debugging
- Collection manipulation errors
- Type safety issues
- Performance optimization

## 📚 Examples Overview

Each example includes:
- **Buggy Code**: The problematic version
- **What's Wrong**: Detailed explanation of the bug
- **Fixed Code**: The corrected version
- **Key Takeaways**: Important concepts to remember
- **Interview Tips**: What interviewers look for

### Example 1: Force Unwrapping Crash
**File**: `Example01_ForceUnwrappingCrash.swift`  
**Topic**: Optional handling and nil safety  
**Difficulty**: Beginner

### Example 2: Retain Cycle Memory Leak
**File**: `Example02_RetainCycle.swift`  
**Topic**: Memory management with closures  
**Difficulty**: Intermediate

### Example 3: Array Index Out of Bounds
**File**: `Example03_ArrayIndexCrash.swift`  
**Topic**: Safe collection access  
**Difficulty**: Beginner

### Example 4: Mutating Struct Methods
**File**: `Example04_MutatingStruct.swift`  
**Topic**: Value types vs reference types  
**Difficulty**: Intermediate

### Example 5: Protocol Conformance Error
**File**: `Example05_ProtocolConformance.swift`  
**Topic**: Protocols and associated types  
**Difficulty**: Intermediate

### Example 6: Race Condition
**File**: `Example06_RaceCondition.swift`  
**Topic**: Thread safety and actors  
**Difficulty**: Advanced

### Example 7: Weak vs Unowned References
**File**: `Example07_WeakVsUnowned.swift`  
**Topic**: Reference types and memory management  
**Difficulty**: Intermediate

### Example 8: Async/Await Deadlock
**File**: `Example08_AsyncDeadlock.swift`  
**Topic**: Modern concurrency  
**Difficulty**: Advanced

### Example 9: Dictionary Type Mismatch
**File**: `Example09_DictionaryTypeMismatch.swift`  
**Topic**: Type safety and casting  
**Difficulty**: Beginner

### Example 10: Infinite Recursion
**File**: `Example10_InfiniteRecursion.swift`  
**Topic**: Stack overflow and algorithm design  
**Difficulty**: Intermediate

## 🚀 How to Use This Guide

### For Beginners:
1. Start with Examples 1, 3, and 9 (Beginner level)
2. Read the buggy code first and try to spot the issue
3. Read the explanation to understand the problem
4. Study the fixed code and key takeaways
5. Try to write your own version from scratch

### For Interview Preparation:
1. Set a timer for 5-10 minutes per example
2. Try to identify and explain the bug verbally (practice for interviews)
3. Write the fix without looking at the solution
4. Compare your solution with the provided fix
5. Practice explaining the concepts out loud

### Testing the Code:
Each example can be run individually. To test:
```bash
# Run a specific example
swift Example01_ForceUnwrappingCrash.swift

# Or use Swift REPL
swift
# Then copy-paste the code
```

## 💡 Interview Tips

### What Apple Interviewers Look For:

1. **Problem Identification**: Can you quickly spot the bug?
2. **Explanation Skills**: Can you articulate what's wrong?
3. **Best Practices**: Do you know the Swift-idiomatic solution?
4. **Edge Cases**: Do you consider all scenarios?
5. **Performance**: Do you think about optimization?

### During the Interview:

- **Think Aloud**: Explain your debugging process
- **Ask Questions**: Clarify requirements and constraints
- **Consider Edge Cases**: What happens with nil, empty arrays, etc.?
- **Write Clean Code**: Follow Swift naming conventions
- **Test Your Solution**: Walk through test cases mentally

## 📖 Additional Resources

- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [Apple's Swift Best Practices](https://developer.apple.com/documentation/swift)
- [Swift Evolution Proposals](https://github.com/apple/swift-evolution)

## 🎓 Study Plan

### Week 1: Fundamentals
- Examples 1, 3, 9 (Optionals, Arrays, Types)
- Focus on understanding Swift's type system

### Week 2: Memory Management
- Examples 2, 7 (Retain cycles, weak/unowned)
- Study ARC (Automatic Reference Counting)

### Week 3: Advanced Topics
- Examples 4, 5 (Structs, Protocols)
- Understand value vs reference semantics

### Week 4: Concurrency
- Examples 6, 8 (Race conditions, async/await)
- Master modern Swift concurrency

### Week 5: Integration & Practice
- Example 10 (Recursion)
- Review all examples
- Practice explaining solutions

## 🤝 Contributing

Feel free to add more examples or improve existing ones!

## ⚠️ Common Interview Mistakes to Avoid

1. Force unwrapping without checking for nil
2. Creating retain cycles with closures
3. Not using `guard` statements for early returns
4. Forgetting `mutating` keyword on struct methods
5. Improper error handling
6. Not considering thread safety
7. Using force casting (`as!`) instead of conditional casting (`as?`)
8. Ignoring compiler warnings

---

**Good luck with your Swift interviews!** 🍀

Remember: The goal isn't just to fix bugs—it's to understand *why* they happened and *how* to prevent them.
