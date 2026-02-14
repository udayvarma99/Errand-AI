// Example 2: Array Index Out of Bounds
// BUG: Accessing index that doesn't exist
// Interviewers often ask: "What happens when the array is empty?"

import Foundation

func getFirstAndLast(from array: [Int]) -> (Int, Int) {
    let first = array[0]   // 💥 CRASH if array is empty
    let last = array[array.count - 1]  // 💥 CRASH if array is empty
    return (first, last)
}

let numbers = [1, 2, 3, 4, 5]
print(getFirstAndLast(from: numbers))  // Works: (1, 5)

let empty: [Int] = []
print(getFirstAndLast(from: empty))  // CRASH: Index out of range
