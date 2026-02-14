import Foundation

// MARK: - Example 03: Retain cycle with stored closure
//
// Pattern:
// - Owner holds a helper object
// - Helper stores a closure
// - Closure captures owner strongly
// => cycle: Owner -> Helper -> Closure -> Owner
//
// Broken (common):
//   helper.onEvent = { self.handle() }
//
// Debug:
// - Add `deinit { print(...) }` and confirm it never fires.
// - Instruments: Leaks / Allocations to find the cycle.
//
// Fix:
// - Capture `[weak self]` (or `[unowned self]` if guaranteed).

public final class ProgressEmitter {
    public var onProgress: ((Double) -> Void)?

    public init() {}

    public func emit(_ progress: Double) {
        onProgress?(progress)
    }
}

public final class Example03_ViewModel {
    public private(set) var progress: Double = 0
    private let emitter: ProgressEmitter

    public init(emitter: ProgressEmitter = ProgressEmitter()) {
        self.emitter = emitter

        // Fixed: avoid retaining self strongly.
        emitter.onProgress = { [weak self] value in
            self?.progress = value
        }
    }

    public func simulateWork() {
        emitter.emit(0.25)
        emitter.emit(0.50)
        emitter.emit(1.0)
    }
}

