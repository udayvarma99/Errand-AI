import Foundation

// MARK: - Example 09: Timer retains its target (and closures can retain self)
//
// Broken (common):
//   timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//       self.tick() // strong capture; timer keeps firing and can keep self alive
//   }
//
// Debug:
// - Add `deinit` and confirm it doesn't run.
// - Instruments: Allocations (look for Timer retaining chains).
//
// Fix:
// - Capture `[weak self]`
// - Invalidate the timer when done (and in `deinit` as a safety net)

public final class Ticker {
    private var timer: Timer?
    private(set) var ticks: Int = 0

    public init() {}

    deinit {
        stop()
    }

    public func start(interval: TimeInterval = 1.0) {
        stop()

        // This requires a run loop (e.g. iOS app / macOS app).
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        ticks += 1
    }
}

