// EXAMPLE 2: Array Index Bounds (Beginner)
// BUG: Accessing index without checking bounds
// Expected: Get the second element safely

func getSecondElement<T>(from array: [T]) -> T? {
    return array[1]  // 💥 Crashes if array has 0 or 1 element
}

// Will crash:
// getSecondElement(from: [])
// getSecondElement(from: [1])
