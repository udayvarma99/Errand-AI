import Foundation

// MARK: - Example 02: Index out of range
//
// Broken (common):
//   let item = items[i]   // crashes if i is invalid
//
// Debug:
// - Inspect `i` and `items.count` right before indexing.
// - Add `precondition(i >= 0 && i < items.count)` to catch earlier in debug builds.

public extension Array {
    /// Returns the element at `index` if it's in-bounds, otherwise `nil`.
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

public enum Example02_SafeIndexing {
    public static func element<T>(at index: Int, in array: [T]) -> T? {
        array[safe: index]
    }
}

