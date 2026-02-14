// =============================================================================
// EXAMPLE 2: Array Index Out of Bounds
// =============================================================================
//
// DIFFICULTY: Beginner
// TOPIC: Arrays, Safe Indexing, Collection Safety
// APPLE INTERVIEW TIP: Array out-of-bounds crashes are extremely common in iOS
//   apps. Showing you understand safe access patterns demonstrates maturity.
//
// WHAT YOU WILL LEARN:
//   - Why accessing an invalid array index crashes your app
//   - How to safely access array elements
//   - How to write a safe subscript extension
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

func getTopThreeScores(from scores: [Int]) -> [Int] {
    // BUG: Assumes the array always has at least 3 elements
    let first  = scores[0]
    let second = scores[1]
    let third  = scores[2]
    return [first, second, third]
}

// This works:
let manyScores = [95, 87, 92, 78, 88]
print(getTopThreeScores(from: manyScores))  // [95, 87, 92]

// This CRASHES! 💥
let fewScores = [95]
print(getTopThreeScores(from: fewScores))  // Fatal error: Index out of range

// This also CRASHES! 💥
let noScores: [Int] = []
print(getTopThreeScores(from: noScores))  // Fatal error: Index out of range

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// In Swift, accessing an array element at an index that doesn't exist causes
// an immediate runtime crash:
//
//   "Fatal error: Index out of range"
//
// Unlike some languages that return nil or a default, Swift arrays crash on
// invalid indices. This is by design for safety — but you must handle it.
//
// Common scenarios where this happens:
//   - API returns fewer items than expected
//   - User deletes items while a background task is accessing the array
//   - Off-by-one errors in loops
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE — Multiple safe approaches
// ---------------------------------------------------------------------------

// APPROACH 1: Check count before accessing
func getTopThreeScoresV1(from scores: [Int]) -> [Int] {
    var result: [Int] = []
    
    if scores.count > 0 { result.append(scores[0]) }
    if scores.count > 1 { result.append(scores[1]) }
    if scores.count > 2 { result.append(scores[2]) }
    
    return result
}

// APPROACH 2: Use prefix (BEST for this use case)
// prefix(_:) safely returns up to N elements — never crashes.
func getTopThreeScoresV2(from scores: [Int]) -> [Int] {
    return Array(scores.prefix(3))
}

// APPROACH 3: Safe subscript extension (Reusable across your whole project!)
extension Collection {
    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func getTopThreeScoresV3(from scores: [Int]) -> [Int] {
    // Using our safe subscript — returns nil instead of crashing
    let first  = scores[safe: 0]
    let second = scores[safe: 1]
    let third  = scores[safe: 2]
    
    // compactMap removes nil values
    return [first, second, third].compactMap { $0 }
}


// ---------------------------------------------------------------------------
// TEST — Verify all approaches work correctly
// ---------------------------------------------------------------------------

let manyScores = [95, 87, 92, 78, 88]
let fewScores  = [95]
let noScores: [Int] = []

print("=== Approach 1: Count Check ===")
print(getTopThreeScoresV1(from: manyScores))  // [95, 87, 92]
print(getTopThreeScoresV1(from: fewScores))   // [95]
print(getTopThreeScoresV1(from: noScores))    // []

print("\n=== Approach 2: prefix (Recommended) ===")
print(getTopThreeScoresV2(from: manyScores))  // [95, 87, 92]
print(getTopThreeScoresV2(from: fewScores))   // [95]
print(getTopThreeScoresV2(from: noScores))    // []

print("\n=== Approach 3: Safe Subscript Extension ===")
print(getTopThreeScoresV3(from: manyScores))  // [95, 87, 92]
print(getTopThreeScoresV3(from: fewScores))   // [95]
print(getTopThreeScoresV3(from: noScores))    // []

// BONUS: Using the safe subscript directly
let colors = ["Red", "Green", "Blue"]
print("\nSafe subscript demo:")
print(colors[safe: 0] ?? "No color")  // Red
print(colors[safe: 5] ?? "No color")  // No color (instead of crash!)


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "How would you handle a situation where a UITableView data source
//     array might be modified from a background thread while the table
//     view is reloading?"
//
// A: This is a classic race-condition leading to index-out-of-bounds crashes.
//    Solutions include:
//    1. Always modify data on the main thread before calling reloadData()
//    2. Use a snapshot/copy of the array for the data source methods
//    3. Use DiffableDataSource (iOS 13+) which handles this automatically
//    4. Use a serial DispatchQueue to synchronize access to the array
//
//    The safe subscript extension above is also a good defensive measure,
//    but it treats the symptom — the real fix is proper synchronization.
// ---------------------------------------------------------------------------
