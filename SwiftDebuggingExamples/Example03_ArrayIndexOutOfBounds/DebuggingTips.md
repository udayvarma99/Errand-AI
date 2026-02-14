# Debugging Array Index Out of Bounds

## 🔧 Finding the Problem

### Reading the Crash Log

When you see:
```
Fatal error: Index out of range
```

**Look for:**
- The line number where crash occurred
- The index that was accessed
- The array size at time of crash

### Xcode Crash Location

Xcode will highlight the exact line:
```swift
let item = array[5]  // <-- Thread 1: Fatal error: Index out of range
```

## 🛠 Debugging Techniques

### Technique 1: Print Debugging

Add prints before array access:

```swift
print("Array count: \(array.count)")
print("Accessing index: \(index)")
print("Valid indices: \(array.indices)")

let item = array[index]
```

### Technique 2: Breakpoints

1. Set breakpoint before array access
2. Check values in Variables view:
   - `array.count`
   - `index`
   - `array.indices`

### Technique 3: Conditional Breakpoint

Set breakpoint with condition:
```
index >= array.count
```

This breaks only when index is invalid.

### Technique 4: LLDB Commands

```
(lldb) po array.count
(lldb) po index
(lldb) po array.indices
(lldb) po array.indices.contains(index)
```

### Technique 5: Exception Breakpoint

1. Debug Navigator → +
2. Add Exception Breakpoint
3. Set to break on "All" exceptions

Will stop at exact crash location.

## 🔍 Common Debugging Scenarios

### Scenario 1: Empty Array

```swift
// Add assertion
assert(!array.isEmpty, "Array should not be empty")
let first = array[0]

// Or precondition
precondition(!array.isEmpty, "Array must have elements")
let first = array[0]

// Or defensive check
guard !array.isEmpty else {
    print("DEBUG: Array is empty!")
    print("Stack trace: \(Thread.callStackSymbols)")
    return
}
let first = array[0]
```

### Scenario 2: Finding Invalid Index

```swift
// Log when index is set
var currentIndex: Int = 0 {
    didSet {
        print("Index changed to: \(currentIndex)")
        print("Array count: \(array.count)")
        
        if !array.indices.contains(currentIndex) {
            print("⚠️ WARNING: Invalid index!")
            print("Call stack: \(Thread.callStackSymbols)")
        }
    }
}
```

### Scenario 3: Tracking Array Modifications

```swift
var items: [Item] = [] {
    didSet {
        print("Array modified. New count: \(items.count)")
        print("Old count: \(oldValue.count)")
    }
}
```

### Scenario 4: Loop Issues

```swift
// Debug loop bounds
print("Loop range: 0..<\(array.count)")
for i in 0..<array.count {
    print("Accessing index: \(i), array count: \(array.count)")
    
    // Check before access
    guard array.indices.contains(i) else {
        print("💥 Index \(i) is invalid!")
        break
    }
    
    let item = array[i]
}
```

## 🎯 Defensive Programming

### Add Runtime Checks (Debug Only)

```swift
#if DEBUG
extension Array {
    subscript(checked index: Int) -> Element {
        guard indices.contains(index) else {
            fatalError("Index \(index) out of range [0..<\(count)]")
        }
        return self[index]
    }
}
#endif

// Usage
let item = array[checked: index]  // Better crash message
```

### Custom Error Messages

```swift
func getItem(at index: Int) -> Item {
    guard array.indices.contains(index) else {
        fatalError("""
            Index out of range!
            Requested: \(index)
            Valid range: \(array.indices)
            Array count: \(array.count)
            """)
    }
    return array[index]
}
```

### Assertions for Development

```swift
func processArray() {
    assert(array.count >= 3, "Need at least 3 items")
    
    let first = array[0]
    let second = array[1]
    let third = array[2]
}
```

## 📊 Testing for Array Bugs

### Unit Tests

```swift
import XCTest

class ArrayAccessTests: XCTestCase {
    func testEmptyArrayAccess() {
        let manager = TaskManager()
        
        // Should not crash
        let first = manager.getFirstTask()
        XCTAssertNil(first)
    }
    
    func testInvalidIndexAccess() {
        let manager = TaskManager()
        manager.tasks = [Task(title: "Test", isCompleted: false)]
        
        let task = manager.getTask(at: 10)
        XCTAssertNil(task)
    }
    
    func testRangeAccess() {
        let manager = TaskManager()
        manager.tasks = Array(repeating: Task(title: "Test", isCompleted: false), count: 5)
        
        // Valid range
        let range1 = manager.getTaskRange(start: 0, end: 4)
        XCTAssertNotNil(range1)
        XCTAssertEqual(range1?.count, 5)
        
        // Invalid range
        let range2 = manager.getTaskRange(start: 0, end: 10)
        XCTAssertNil(range2)
    }
}
```

### Property-Based Testing

```swift
func testArrayAccessProperty() {
    let array = [1, 2, 3, 4, 5]
    
    // Property: safe subscript never crashes
    for index in -10...20 {
        _ = array[safe: index]  // Should never crash
    }
}
```

## 🚀 Advanced Debugging

### Memory Debugger

For concurrent modification issues:

1. Run with Thread Sanitizer (Edit Scheme → Diagnostics)
2. Enable "Thread Sanitizer"
3. Run app
4. Look for data race warnings

### Instruments - Allocations

Track array lifecycle:

1. Product → Profile
2. Select "Allocations"
3. Filter by your array type
4. See when arrays are created/destroyed

### Custom Debug Description

```swift
extension Array {
    var debugInfo: String {
        """
        Array Debug Info:
        - Count: \(count)
        - Indices: \(indices)
        - Empty: \(isEmpty)
        - First: \(first.map(String.init(describing:)) ?? "nil")
        - Last: \(last.map(String.init(describing:)) ?? "nil")
        """
    }
}

// Usage
print(array.debugInfo)
```

## 💡 Preventive Measures

### SwiftLint Rules

Add to `.swiftlint.yml`:

```yaml
force_unwrapping:
  severity: error

array_init:
  severity: warning
  
empty_count:
  severity: warning
```

### Code Review Checklist

- [ ] No direct `[0]` access without checking `isEmpty`
- [ ] No array access with user input without validation
- [ ] Loop bounds use `0..<count` not `0...count`
- [ ] No modification of array during iteration
- [ ] Range access validates bounds
- [ ] All array access has nil/error handling

### Static Analysis

Run Xcode's static analyzer:
```
Product → Analyze (⌘⇧B)
```

Looks for:
- Out of bounds access
- Null dereference
- Logic errors

## 🔧 Quick Fixes

### Fix 1: Replace Direct Access

```bash
# Find all array[0] patterns
grep -r "array\[0\]" .

# Replace with safe access
# array[0] → array.first
```

### Fix 2: Add Safe Extension

```swift
// Add to your project
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Replace dangerous accesses
// array[index] → array[safe: index]
```

### Fix 3: Wrap in Guard

```swift
// Before
let item = array[index]

// After
guard array.indices.contains(index) else { return }
let item = array[index]
```

## 📝 Debug Logging Template

```swift
func debugArrayAccess<T>(_ array: [T], index: Int, file: String = #file, line: Int = #line) {
    print("""
        ⚠️ Array Access Debug ⚠️
        Location: \(file):\(line)
        Array count: \(array.count)
        Requested index: \(index)
        Valid: \(array.indices.contains(index))
        Valid indices: \(array.indices)
        """)
}

// Usage
debugArrayAccess(myArray, index: 5)
if myArray.indices.contains(5) {
    let item = myArray[5]
}
```

## 🎓 Learning from Crashes

### Save Crash Logs

When you find a crash:

1. Save the crash log
2. Note the array size and index
3. Add test case to prevent regression
4. Add defensive check at crash location

### Crash Analysis Template

```markdown
## Crash: Array Index Out of Bounds

**Date:** 2024-02-14
**Location:** TaskManager.swift:42
**Array:** tasks
**Count:** 0
**Index Accessed:** 0

**Root Cause:** Array accessed before data loaded

**Fix:** Added isEmpty check before access

**Test Added:** testEmptyArrayHandling()

**Prevention:** All array access now uses safe subscript
```

## 📚 Additional Tips

1. **Enable NSZombie** for debugging freed objects
2. **Use Address Sanitizer** to catch memory issues
3. **Add debug assertions** during development
4. **Test edge cases** (empty, single element, full)
5. **Log array operations** in complex code
6. **Use breakpoints** to inspect state before crashes
7. **Create helper methods** for common safe operations
8. **Document array size assumptions** in comments
