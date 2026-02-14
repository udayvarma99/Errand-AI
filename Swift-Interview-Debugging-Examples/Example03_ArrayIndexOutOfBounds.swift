// =============================================================================
// EXAMPLE 3: Array Index Out of Bounds
// =============================================================================
// Difficulty: Beginner
// Topic:      Collections, Safe Indexing, Bounds Checking
//
// SCENARIO:
// You are building a simple to-do list app. The code tries to access items
// from an array using indices that may not exist. This causes a fatal runtime
// crash in Swift — arrays do NOT return nil for out-of-bounds access.
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

func displayTaskBuggy(tasks: [String], at index: Int) {
    // BUG: No bounds checking! If index >= tasks.count or index < 0,
    // this will crash with "Fatal error: Index out of range"
    let task = tasks[index]
    print("Task: \(task)")
}

func removeLastTwoTasksBuggy(tasks: inout [String]) {
    // BUG: What if the array has fewer than 2 elements?
    // Removing from an empty array crashes!
    tasks.removeLast()
    tasks.removeLast()
}

func demoBuggy() {
    let tasks = ["Buy milk", "Walk dog", "Read book"]

    displayTaskBuggy(tasks: tasks, at: 0)  // OK: "Buy milk"
    displayTaskBuggy(tasks: tasks, at: 2)  // OK: "Read book"
    // displayTaskBuggy(tasks: tasks, at: 5)  // CRASH: Index out of range!
    // displayTaskBuggy(tasks: tasks, at: -1) // CRASH: Index out of range!

    var shortList = ["Only one task"]
    // removeLastTwoTasksBuggy(tasks: &shortList)  // CRASH on second removeLast!
}

// demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// Unlike some languages (like Objective-C's NSArray), Swift arrays do NOT
// return nil when you access an out-of-bounds index. Instead, they CRASH.
//
// This is by design — Swift prefers safety over silent bugs. But it means
// YOU must check bounds before accessing array elements.
//
// Common places where this bug appears:
//   - Table view data sources (cellForRowAt indexPath)
//   - Parsing JSON arrays from APIs
//   - User-provided index values
//   - Off-by-one errors in loops
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Multiple safe approaches
// ─────────────────────────────────────────────────────────────────────────────

// FIX APPROACH 1: Check bounds manually before accessing
func displayTaskFixed(tasks: [String], at index: Int) {
    // Always check that the index is within valid range
    guard index >= 0 && index < tasks.count else {
        print("Error: Index \(index) is out of bounds (0..<\(tasks.count))")
        return
    }
    let task = tasks[index]
    print("Task: \(task)")
}

// FIX APPROACH 2: Use a safe subscript extension (very popular in interviews!)
extension Array {
    /// Returns the element at the given index, or nil if the index is out of bounds.
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func displayTaskWithSafeSubscript(tasks: [String], at index: Int) {
    // Now we get nil instead of a crash for invalid indices
    if let task = tasks[safe: index] {
        print("Task: \(task)")
    } else {
        print("No task at index \(index)")
    }
}

// FIX APPROACH 3: Safe removal with count checking
func removeLastTwoTasksFixed(tasks: inout [String]) {
    // Check how many we can actually remove
    let removeCount = min(2, tasks.count)
    for _ in 0..<removeCount {
        tasks.removeLast()
    }
    print("Removed \(removeCount) tasks. Remaining: \(tasks.count)")
}

func demoFixed() {
    let tasks = ["Buy milk", "Walk dog", "Read book"]

    print("--- Bounds Checking ---")
    displayTaskFixed(tasks: tasks, at: 0)   // "Task: Buy milk"
    displayTaskFixed(tasks: tasks, at: 2)   // "Task: Read book"
    displayTaskFixed(tasks: tasks, at: 5)   // "Error: Index 5 is out of bounds"
    displayTaskFixed(tasks: tasks, at: -1)  // "Error: Index -1 is out of bounds"

    print("\n--- Safe Subscript ---")
    displayTaskWithSafeSubscript(tasks: tasks, at: 0)   // "Task: Buy milk"
    displayTaskWithSafeSubscript(tasks: tasks, at: 99)  // "No task at index 99"

    print("\n--- Safe Removal ---")
    var shortList = ["Only one task"]
    removeLastTwoTasksFixed(tasks: &shortList)  // "Removed 1 tasks. Remaining: 0"

    print("\n--- Using .first and .last (always safe) ---")
    let emptyArray: [String] = []
    print("First of empty: \(emptyArray.first ?? "nil")")  // "nil"
    print("Last of empty: \(emptyArray.last ?? "nil")")     // "nil"
    print("First of tasks: \(tasks.first ?? "nil")")        // "Buy milk"
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Swift arrays CRASH on out-of-bounds access — they don't return nil.
//
// 2. Always validate indices before accessing: guard index < array.count
//
// 3. The "safe subscript" extension (array[safe: index]) is a very common
//    interview answer. Memorize it!
//
// 4. Use .first and .last properties — they safely return nil for empty arrays.
//
// 5. When removing elements, always check .count or .isEmpty first.
//
// 6. Use enumerated() in loops to safely iterate with indices:
//    for (index, element) in array.enumerated() { ... }
//
// 7. Prefer higher-order functions (map, filter, etc.) over manual indexing
//    to avoid off-by-one errors entirely.
// ─────────────────────────────────────────────────────────────────────────────
