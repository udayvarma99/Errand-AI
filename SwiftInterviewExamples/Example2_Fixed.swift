// EXAMPLE 2: Array Index Bounds (FIXED)
// Always validate index before access

func getSecondElement<T>(from array: [T]) -> T? {
    guard array.count > 1 else {
        return nil
    }
    return array[1]
}

// Or use Swift's subscript safely:
// return array.indices.contains(1) ? array[1] : nil
