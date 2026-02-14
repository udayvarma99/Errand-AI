import Foundation

// MARK: - Example 07: Performance bug (O(n^2) membership checks)
//
// Broken (common):
// - Loop over A and call `b.contains(x)` when B is an Array (O(n) each).
//
// Debug:
// - Instruments: Time Profiler to find repeated `Array.contains`.
//
// Fix:
// - Use `Set` for average O(1) membership.

public enum Example07_PerformanceSet {
    /// Teaching example: correct but can be slow.
    public static func commonElementsSlow<T: Equatable>(_ a: [T], _ b: [T]) -> [T] {
        var result: [T] = []
        result.reserveCapacity(min(a.count, b.count))

        for x in a {
            if b.contains(x) {
                result.append(x)
            }
        }

        return result
    }

    /// Fixed: uses a Set to speed up lookups.
    public static func commonElementsFast<T: Hashable>(_ a: [T], _ b: [T]) -> [T] {
        let setB = Set(b)
        return a.filter { setB.contains($0) }
    }
}

