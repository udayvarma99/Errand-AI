# Swift Debugging - Quick Reference Cheat Sheet

## 🚨 Most Common Bugs & Quick Fixes

### 1. Optional Unwrapping Crashes
```swift
// ❌ WRONG
let value = optional!  // Crashes if nil

// ✅ CORRECT
if let value = optional {
    // Use value safely
}
// OR
let value = optional ?? defaultValue
```

### 2. Array Index Out of Bounds
```swift
// ❌ WRONG
let item = array[index]  // Crashes if index invalid

// ✅ CORRECT
guard index >= 0 && index < array.count else { return }
let item = array[index]
// OR
let item = array.first  // Returns optional
```

### 3. Memory Leaks (Retain Cycles)
```swift
// ❌ WRONG
completionHandler = {
    self.doSomething()  // Retain cycle!
}

// ✅ CORRECT
completionHandler = { [weak self] in
    self?.doSomething()
}
```

### 4. Race Conditions
```swift
// ❌ WRONG
var shared = 0
queue.async { shared += 1 }  // Race condition!

// ✅ CORRECT
let queue = DispatchQueue(label: "serial")
queue.sync { shared += 1 }
// OR use actors (Swift 5.5+)
```

### 5. Type Casting Crashes
```swift
// ❌ WRONG
let dog = animal as! Dog  // Crashes if not a Dog

// ✅ CORRECT
if let dog = animal as? Dog {
    dog.fetch()
}
```

### 6. Infinite Loops
```swift
// ❌ WRONG
var i = 0
while i >= 0 {  // Never ends!
    i += 1
}

// ✅ CORRECT
for i in 0..<10 {  // Guaranteed to end
    print(i)
}
```

### 7. Dictionary Access
```swift
// ❌ WRONG
let value = dict["key"]!  // Crashes if key missing

// ✅ CORRECT
let value = dict["key"] ?? defaultValue
// OR
if let value = dict["key"] { }
```

### 8. String Manipulation
```swift
// ❌ WRONG
let char = string[0]  // Compile error!

// ✅ CORRECT
let char = string.first  // Optional
// OR
for char in string { }
```

### 9. Protocol Conformance
```swift
// ❌ WRONG
class MyClass: MyProtocol {
    // Missing required methods!
}

// ✅ CORRECT
class MyClass: MyProtocol {
    // Implement ALL required methods
    func requiredMethod() { }
}
```

### 10. Closure Captures
```swift
// ❌ WRONG (in loop)
for i in 0..<5 {
    closures.append({ print(i) })  // All capture same i
}

// ✅ CORRECT
for i in 0..<5 {
    closures.append({ [i] in print(i) })
}
```

---

## 🛠️ Essential Debugging Commands

### Xcode Debugger (LLDB)
```
po variable              # Print object description
p variable               # Print value
expr variable = 5        # Modify variable
bt                       # Backtrace (call stack)
frame variable           # Show local variables
thread list              # List all threads
continue                 # Resume execution
```

### Common Assertions
```swift
assert(condition, "Message")           // Debug only
precondition(condition, "Message")     // Always checked
fatalError("Message")                  // Always crashes
```

### Print Debugging
```swift
print("Value: \(value)")
debugPrint(object)
dump(object)  // Detailed structure
print(Thread.current)  // Current thread info
```

---

## ⚡ Quick Decision Trees

### When to use Optional handling?
- Use **if let** when you need the value in a scope
- Use **guard let** for early returns
- Use **??** when you have a good default value
- Use **optional chaining** for nested optionals

### Memory Management
- Use **weak** for delegates
- Use **weak** for parent references in child objects
- Use **weak** when object might be deallocated
- Use **unowned** only when 100% certain lifetime is safe

### Thread Safety
- Use **serial queue** for simple synchronization
- Use **NSLock** for fine-grained control
- Use **actors** for modern Swift (5.5+)
- Update UI only on **main thread**

### String Operations
- Use **.first/.last** instead of indices
- Use **prefix()/suffix()** for substrings
- Use **for char in string** to iterate
- Never treat strings as arrays

---

## 🎯 Interview Red Flags to Avoid

1. ❌ Force unwrapping optionals with `!`
2. ❌ Accessing arrays without bounds checking
3. ❌ Not using `[weak self]` in closures
4. ❌ Force casting with `as!`
5. ❌ Comparing floats with `==`
6. ❌ Updating UI from background threads
7. ❌ Infinite loops without safety limits
8. ❌ Ignoring compiler warnings
9. ❌ Not handling empty collections
10. ❌ Modifying collections while iterating

---

## ✅ Interview Green Flags

1. ✅ Always use safe optional unwrapping
2. ✅ Validate array bounds before access
3. ✅ Use `[weak self]` in escaping closures
4. ✅ Use optional casting with `as?`
5. ✅ Use tolerance for floating-point comparisons
6. ✅ Always use `DispatchQueue.main` for UI
7. ✅ Add max iteration limits in loops
8. ✅ Fix all compiler warnings
9. ✅ Check `isEmpty` before accessing collections
10. ✅ Use immutable copies when iterating

---

## 🔍 Debugging Workflow

1. **Read the error message carefully**
   - Compiler errors tell you exactly what's wrong
   - Runtime errors show the crash line

2. **Set a breakpoint**
   - Click line number in Xcode
   - Run in debug mode

3. **Inspect variables**
   - Hover over variables
   - Use `po` command in console

4. **Check assumptions**
   - Is the array empty?
   - Is the optional nil?
   - Is the index in bounds?

5. **Use print statements**
   - Print before and after the issue
   - Print variable values

6. **Enable debugging tools**
   - Thread Sanitizer (race conditions)
   - Address Sanitizer (memory issues)
   - Memory Graph Debugger (leaks)

---

## 📊 Time Complexity Quick Reference

```swift
// O(1) - Constant
array[0]
dict["key"]
array.first/last

// O(log n) - Logarithmic  
binarySearch()

// O(n) - Linear
array.contains()
array.filter()
array.map()

// O(n log n) - Log-linear
array.sorted()

// O(n²) - Quadratic
Nested loops over same array

// O(∞) - Infinite
Infinite loops (BUG!)
```

---

## 🎓 Key Swift Concepts for Interviews

### Value vs Reference Types
- **Value types**: struct, enum, tuple (copied)
- **Reference types**: class (shared reference)

### ARC (Automatic Reference Counting)
- Strong references keep objects alive
- Weak references don't prevent deallocation
- Unowned assumes object exists

### Optionals
- Optional<T> is an enum: .some(value) or .none
- `?` creates optional
- `!` force unwraps (dangerous)
- `??` provides default value

### Protocols
- Define interface/contract
- Classes, structs, enums can conform
- Can have associated types
- Extensions can provide default implementations

### Closures
- Capture variables from surrounding scope
- Can escape function scope
- Can create retain cycles
- Are reference types

---

## 💡 Pro Tips

1. **Enable all warnings**: Build Settings → "Treat Warnings as Errors"
2. **Use SwiftLint**: Enforce code style and catch common issues
3. **Write tests**: Unit tests catch bugs early
4. **Code review**: Fresh eyes catch what you miss
5. **Use git**: Commit often, you can always revert
6. **Read documentation**: Apple's Swift book is excellent
7. **Practice daily**: Do one LeetCode/HackerRank problem
8. **Understand, don't memorize**: Know *why*, not just *what*
9. **Ask "what if?"**: Empty array? Nil value? Edge cases?
10. **Stay current**: Swift evolves, learn new features

---

## 🚀 Next Steps for Interview Prep

1. ✅ Complete all 10 examples in this repo
2. ✅ Run each example in a Swift playground
3. ✅ Try to fix bugs before reading solutions
4. ✅ Understand every line of code
5. ✅ Practice explaining concepts out loud
6. ✅ Write your own buggy code and fix it
7. ✅ Review Swift language guide
8. ✅ Practice on coding platforms
9. ✅ Build a small project applying these concepts
10. ✅ Mock interview with a friend

---

## 📚 Recommended Resources

- **Swift.org**: Official language documentation
- **Apple Developer**: WWDC videos and guides
- **Ray Wenderlich**: iOS tutorials
- **Hacking with Swift**: 100 Days of Swift
- **LeetCode**: Algorithm practice
- **Cracking the Coding Interview**: General prep

---

**Good luck with your Apple interview! 🍎**

*Remember: The best debuggers are those who write code that doesn't need debugging!*
