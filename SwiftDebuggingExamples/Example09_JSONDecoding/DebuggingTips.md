# Debugging JSON Decoding

## 🔧 Quick Debugging

### Print JSON Structure
```swift
if let json = try? JSONSerialization.jsonObject(with: data) {
    print("JSON: \(json)")
}
```

### Catch Specific Errors
```swift
do {
    let user = try decoder.decode(User.self, from: data)
} catch DecodingError.keyNotFound(let key, let context) {
    print("Missing: \(key.stringValue)")
    print("Path: \(context.codingPath)")
} catch DecodingError.typeMismatch(_, let context) {
    print("Type error at: \(context.codingPath)")
    print("Expected: \(context.debugDescription)")
}
```

### Test with Sample JSON
```swift
let sampleJSON = """
{
    "key": "value"
}
"""

let data = sampleJSON.data(using: .utf8)!
```

## 💡 Common Fixes

1. **Key not found**: Check CodingKeys or make optional
2. **Type mismatch**: Check JSON value types
3. **Date parsing**: Set dateDecodingStrategy
4. **Snake case**: Use convertFromSnakeCase
5. **Missing field**: Make property optional
