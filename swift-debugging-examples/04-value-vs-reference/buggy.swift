// BUGGY: Expecting reference semantics with a Struct (value type!)
// Interview scenario: "Why doesn't this share state between two views?"
struct Counter {
    var count: Int = 0
    
    mutating func increment() {
        count += 1
    }
}

var counter = Counter()
let copy = counter  // Creates a COPY (value type)
counter.increment()

print(copy.count)   // 💥 Prints 0 - Developer expected 1! copy is independent
print(counter.count) // Prints 1

// The bug: Developer thought both reference same object (like a class would)
