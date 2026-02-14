# Example 4: Value vs Reference Types

## The Bug
Structs are **value types** - copied on assignment. If you expect changes to propagate (like a class), you'll be surprised. Also: structs need `mutating` for methods that change properties.

## The Fix
- **Struct**: Use when you want independence, immutability, or copying
- **Class**: Use when you need shared mutable state or inheritance

## Interview Tip
"Why does Swift prefer structs?" - Value semantics avoid bugs, are thread-safe, and work great with SwiftUI. Know when to use each!
