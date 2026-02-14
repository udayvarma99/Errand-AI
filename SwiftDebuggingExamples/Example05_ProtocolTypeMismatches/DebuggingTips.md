# Debugging Protocol and Type Issues

## 🔧 Quick Debugging

### Check Type at Runtime
```swift
print("Type: \(type(of: value))")
print("Is String: \(value is String)")

if let string = value as? String {
    print("Successfully cast to String")
}
```

### LLDB Commands
```
(lldb) po type(of: myObject)
(lldb) po myObject is MyProtocol
(lldb) expr -d run -- type(of: myObject)
```

### Breakpoint on Cast Failures
Set symbolic breakpoint on:
- `swift_dynamicCastFailure`
- `_swift_dynamicCastClassUnconditional`

## 🚨 Common Errors

### Error: "Cannot convert value"
**Fix:** Add type annotation or cast
```swift
let value: Any = "Hello"
let string = value as? String  // ✅
```

### Error: "Type does not conform to protocol"
**Fix:** Implement all required methods/properties
```swift
protocol MyProtocol {
    func required()
}

class MyClass: MyProtocol {
    func required() { }  // ✅ Must implement
}
```

### Error: "Protocol can only be used as generic constraint"
**Fix:** Use type erasure or opaque types
```swift
// ❌ let x: Container = ...
// ✅ let x: some Container = ...
// ✅ let x: AnyContainer<Int> = ...
```

## 💡 Prevention

1. **Enable strict type checking** in build settings
2. **Use compiler warnings** as errors
3. **Write type-specific tests**
4. **Use protocol witnesses** for testing
5. **Document type assumptions**
