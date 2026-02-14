# Example 9: JSON Decoding Failures

## 🐛 The Problem

Codable decoding fails with errors like:
- `keyNotFound`: JSON key doesn't match property name
- `typeMismatch`: JSON value type differs from property type
- `valueNotFound`: Required field missing in JSON
- `dataCorrupted`: Invalid data format (dates, enums)

## ✅ Key Solutions

### 1. Custom CodingKeys
```swift
struct User: Codable {
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case email = "emailAddress"  // JSON key
    }
}
```

### 2. Snake Case Conversion
```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
// user_id → userId
```

### 3. Optional Fields
```swift
struct Profile: Codable {
    let name: String
    let bio: String?  // ✅ Can be missing
}
```

### 4. Date Strategies
```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
// or
decoder.dateDecodingStrategy = .formatted(customFormatter)
```

### 5. Custom Decoding
```swift
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // Custom logic here
}
```

### 6. Proper Error Handling
```swift
do {
    let user = try decoder.decode(User.self, from: data)
} catch DecodingError.keyNotFound(let key, _) {
    print("Missing key: \(key)")
} catch DecodingError.typeMismatch(let type, _) {
    print("Type mismatch: \(type)")
} catch {
    print("Error: \(error)")
}
```

## 📚 Key Takeaways

1. **Use CodingKeys** for key mismatches
2. **Make fields optional** when they might be missing
3. **Set date strategy** for date parsing
4. **Handle type mismatches** with custom init
5. **Use convertFromSnakeCase** for APIs
6. **Never use try!** for decoding
7. **Provide defaults** or optionals
8. **Test with actual API** responses
