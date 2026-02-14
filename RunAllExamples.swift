#!/usr/bin/env swift
/*
 ═══════════════════════════════════════════════════════════════
 RUN ALL SWIFT DEBUGGING EXAMPLES
 ═══════════════════════════════════════════════════════════════
 
 This file runs all 10 debugging examples in sequence.
 
 To run:
 1. Make executable: chmod +x RunAllExamples.swift
 2. Run: ./RunAllExamples.swift
 
 Or simply: swift RunAllExamples.swift
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// Note: In a real project, you would import the example files.
// For this demonstration, copy the functions from each example file.

print("""
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   SWIFT DEBUGGING EXAMPLES - APPLE INTERVIEW PREPARATION      ║
║                                                               ║
║   10 Common Swift Bugs and How to Fix Them                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Welcome! This tutorial will show you 10 common Swift bugs you'll
encounter in Apple-level interviews, and how to debug and fix them.

Each example includes:
  ✓ Buggy code (what's wrong)
  ✓ Explanation of the bug
  ✓ Fixed code (multiple solutions)
  ✓ Key takeaways
  ✓ Interview tips

Let's get started!

""")

print("""
═══════════════════════════════════════════════════════════════

HOW TO USE THIS TUTORIAL:

1. READ each example file individually (Example01_*.swift)
2. TRY to identify the bug before reading the explanation
3. UNDERSTAND the fixed code and why it works
4. PRACTICE explaining the bug out loud
5. REVIEW the interview tips section

For interactive testing:
  - Open each example file in Xcode
  - Uncomment the test function at the bottom
  - Run and observe the output

For command-line testing:
  - swift Example01_ForceUnwrappingCrash.swift
  - swift Example02_RetainCycle.swift
  - etc.

═══════════════════════════════════════════════════════════════

""")

// Table of Contents
print("TABLE OF CONTENTS:")
print("─────────────────────────────────────────────────────────\n")

let examples = [
    (1, "Force Unwrapping Crash", "Beginner", "Optional handling"),
    (2, "Retain Cycle Memory Leak", "Intermediate", "Memory management"),
    (3, "Array Index Out of Bounds", "Beginner", "Safe collection access"),
    (4, "Mutating Struct Methods", "Intermediate", "Value vs reference types"),
    (5, "Protocol Conformance Error", "Intermediate", "Protocols & generics"),
    (6, "Race Condition", "Advanced", "Thread safety"),
    (7, "Weak vs Unowned References", "Intermediate", "Memory management"),
    (8, "Async/Await Deadlock", "Advanced", "Modern concurrency"),
    (9, "Dictionary Type Mismatch", "Beginner", "Type safety & casting"),
    (10, "Infinite Recursion", "Intermediate", "Recursion & algorithms")
]

for (num, name, difficulty, topic) in examples {
    let difficultyEmoji = difficulty == "Beginner" ? "🟢" : 
                          difficulty == "Intermediate" ? "🟡" : "🔴"
    print(String(format: "%2d. %-30s %@ %-13s | %@", 
                 num, name, difficultyEmoji, difficulty, topic))
}

print("\n═══════════════════════════════════════════════════════════════\n")

// Study recommendations
print("""
RECOMMENDED STUDY ORDER:

📚 For Beginners (Start here):
   → Example 1: Force Unwrapping
   → Example 3: Array Index Bounds
   → Example 9: Dictionary Type Mismatch
   Focus: Swift basics and safety

📚 For Intermediate (After basics):
   → Example 2: Retain Cycles
   → Example 4: Mutating Structs
   → Example 5: Protocols
   → Example 7: Weak vs Unowned
   → Example 10: Recursion
   Focus: Memory management and language features

📚 For Advanced (Final preparation):
   → Example 6: Race Conditions
   → Example 8: Async/Await
   Focus: Concurrency and performance

═══════════════════════════════════════════════════════════════

""")

// Interview prep timeline
print("""
📅 SUGGESTED STUDY TIMELINE:

Week 1: Foundations
  Day 1-2: Examples 1, 3, 9 (Beginner topics)
  Day 3-4: Practice problems with optionals and arrays
  Day 5-7: Review and write your own examples

Week 2: Memory Management
  Day 1-3: Examples 2, 7 (Retain cycles, weak/unowned)
  Day 4-5: Example 4 (Value types)
  Day 6-7: Practice and review

Week 3: Advanced Concepts
  Day 1-2: Example 5 (Protocols)
  Day 3-4: Example 10 (Recursion)
  Day 5-7: Practice combining concepts

Week 4: Concurrency & Mock Interviews
  Day 1-3: Examples 6, 8 (Threading, async/await)
  Day 4-5: Review all examples
  Day 6-7: Mock interviews

═══════════════════════════════════════════════════════════════

""")

// Quick tips
print("""
💡 QUICK INTERVIEW TIPS:

1. THINK ALOUD
   Explain your thought process as you debug

2. ASK QUESTIONS
   Clarify requirements and constraints

3. CONSIDER EDGE CASES
   What about nil? Empty arrays? Negative numbers?

4. EXPLAIN THE WHY
   Don't just fix it - explain why it was wrong

5. DISCUSS ALTERNATIVES
   Show you know multiple solutions

6. WRITE CLEAN CODE
   Follow Swift naming conventions

7. TEST YOUR SOLUTION
   Walk through test cases mentally

8. KNOW THE COMPLEXITY
   Discuss time and space complexity

═══════════════════════════════════════════════════════════════

""")

// Common mistakes to avoid
print("""
⚠️  COMMON INTERVIEW MISTAKES TO AVOID:

❌ Force unwrapping with ! without explanation
❌ Using as! instead of as?
❌ Creating retain cycles with closures
❌ Not checking array bounds
❌ Forgetting 'mutating' on struct methods
❌ Using strong references for delegates
❌ Blocking the main thread
❌ Not handling optionals safely
❌ Ignoring compiler warnings
❌ Not testing edge cases

═══════════════════════════════════════════════════════════════

""")

// Resources
print("""
📖 ADDITIONAL RESOURCES:

Official Documentation:
  • Swift Language Guide
    https://docs.swift.org/swift-book/

  • Apple Developer Documentation
    https://developer.apple.com/documentation/swift

  • Swift Evolution Proposals
    https://github.com/apple/swift-evolution

Recommended WWDC Sessions:
  • Protocol-Oriented Programming in Swift (2015)
  • Understanding Swift Performance (2016)
  • Modernizing Grand Central Dispatch Usage (2017)
  • Swift Generics (2018)
  • Data Essentials in SwiftUI (2020)
  • Meet async/await in Swift (2021)

Practice Platforms:
  • LeetCode (Swift problems)
  • HackerRank (Swift track)
  • Exercism (Swift track)

═══════════════════════════════════════════════════════════════

""")

print("""
🎯 YOU'RE READY TO START!

Open the example files one by one and work through them.
Each file is self-contained with complete explanations.

Good luck with your Swift interview preparation! 🍀

Remember: The goal isn't just to fix bugs—it's to understand
*why* they happened and *how* to prevent them.

═══════════════════════════════════════════════════════════════

""")

print("Press Enter to continue...")
_ = readLine()

print("\n\n🎓 Happy learning!\n")
