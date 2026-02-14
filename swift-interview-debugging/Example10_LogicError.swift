// =============================================================================
// EXAMPLE 10: Off-by-One & Logic Errors
// =============================================================================
// INTERVIEW TIP: Trace through loops and edge cases (empty, single, last)
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Off-by-one in loop
// -----------------------------------------------------------------------------

func sumFirstN_BUG(_ n: Int) -> Int {
    var sum = 0
    for i in 0...n {
        sum += i
    }
    return sum
}
// sumFirstN_BUG(5) = 0+1+2+3+4+5 = 15 ✓ (Actually correct for "first N")
// But if "first 5" means 0..<5:
func sumFirstFive_BUG() -> Int {
    var sum = 0
    for i in 0...5 {
        sum += i
    }
    return sum
}
// Returns 0+1+2+3+4+5=15, but "first 5" might mean 0,1,2,3,4 = 10

// -----------------------------------------------------------------------------
// ✅ FIX: Be explicit about ranges
// -----------------------------------------------------------------------------

func sumFirstN_FIX(_ n: Int) -> Int {
    (0..<n).reduce(0, +)  // 0 to n-1
}
// sumFirstN_FIX(5) = 0+1+2+3+4 = 10

// -----------------------------------------------------------------------------
// 🐛 BUG: Wrong comparison operator
// -----------------------------------------------------------------------------

func isAdult_BUG(age: Int) -> Bool {
    return age > 18  // ❌ 18 is adult! Should be >=
}

// -----------------------------------------------------------------------------
// ✅ FIX
// -----------------------------------------------------------------------------

func isAdult_FIX(age: Int) -> Bool {
    return age >= 18
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Empty/single element edge case
// -----------------------------------------------------------------------------

func findMax_BUG(_ array: [Int]) -> Int {
    var max = array[0]  // ❌ CRASH if array is empty!
    for n in array {
        if n > max { max = n }
    }
    return max
}

// -----------------------------------------------------------------------------
// ✅ FIX: Guard for empty
// -----------------------------------------------------------------------------

func findMax_FIX(_ array: [Int]) -> Int? {
    guard !array.isEmpty else { return nil }
    var max = array[0]
    for n in array {
        if n > max { max = n }
    }
    return max
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Modifying collection while iterating
// -----------------------------------------------------------------------------

var items = [1, 2, 3, 4]
for item in items {
    if item % 2 == 0 {
        items.removeAll { $0 == item }  // ❌ Undefined behavior
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX: Filter into new array
// -----------------------------------------------------------------------------

let filtered = items.filter { $0 % 2 != 0 }

// 📌 KEY LESSON: Test edge cases: empty, single element, duplicates.
//    Double-check loop bounds (0..<n vs 0...n). Avoid mutating while iterating.
