# Example 1: Optional Unwrapping Crashes

## 🐛 The Problem

Force unwrapping optionals is one of the most common causes of crashes in Swift. The crash message you'll see is:

```
Fatal error: Unexpectedly found nil while unwrapping an Optional value
```

## 🔍 Common Patterns That Cause Crashes

### 1. Force Unwrapping with `!`
```swift
let name = currentUser!.name!  // 💥 Crashes if either is nil
```

### 2. Force Casting with `as!`
```swift
let age = userDict["age"] as! Int  // 💥 Crashes if key missing or wrong type
```

### 3. Force Try with `try!`
```swift
let json = try! JSONSerialization.jsonObject(...)  // 💥 Crashes on error
```

### 4. Implicitly Unwrapped Optionals
```swift
var data: String!
print(data)  // 💥 Crashes if never assigned
```

## ✅ The Solutions

### 1. Optional Binding with `if let`
Use when you want to handle both the success and nil cases:

```swift
if let user = currentUser, let name = user.name {
    print("Name: \(name)")
} else {
    print("Name not available")
}
```

### 2. Guard Statements with `guard let`
Use for early exit when nil is not acceptable:

```swift
guard let user = currentUser, let name = user.name else {
    print("Missing required data")
    return
}
// Continue with unwrapped values
print("Name: \(name)")
```

### 3. Optional Chaining with `?`
Safely access nested optionals:

```swift
let city = currentUser?.address?.city  // Returns nil if any part is nil
```

### 4. Nil Coalescing Operator `??`
Provide a default value:

```swift
let name = currentUser?.name ?? "Guest"
```

### 5. Conditional Casting with `as?`
Safe type casting:

```swift
if let age = userDict["age"] as? Int {
    print("Age: \(age)")
}
```

### 6. Proper Error Handling with `do-catch`
Instead of `try!`, use proper error handling:

```swift
do {
    let json = try JSONSerialization.jsonObject(with: data)
} catch {
    print("Error: \(error)")
}
```

## 📊 When to Use Each Approach

| Scenario | Use | Example |
|----------|-----|---------|
| Need to handle nil case | `if let` | User input validation |
| Nil means method can't continue | `guard let` | Required parameters |
| Chain of optionals | Optional chaining `?` | Nested object access |
| Want a fallback value | `??` | Default configurations |
| Type casting | `as?` | Working with Any |
| Can handle errors | `do-catch` | File I/O, networking |

## 🎯 Interview Tips

1. **Never use `!` unless you're 100% certain** the value exists
2. **Prefer `guard let` for required values** - makes intent clear
3. **Use `if let` for optional operations** - when nil is acceptable
4. **Optional chaining is cleaner** than nested if-lets
5. **Consider using `Result` type** for operations that can fail

## 🚨 Red Flags in Code Reviews

- Multiple `!` in a row: `user!.profile!.name!`
- `try!` in production code
- Implicitly unwrapped optionals without clear justification
- No nil checks before force unwrapping
- Force casting without checking type first

## 💪 Practice Exercise

Try fixing this code:

```swift
func processUser(_ userData: [String: Any]) {
    let name = userData["name"] as! String
    let age = userData["age"] as! Int
    let email = userData["email"] as! String
    
    print("\(name) is \(age) years old. Email: \(email)")
}
```

**Answer:**

```swift
func processUser(_ userData: [String: Any]) {
    guard let name = userData["name"] as? String,
          let age = userData["age"] as? Int else {
        print("Missing required user data")
        return
    }
    
    let email = userData["email"] as? String ?? "No email provided"
    print("\(name) is \(age) years old. Email: \(email)")
}
```
