// =============================================================================
// EXAMPLE 3: Array Index Out of Bounds
// =============================================================================
// INTERVIEW TIP: Always validate indices before accessing arrays
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Accessing index that doesn't exist = CRASH
// -----------------------------------------------------------------------------

func getThirdElement_BUG(array: [Int]) -> Int {
    return array[2]  // ❌ CRASH if array has < 3 elements
}
// getThirdElement_BUG(array: [1, 2])  // Index out of range!

// -----------------------------------------------------------------------------
// ✅ FIX 1: Check count first
// -----------------------------------------------------------------------------

func getThirdElement_FIX1(array: [Int]) -> Int? {
    guard array.count > 2 else { return nil }
    return array[2]
}

// -----------------------------------------------------------------------------
// ✅ FIX 2: Use safe subscript
// -----------------------------------------------------------------------------

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func getThirdElement_FIX2(array: [Int]) -> Int? {
    return array[safe: 2]
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Removing while iterating (or wrong index)
// -----------------------------------------------------------------------------

func removeEvens_BUG(array: [Int]) -> [Int] {
    var result = array
    for i in 0..<result.count {
        if result[i] % 2 == 0 {
            result.remove(at: i)  // ❌ Shifts indices, skips elements!
        }
    }
    return result
}

// -----------------------------------------------------------------------------
// ✅ FIX: Iterate backwards or use filter
// -----------------------------------------------------------------------------

func removeEvens_FIX(array: [Int]) -> [Int] {
    return array.filter { $0 % 2 != 0 }
}

func removeEvens_FIX2(array: [Int]) -> [Int] {
    var result = array
    for i in (0..<result.count).reversed() {
        if result[i] % 2 == 0 {
            result.remove(at: i)
        }
    }
    return result
}

// 📌 KEY LESSON: Never assume array has N elements. Use guard, optional
//    subscript, or .indices.contains(index) before array[index].
