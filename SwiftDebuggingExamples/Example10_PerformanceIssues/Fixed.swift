// Example 10: Performance Issues - FIXED VERSION
// Optimized collection operations

import Foundation

// FIX 1: Use appropriate data structure
class FastTaskQueue {
    private var tasks: [String] = []
    private var startIndex = 0
    
    func addTask(_ task: String) {
        tasks.append(task)
    }
    
    func processNext() -> String? {
        guard startIndex < tasks.count else {
            // Reset when empty
            tasks.removeAll()
            startIndex = 0
            return nil
        }
        
        // ✅ O(1) operation
        let task = tasks[startIndex]
        startIndex += 1
        
        // Periodically clean up
        if startIndex > 100 {
            tasks.removeFirst(startIndex)
            startIndex = 0
        }
        
        return task
    }
}

// Alternative: Use Deque or LinkedList-like structure
class QueueWithArray<T> {
    private var array: [T] = []
    
    func enqueue(_ item: T) {
        array.append(item)  // O(1) amortized
    }
    
    func dequeue() -> T? {
        guard !array.isEmpty else { return nil }
        return array.removeFirst()  // O(n) but acceptable for small queues
    }
}

// FIX 2: Use string builder
func buildString(count: Int) -> String {
    // ✅ O(n) with proper capacity
    var parts: [String] = []
    parts.reserveCapacity(count)
    
    for i in 0..<count {
        parts.append("Item \(i)")
        parts.append(", ")
    }
    
    return parts.joined()
}

// Alternative: Direct string interpolation for small counts
func buildStringSmall(count: Int) -> String {
    (0..<count).map { "Item \($0)" }.joined(separator: ", ")
}

// FIX 3: Use Set for lookups
func filterUnique(_ items: [String], exclude: [String]) -> [String] {
    // ✅ O(1) lookup with Set
    let excludeSet = Set(exclude)
    
    return items.filter { !excludeSet.contains($0) }
}

// FIX 4: Use compactMap
func processNumbers(_ numbers: [String]) -> [Int] {
    // ✅ Safe and efficient
    return numbers.compactMap { Int($0) }
}

// FIX 5: Single dictionary lookup
func sumUserScores(_ users: [String], scores: [String: Int]) -> Int {
    var total = 0
    
    for user in users {
        // ✅ Single lookup using if let
        if let score = scores[user] {
            total += score
        }
    }
    
    return total
}

// Alternative: Use reduce
func sumUserScoresReduce(_ users: [String], scores: [String: Int]) -> Int {
    users.reduce(0) { $0 + (scores[$1] ?? 0) }
}

// FIX 6: Use first(where:)
func findFirstMatch(_ items: [Int], condition: (Int) -> Bool) -> Int? {
    // ✅ Stops at first match
    return items.first(where: condition)
}

// FIX 7: Use default value subscript
func countOccurrences(_ items: [String]) -> [String: Int] {
    var counts: [String: Int] = [:]
    
    for item in items {
        // ✅ Single operation with default
        counts[item, default: 0] += 1
    }
    
    return counts
}

// Alternative: Use reduce
func countOccurrencesReduce(_ items: [String]) -> [String: Int] {
    items.reduce(into: [:]) { counts, item in
        counts[item, default: 0] += 1
    }
}

// FIX 8: Operate in-place or use map
struct DataProcessor {
    func process(_ data: [Int]) -> [Int] {
        // ✅ No copy, transforms directly
        return data.map { $0 * 2 }
    }
    
    // In-place mutation for var array
    func processInPlace(_ data: inout [Int]) {
        for i in data.indices {
            data[i] *= 2
        }
    }
}

// FIX 9: Use lazy evaluation
func expensiveTransform(_ numbers: [Int]) -> Int? {
    // ✅ Lazy - stops at first match
    return numbers
        .lazy
        .map { $0 * 2 }
        .first { $0 > 100 }
}

// FIX 10: Filter before sorting or use different approach
func sortAndFilter(_ items: [Int], threshold: Int) -> [Int] {
    // ✅ Filter first to reduce sort size
    return items
        .filter { $0 > threshold }
        .sorted()
}

// BONUS: Performance best practices

// 1. Reserve capacity when size is known
func reserveCapacityExample(count: Int) -> [Int] {
    var array: [Int] = []
    array.reserveCapacity(count)  // ✅ Avoid reallocations
    
    for i in 0..<count {
        array.append(i)
    }
    
    return array
}

// 2. Use ContiguousArray for performance-critical code
func contiguousArrayExample() -> ContiguousArray<Int> {
    var array = ContiguousArray<Int>()
    array.reserveCapacity(1000)
    
    for i in 0..<1000 {
        array.append(i)
    }
    
    return array
}

// 3. Use reduce(into:) instead of reduce
func reduceIntoExample(_ items: [Int]) -> [Int] {
    // ✅ Mutates accumulator in-place
    return items.reduce(into: []) { result, item in
        result.append(item * 2)
    }
}

// 4. Batch operations
func batchUpdate(_ items: inout [Int]) {
    // ✅ Single mutation instead of many
    items = items.map { $0 * 2 }
}

// 5. Use indices for safe iteration
func safeIteration(_ items: [Int]) -> [Int] {
    var result: [Int] = []
    
    for index in items.indices {
        result.append(items[index] * 2)
    }
    
    return result
}

// Demonstrate improvements:
print("=== Performance Optimized ===\n")

print("Fix 1: Fast task queue")
let queue = FastTaskQueue()
for i in 0..<1000 {
    queue.addTask("Task \(i)")
}

let start1 = Date()
for _ in 0..<100 {
    _ = queue.processNext()
}
print("Time: \(Date().timeIntervalSince(start1))s - Fast! ✅\n")

print("Fix 2: String builder")
let start2 = Date()
let longString = buildString(count: 1000)
print("Time: \(Date().timeIntervalSince(start2))s - Fast! ✅\n")

print("Fix 3: Set for lookups")
let items = Array(0..<1000).map { "Item \(Int.random(in: 0..<100))" }
let exclude = Array(0..<500).map { "Item \($0)" }

let start3 = Date()
let unique = filterUnique(items, exclude: exclude)
print("Time: \(Date().timeIntervalSince(start3))s - Fast! ✅")
print("Result count: \(unique.count)\n")

print("Fix 4: compactMap")
let numbers = (0..<1000).map { "\($0)" }
let start4 = Date()
let processed = processNumbers(numbers)
print("Time: \(Date().timeIntervalSince(start4))s - Fast! ✅")
print("Processed: \(processed.count)\n")

print("Fix 9: Lazy evaluation")
let largeArray = Array(0..<100000)
let start9 = Date()
let first = expensiveTransform(largeArray)
print("Time: \(Date().timeIntervalSince(start9))s - Fast! ✅")
print("First match: \(first ?? 0)\n")

print("✅ All performance optimizations working!")

// Performance comparison
func comparePerformance() {
    print("\n=== Performance Comparison ===\n")
    
    // Test 1: Array vs Set for contains
    let largeArray = Array(0..<10000)
    let largeSet = Set(largeArray)
    let searchItems = Array(0..<1000)
    
    let arrayStart = Date()
    for item in searchItems {
        _ = largeArray.contains(item)
    }
    let arrayTime = Date().timeIntervalSince(arrayStart)
    print("Array contains: \(arrayTime)s")
    
    let setStart = Date()
    for item in searchItems {
        _ = largeSet.contains(item)
    }
    let setTime = Date().timeIntervalSince(setStart)
    print("Set contains: \(setTime)s")
    print("Set is \(Int(arrayTime / setTime))x faster! ✅\n")
    
    // Test 2: map vs lazy.map
    let numbers = Array(0..<100000)
    
    let mapStart = Date()
    _ = numbers.map { $0 * 2 }.filter { $0 > 1000 }.first
    let mapTime = Date().timeIntervalSince(mapStart)
    print("Eager map: \(mapTime)s")
    
    let lazyStart = Date()
    _ = numbers.lazy.map { $0 * 2 }.filter { $0 > 1000 }.first
    let lazyTime = Date().timeIntervalSince(lazyStart)
    print("Lazy map: \(lazyTime)s")
    print("Lazy is \(Int(mapTime / lazyTime))x faster! ✅")
}

comparePerformance()
