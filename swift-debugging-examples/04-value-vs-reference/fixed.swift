// FIXED: Understand value vs reference - Pick the right type!
struct Counter {
    var count: Int = 0
    
    mutating func increment() {
        count += 1
    }
}

// Value type (Struct): Each assignment = copy
var counter = Counter()
counter.increment()
print(counter.count)  // 1

// Need shared mutable state? Use Class (reference type)
class SharedCounter {
    var count: Int = 0
    
    func increment() {
        count += 1
    }
}

let shared1 = SharedCounter()
let shared2 = shared1  // Same reference!
shared1.increment()
print(shared2.count)   // 1 - they share the same object ✅
