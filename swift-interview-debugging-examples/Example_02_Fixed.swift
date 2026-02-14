// Example 2 FIXED: Bounds Checking
// Always validate indices before accessing

import Foundation

func getFirstAndLast(from array: [Int]) -> (Int, Int)? {
    guard !array.isEmpty else { return nil }
    let first = array[0]
    let last = array[array.count - 1]
    return (first, last)
}

let numbers = [1, 2, 3, 4, 5]
if let result = getFirstAndLast(from: numbers) {
    print(result)  // (1, 5)
}

let empty: [Int] = []
if let result = getFirstAndLast(from: empty) {
    print(result)
} else {
    print("Array is empty - no crash!")  // Safe handling
}
