// =============================================================================
// EXAMPLE 2: Array Index Out of Bounds
// Topic: Accessing an array element at an invalid index crashes the app
// Difficulty: Beginner
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

func getTopThreeScores(from scores: [Int]) -> [Int] {
    // BUG: Assumes the array always has at least 3 elements
    let first  = scores[0]
    let second = scores[1]
    let third  = scores[2]
    return [first, second, third]
}

let allScores = [95, 87]  // Only 2 elements!

// CRASH: Index out of range
let topThree = getTopThreeScores(from: allScores)
print(topThree)

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// The function tries to access scores[2], but the array only has 2 elements
// (indices 0 and 1). Accessing index 2 is out of bounds.
//
// Swift arrays do NOT return nil for invalid indices — they CRASH immediately:
//   "Fatal error: Index out of range"
//
// This is different from dictionaries, which return nil for missing keys.
//
// Common places this bug appears:
//   - Assuming user input or API data has a certain number of elements
//   - Off-by-one errors in loops (using <= instead of <)
//   - Deleting items from a list while iterating
//

// =============================================================================
// FIXED CODE - Multiple safe approaches
// =============================================================================

// --- Fix 1: Check the count before accessing ---
func getTopThreeScoresFix1(from scores: [Int]) -> [Int] {
    let sorted = scores.sorted(by: >)  // Sort descending
    var result: [Int] = []

    // Only access indices that exist
    for i in 0..<min(3, sorted.count) {
        result.append(sorted[i])
    }
    return result
}

// --- Fix 2: Use prefix() for safe slicing ---
// prefix(_:) never crashes — it returns up to N elements.
func getTopThreeScoresFix2(from scores: [Int]) -> [Int] {
    return Array(scores.sorted(by: >).prefix(3))
}

// --- Fix 3: Use a safe subscript extension ---
// This is a very popular interview technique!
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func getTopThreeScoresFix3(from scores: [Int]) -> [Int] {
    let sorted = scores.sorted(by: >)
    var result: [Int] = []

    for i in 0..<3 {
        if let score = sorted[safe: i] {
            result.append(score)
        }
    }
    return result
}

// --- Test all fixes ---
let testScores1 = [95, 87]          // Only 2 scores
let testScores2 = [95, 87, 72, 60]  // 4 scores
let testScores3: [Int] = []          // Empty array

print("=== Fix 1: Check count ===")
print(getTopThreeScoresFix1(from: testScores1))  // [95, 87]
print(getTopThreeScoresFix1(from: testScores2))  // [95, 87, 72]
print(getTopThreeScoresFix1(from: testScores3))  // []

print("\n=== Fix 2: prefix() ===")
print(getTopThreeScoresFix2(from: testScores1))  // [95, 87]
print(getTopThreeScoresFix2(from: testScores2))  // [95, 87, 72]
print(getTopThreeScoresFix2(from: testScores3))  // []

print("\n=== Fix 3: Safe subscript ===")
print(getTopThreeScoresFix3(from: testScores1))  // [95, 87]
print(getTopThreeScoresFix3(from: testScores2))  // [95, 87, 72]
print(getTopThreeScoresFix3(from: testScores3))  // []

// =============================================================================
// BONUS: Common off-by-one loop bug
// =============================================================================

/*
 BUGGY LOOP:
   for i in 0...arr.count {   // BUG: ... includes arr.count, which is out of bounds
       print(arr[i])
   }

 FIXED LOOP:
   for i in 0..<arr.count {   // FIX: ..< excludes arr.count
       print(arr[i])
   }

 EVEN BETTER:
   for element in arr {       // No index needed — can't go out of bounds
       print(element)
   }
*/

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Swift arrays crash on out-of-bounds access — they do NOT return nil.
//
// In interviews, Apple engineers look for:
//   1. Defensive programming: always check .count or .isEmpty first
//   2. Knowledge of safe methods: prefix(), suffix(), first, last
//   3. Understanding ..< (half-open range) vs ... (closed range)
//   4. Ability to write safe extensions (safe subscript)
//
// Quick Reference:
//   arr[5]           // CRASH if index 5 doesn't exist
//   arr.first        // SAFE - returns Optional (nil if empty)
//   arr.last         // SAFE - returns Optional (nil if empty)
//   arr.prefix(3)    // SAFE - returns up to 3 elements
//   arr[safe: 5]     // SAFE - custom extension returning Optional
// =============================================================================
