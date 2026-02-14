# Debugging Value vs Reference Issues

## 🔧 Quick Checks

### Test if Value or Reference
```swift
var a = myType
var b = a
b.modify()

// If a changed: reference type
// If a unchanged: value type
```

### Print Object Identity (Classes)
```swift
print(ObjectIdentifier(obj1) == ObjectIdentifier(obj2))
// or
print(obj1 === obj2)  // Reference equality
```

### Check Copies
```swift
// Struct: new memory
let s1 = MyStruct()
let s2 = s1
// s1 and s2 are separate

// Class: same memory
let c1 = MyClass()
let c2 = c1
// c1 and c2 point to same object
```

## 💡 Common Fixes

1. **Struct not mutating**: Use `inout` parameter
2. **Class copying too much**: Use reference semantics
3. **Unexpected mutations**: Check if reference type
4. **Constant can't mutate**: Use `var` not `let` for structs
