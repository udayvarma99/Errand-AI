// ============================================================================
// EXAMPLE 3: Array Index Out of Bounds
// Difficulty: Beginner
// Topic: Safe array access, common collection pitfalls
// ============================================================================

// ============================================================================
// WHAT IS AN ARRAY INDEX OUT OF BOUNDS ERROR?
// ============================================================================
// Arrays in Swift are zero-indexed, meaning the first element is at index 0.
// If you try to access an index that doesn't exist, your app CRASHES.
//
//   let fruits = ["Apple", "Banana", "Cherry"]
//   fruits[0]  // "Apple"   (valid)
//   fruits[2]  // "Cherry"  (valid)
//   fruits[3]  // 💥 CRASH! (only indices 0, 1, 2 exist)
//
// Swift does NOT return nil for invalid indices — it crashes immediately.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Accessing an index that doesn't exist
let colors = ["Red", "Green", "Blue"]
print(colors[3])  // 💥 CRASH: Index 3 is out of range (valid: 0-2)


// Bug 2: Off-by-one error in a loop
let numbers = [10, 20, 30, 40, 50]
for i in 0...numbers.count {  // Bug: should be ..< not ...
    print(numbers[i])  // 💥 CRASH when i == 5 (count is 5, max index is 4)
}


// Bug 3: Removing elements while iterating
var names = ["Alice", "Bob", "Charlie", "Diana"]
for i in 0..<names.count {
    if names[i] == "Bob" {
        names.remove(at: i)  // Array shrinks, but loop still uses old count!
    }
    // 💥 CRASH: After removal, index 3 no longer exists
}


// Bug 4: Using first/last unsafely
let emptyArray: [String] = []
let firstItem: String = emptyArray.first!  // 💥 CRASH: Force unwrapping nil!
print(firstItem)


// Bug 5: Assuming array has enough elements
func getTopThree(scores: [Int]) -> [Int] {
    return [scores[0], scores[1], scores[2]]  // 💥 CRASH if < 3 elements!
}
let result = getTopThree(scores: [100, 95])  // Only 2 elements!

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Array has 3 elements (indices 0, 1, 2). Index 3 doesn't exist.
//
// Bug 2: The `...` operator includes the end value. So `0...5` includes 5,
//         but the last valid index is 4. Use `..<` (half-open range) instead.
//
// Bug 3: When you remove an element, the array shrinks. The loop counter
//         still goes to the original count, causing an out-of-bounds crash.
//
// Bug 4: `.first` on an empty array returns nil (it's an Optional).
//         Force unwrapping nil with `!` crashes.
//
// Bug 5: The function assumes the array always has 3+ elements, but the
//         caller passed an array with only 2 elements.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Check the index before accessing
let colors = ["Red", "Green", "Blue"]
let index = 3

if index < colors.count {
    print(colors[index])
} else {
    print("Index \(index) is out of range. Array has \(colors.count) items.")
}

// Even better — create a safe subscript extension:
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

print(colors[safe: 3] ?? "No color at that index")  // Safe!
print(colors[safe: 1] ?? "No color at that index")  // "Green"


// Fix 2: Use ..< (half-open range) instead of ... (closed range)
let numbers = [10, 20, 30, 40, 50]

// Correct way 1: Half-open range
for i in 0..<numbers.count {
    print("Index \(i): \(numbers[i])")
}

// Even better: Use for-in directly (no index needed)
for number in numbers {
    print(number)
}

// If you need the index AND the value, use enumerated()
for (index, number) in numbers.enumerated() {
    print("Index \(index): \(number)")
}


// Fix 3: Use filter() or reversed iteration when removing elements
var names = ["Alice", "Bob", "Charlie", "Diana"]

// Approach 1: Use filter (creates a new array — preferred!)
names = names.filter { $0 != "Bob" }
print(names)  // ["Alice", "Charlie", "Diana"]

// Approach 2: If you must modify in place, iterate in reverse
var names2 = ["Alice", "Bob", "Charlie", "Bob", "Diana"]
for i in stride(from: names2.count - 1, through: 0, by: -1) {
    if names2[i] == "Bob" {
        names2.remove(at: i)  // Safe because we go backwards
    }
}
print(names2)  // ["Alice", "Charlie", "Diana"]

// Approach 3: Use removeAll(where:) — the most Swifty way!
var names3 = ["Alice", "Bob", "Charlie", "Bob", "Diana"]
names3.removeAll { $0 == "Bob" }
print(names3)  // ["Alice", "Charlie", "Diana"]


// Fix 4: Safely unwrap first/last
let emptyArray: [String] = []

if let firstItem = emptyArray.first {
    print("First item: \(firstItem)")
} else {
    print("Array is empty!")
}

// Or use nil-coalescing
let firstItem = emptyArray.first ?? "Default"
print(firstItem)  // "Default"


// Fix 5: Validate array size before accessing specific indices
func getTopThree(scores: [Int]) -> [Int] {
    // Sort descending and take up to 3
    let sorted = scores.sorted(by: >)
    return Array(sorted.prefix(3))  // prefix() is safe — never crashes!
}

let result1 = getTopThree(scores: [100, 95])
print("Top scores: \(result1)")  // [100, 95] — returns what's available

let result2 = getTopThree(scores: [100, 95, 88, 72, 60])
print("Top scores: \(result2)")  // [100, 95, 88]


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. NEVER access array indices without checking bounds first.
//
// 2. Use `.first` and `.last` (which return Optionals) instead of `[0]`
//    and `[array.count - 1]`.
//
// 3. Prefer `for item in array` over `for i in 0..<array.count`.
//
// 4. Use `prefix()`, `suffix()`, and `dropFirst()` for safe slicing.
//
// 5. Use `filter()` or `removeAll(where:)` instead of manual removal loops.
//
// 6. The safe subscript extension is a great tool to mention in interviews.
//
// Common interview question: "How would you safely access an array element?"
// Answer: Check `indices.contains(index)`, use optional-returning safe
//         subscripts, or use methods like `.first`, `.last`, `.prefix()`.
// ============================================================================
