/*
 ============================================
 EXAMPLE 2: ARRAY INDEX OUT OF BOUNDS
 ============================================
 
 Common Issue: Accessing array elements without bounds checking
 Apple Interview Focus: Safe collection handling and validation
 */

import Foundation

// ❌ BUGGY CODE - This will crash!
class BuggyArrayHandler {
    let numbers = [1, 2, 3, 4, 5]
    
    func getThirdElement() -> Int {
        // 🐛 BUG: What if array has fewer than 3 elements?
        return numbers[2]  // Assumes array always has index 2
    }
    
    func getElementAtIndex(_ index: Int) -> Int {
        // 🐛 BUG: No bounds checking
        return numbers[index]  // Crashes if index >= count or index < 0
    }
    
    func removeLastThreeElements() -> [Int] {
        var mutableNumbers = numbers
        // 🐛 BUG: What if array has fewer than 3 elements?
        mutableNumbers.removeLast()
        mutableNumbers.removeLast()
        mutableNumbers.removeLast()
        return mutableNumbers  // Crashes if array has < 3 elements
    }
    
    func processUserInput() {
        let emptyArray: [String] = []
        // 🐛 BUG: Accessing first element without checking if array is empty
        let firstItem = emptyArray[0]  // 💥 CRASH!
        print(firstItem)
    }
    
    func iterateWithBuggyLogic() {
        let items = [10, 20, 30]
        // 🐛 BUG: Off-by-one error
        for i in 0...items.count {  // Should be 0..<items.count
            print(items[i])  // Crashes at items[3] (doesn't exist)
        }
    }
}

// Example of the crash:
func demonstrateBug() {
    let handler = BuggyArrayHandler()
    // handler.getElementAtIndex(10)  // 💥 CRASH: Index out of range
    // handler.processUserInput()     // 💥 CRASH: Index out of range
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Print array.count before accessing indices
 2. Use LLDB: `po array.count` and `po index`
 3. Look at the crash log - it will say "Index out of range"
 4. Add assertions during development: assert(index < array.count)
 5. Use Xcode's Address Sanitizer to catch these issues
 */

// ✅ FIXED CODE - Safe Array Access

class FixedArrayHandler {
    let numbers = [1, 2, 3, 4, 5]
    
    // SOLUTION 1: Check array count before accessing
    func getThirdElement() -> Int? {
        guard numbers.count >= 3 else {
            return nil
        }
        return numbers[2]
    }
    
    // SOLUTION 2: Validate index bounds
    func getElementAtIndex(_ index: Int) -> Int? {
        guard index >= 0 && index < numbers.count else {
            print("⚠️ Index \(index) is out of bounds")
            return nil
        }
        return numbers[index]
    }
    
    // SOLUTION 3: Use safe subscript extension
    func getElementSafely(_ index: Int) -> Int? {
        return numbers[safe: index]  // Uses extension below
    }
    
    // SOLUTION 4: Use first/last properties
    func getFirstElement() -> Int? {
        return numbers.first  // Returns nil if empty, never crashes
    }
    
    func getLastElement() -> Int? {
        return numbers.last  // Returns nil if empty
    }
    
    // SOLUTION 5: Safe removal with count check
    func removeLastThreeElements() -> [Int] {
        var mutableNumbers = numbers
        
        // Remove elements safely
        for _ in 0..<min(3, mutableNumbers.count) {
            if !mutableNumbers.isEmpty {
                mutableNumbers.removeLast()
            }
        }
        return mutableNumbers
    }
    
    // SOLUTION 6: Better - use dropLast
    func removeLastThreeElementsBetter() -> [Int] {
        return Array(numbers.dropLast(min(3, numbers.count)))
    }
    
    // SOLUTION 7: Safe iteration
    func iterateCorrectly() {
        let items = [10, 20, 30]
        
        // Method 1: Use indices property
        for index in items.indices {
            print(items[index])
        }
        
        // Method 2: Use enumerated()
        for (index, value) in items.enumerated() {
            print("Index \(index): \(value)")
        }
        
        // Method 3: Direct iteration (best if you don't need index)
        for value in items {
            print(value)
        }
    }
    
    // SOLUTION 8: Safe array slicing
    func getFirstThreeElements() -> [Int] {
        let count = min(3, numbers.count)
        return Array(numbers.prefix(count))
    }
    
    // SOLUTION 9: Handling empty arrays
    func processUserInput(items: [String]) {
        // Check if array has elements
        guard !items.isEmpty else {
            print("Array is empty")
            return
        }
        
        let firstItem = items[0]  // Now safe
        print("First item: \(firstItem)")
        
        // Better: use .first
        if let first = items.first {
            print("First item: \(first)")
        }
    }
}

// 🛠️ BONUS: Create a safe subscript extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Extension for safe range access
extension Array {
    func safely(from start: Int, to end: Int) -> [Element] {
        let safeStart = max(0, start)
        let safeEnd = min(count, end)
        guard safeStart < safeEnd else { return [] }
        return Array(self[safeStart..<safeEnd])
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    let handler = FixedArrayHandler()
    
    print("=== Safe element access ===")
    if let element = handler.getElementAtIndex(2) {
        print("Element at index 2: \(element)")
    }
    
    if let element = handler.getElementAtIndex(10) {
        print("Element at index 10: \(element)")
    } else {
        print("Index 10 is out of bounds")
    }
    
    print("\n=== Using safe subscript ===")
    let numbers = [1, 2, 3, 4, 5]
    print("numbers[safe: 2] = \(numbers[safe: 2] ?? -1)")
    print("numbers[safe: 10] = \(numbers[safe: 10] ?? -1)")
    
    print("\n=== Safe first/last ===")
    let emptyArray: [Int] = []
    print("Empty array first: \(emptyArray.first ?? -1)")
    print("Numbers array last: \(numbers.last ?? -1)")
    
    print("\n=== Safe iteration ===")
    handler.iterateCorrectly()
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. ALWAYS validate array bounds before accessing indices
 2. Use .first and .last instead of [0] and [count-1]
 3. Use .indices for safe index iteration
 4. Prefer enumerated() when you need both index and value
 5. Use half-open range 0..<count, NOT 0...count
 6. Create safe subscript extensions for cleaner code
 7. Check isEmpty before assuming array has elements
 8. Use prefix/suffix for getting first/last N elements
 
 🎯 SAFE ARRAY PATTERNS:
 
 - array.first / array.last (returns optional)
 - array.indices (safe index range)
 - array[safe: index] (custom extension)
 - array.prefix(n) / array.suffix(n)
 - for item in array (no indices needed)
 - array.isEmpty check before access
 
 ⚠️  COMMON MISTAKES:
 
 - Using ... instead of ..< for ranges (off-by-one error)
 - Assuming arrays always have elements
 - Not checking bounds after user input
 - Using removeLast() without checking isEmpty
 - Accessing [0] without checking count > 0
 
 💡 INTERVIEW TIP:
 When writing code, always ask yourself:
 "What if this array is empty?"
 "What if the index is negative or too large?"
 */

// Run the demonstration
demonstrateFix()
