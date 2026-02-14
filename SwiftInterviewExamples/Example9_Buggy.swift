// EXAMPLE 9: Thread Safety / Race Condition (Hard)
// BUG: Shared mutable state accessed from multiple threads without sync
// Expected: Thread-safe counter

class Counter {
    var count = 0
    
    func increment() {
        count += 1  // 💥 Not atomic! Two threads can read same value
    }
}

// Thread 1: reads 0, writes 1
// Thread 2: reads 0 (before 1 is written), writes 1
// Result: count = 1 instead of 2
