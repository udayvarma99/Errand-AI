// Example 10 FIXED: Thread-safe access
// Use: serial queue, lock, or actor (Swift 5.5+)

import Foundation

// Option 1: Serial queue - all writes go through one queue
class CounterSafe {
    private var _count = 0
    private let queue = DispatchQueue(label: "counter.queue")
    
    var count: Int { queue.sync { _count } }
    
    func increment() {
        queue.sync { _count += 1 }
    }
}

let counter = CounterSafe()
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}
print(counter.count)  // ✅ Always 1000 - predictable!

// Option 2: Actor (Swift 5.5+) - use in async/await code
// actor Counter { var count = 0; func increment() { count += 1 } }
