import Foundation

// MARK: - Example 04: Value semantics bug (struct copy)
//
// Broken (common):
//   func add(_ item: String, to bag: Bag) {
//       var copy = bag
//       copy.items.append(item)
//   }
// Caller expects `bag` to change, but `struct` values are copied.
//
// Debug:
// - Step through and compare `bag` vs `copy`.
// - Decide whether you want an `inout` API (mutates caller) or a pure function (returns new value).

public struct Bag: Equatable {
    public var items: [String]

    public init(items: [String] = []) {
        self.items = items
    }
}

public enum Example04_ValueSemantics {
    /// Broken: mutates only a local copy. (Kept here as a teaching example.)
    public static func addBroken(_ item: String, to bag: Bag) {
        var copy = bag
        copy.items.append(item)
        _ = copy
    }

    /// Fixed: explicitly mutates the caller using `inout`.
    public static func addFixed(_ item: String, to bag: inout Bag) {
        bag.items.append(item)
    }

    /// Alternative fix: pure function that returns a new value.
    public static func adding(_ item: String, to bag: Bag) -> Bag {
        var copy = bag
        copy.items.append(item)
        return copy
    }
}

