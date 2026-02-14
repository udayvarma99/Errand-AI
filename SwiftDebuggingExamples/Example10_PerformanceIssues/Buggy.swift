// Example 10: Performance Issues with Collections
// Common performance bugs that slow down your app

import Foundation

// BUG 1: Using array for frequent removals
class SlowTaskQueue {
    var tasks: [String] = []
    
    func addTask(_ task: String) {
        tasks.append(task)
    }
    
    func processNext() {
        guard !tasks.isEmpty else { return }
        // 🐛 O(n) operation! Shifts all elements
        let task = tasks.removeFirst()
        print("Processing: \(task)")
    }
}

// BUG 2: Repeated string concatenation
func buildString(count: Int) -> String {
    var result = ""
    
    // 🐛 O(n²) - creates new string each iteration
    for i in 0..<count {
        result += "Item \(i)"
        result += ", "
    }
    
    return result
}

// BUG 3: Contains check in loop
func filterUnique(_ items: [String], exclude: [String]) -> [String] {
    var result: [String] = []
    
    for item in items {
        // 🐛 O(n) for each iteration = O(n²) total
        if !exclude.contains(item) {
            result.append(item)
        }
    }
    
    return result
}

// BUG 4: Force unwrapping in tight loop
func processNumbers(_ numbers: [String]) -> [Int] {
    var result: [Int] = []
    
    for number in numbers {
        // 🐛 Force unwrap in loop can cause crashes
        // Also creates/destroys optionals repeatedly
        result.append(Int(number)!)
    }
    
    return result
}

// BUG 5: Repeated dictionary lookups
func sumUserScores(_ users: [String], scores: [String: Int]) -> Int {
    var total = 0
    
    for user in users {
        // 🐛 Multiple lookups of same key
        if scores[user] != nil {
            total += scores[user]!
        }
    }
    
    return total
}

// BUG 6: Creating unnecessary arrays
func findFirstMatch(_ items: [Int], condition: (Int) -> Bool) -> Int? {
    // 🐛 Creates entire filtered array just to get first element!
    let matches = items.filter(condition)
    return matches.first
}

// BUG 7: Inefficient counting
func countOccurrences(_ items: [String]) -> [String: Int] {
    var counts: [String: Int] = [:]
    
    for item in items {
        // 🐛 Lookup, unwrap, increment, assign - inefficient
        if let current = counts[item] {
            counts[item] = current + 1
        } else {
            counts[item] = 1
        }
    }
    
    return counts
}

// BUG 8: Copying large collections unnecessarily
struct DataProcessor {
    func process(_ data: [Int]) -> [Int] {
        var result = data  // 🐛 Full copy for large arrays
        
        for i in 0..<result.count {
            result[i] = result[i] * 2
        }
        
        return result
    }
}

// BUG 9: Not using lazy evaluation
func expensiveTransform(_ numbers: [Int]) -> Int? {
    // 🐛 Processes entire array even though we only need first match
    let transformed = numbers.map { $0 * 2 }
    let filtered = transformed.filter { $0 > 100 }
    return filtered.first
}

// BUG 10: Inefficient sorting
func sortAndFilter(_ items: [Int], threshold: Int) -> [Int] {
    // 🐛 Sorts entire array then filters
    let sorted = items.sorted()
    return sorted.filter { $0 > threshold }
}

// Demonstrate performance issues:
print("=== Performance Issues ===\n")

print("Bug 1: Slow task queue")
let queue = SlowTaskQueue()
for i in 0..<1000 {
    queue.addTask("Task \(i)")
}

let start1 = Date()
for _ in 0..<100 {
    queue.processNext()
}
print("Time: \(Date().timeIntervalSince(start1))s - Slow!\n")

print("Bug 2: String concatenation")
let start2 = Date()
let longString = buildString(count: 1000)
print("Time: \(Date().timeIntervalSince(start2))s - Slow!\n")

print("Bug 3: Contains in loop")
let items = Array(0..<1000).map { "Item \(Int.random(in: 0..<100))" }
let exclude = Array(0..<500).map { "Item \($0)" }

let start3 = Date()
let unique = filterUnique(items, exclude: exclude)
print("Time: \(Date().timeIntervalSince(start3))s - Slow!")
print("Result count: \(unique.count)\n")

print("❌ All examples show poor performance!")
