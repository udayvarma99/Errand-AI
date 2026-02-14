// EXAMPLE 9: Thread Safety / Race Condition (FIXED)
// Use serial queue or actor (Swift 5.5+) for thread safety

// Option A: Serial DispatchQueue
class Counter {
    private var _count = 0
    private let queue = DispatchQueue(label: "counter.queue")
    
    var count: Int {
        queue.sync { _count }
    }
    
    func increment() {
        queue.sync { _count += 1 }  // sync ensures atomic read-modify-write
    }
}

// Option B: Swift Actor (Swift 5.5+)
// actor Counter {
//     var count = 0
//     func increment() { count += 1 }
// }
