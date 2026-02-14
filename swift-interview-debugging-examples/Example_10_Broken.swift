// Example 10: Data Race / Thread Safety
// BUG: Multiple threads writing same variable = undefined behavior
// "Random crashes when scrolling" - classic concurrency bug

import Foundation

class Counter {
    var count = 0  // 💥 Not thread-safe
    
    func increment() {
        count += 1  // Not atomic - race condition!
    }
}

let counter = Counter()
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}
print(counter.count)  // Might print 847, 912, 998 - unpredictable!
