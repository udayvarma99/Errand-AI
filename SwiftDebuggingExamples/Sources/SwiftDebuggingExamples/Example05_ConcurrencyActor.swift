import Foundation

// MARK: - Example 05: Data race (shared mutable state)
//
// Broken (common):
//   final class Counter { var value = 0; func inc() { value += 1 } }
// If called from multiple threads/tasks, this can race.
//
// Debug:
// - Enable Thread Sanitizer (TSAN) and reproduce.
// - TSAN points to the conflicting reads/writes.
//
// Fix:
// - Use an `actor` (or locks / serial queue) to protect shared state.

public final class UnsafeCounter {
    public var value: Int = 0
    public init() {}
    public func increment() { value += 1 }
}

public actor CounterActor {
    private var value: Int = 0

    public init() {}

    public func increment() {
        value += 1
    }

    public func get() -> Int {
        value
    }
}

