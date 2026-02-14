import Foundation

// MARK: - Example 06: Off-by-one in binary search
//
// Debug tip:
// - For loop/invariant bugs, write edge-case tests first:
//   empty, 1 element, first/last, target missing, target < min, target > max.
// - Step through while watching low/high/mid.

public enum Example06_BinarySearch {
    /// Returns the index of `target` if found, otherwise `nil`.
    public static func binarySearch<T: Comparable>(_ array: [T], target: T) -> Int? {
        var low = 0
        var high = array.count - 1

        while low <= high {
            let mid = low + (high - low) / 2
            let value = array[mid]

            if value == target {
                return mid
            } else if value < target {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return nil
    }
}

