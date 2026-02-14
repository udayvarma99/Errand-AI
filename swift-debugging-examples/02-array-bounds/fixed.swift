// FIXED: Safe array access - Always check bounds first
func getFifthElement(from array: [Int]) -> Int? {
    guard array.count > 4 else {
        return nil
    }
    return array[4]
}

// Alternative: Use indices
func getFifthElementSafe(from array: [Int]) -> Int? {
    let index = 4
    guard array.indices.contains(index) else {
        return nil
    }
    return array[index]
}

let numbers = [1, 2, 3]
if let fifth = getFifthElement(from: numbers) {
    print(fifth)
} else {
    print("Array too short")  // ✅ This runs - no crash!
}
