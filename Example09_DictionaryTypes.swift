/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 9: DICTIONARY TYPE MISMATCHES
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Working with dictionary optionals and JSON
 Common Interview Question: "How do you safely parse JSON in Swift?"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Force unwrapping dictionary values

struct UserProfileBuggy {
    var name: String
    var age: Int
    var email: String
    
    init?(from dict: [String: Any]) {
        // 🐛 BUG: Force unwrapping can crash!
        self.name = dict["name"] as! String  // 💥 Crash if missing or wrong type
        self.age = dict["age"] as! Int       // 💥 Crash if age is String "25"
        self.email = dict["email"] as! String
    }
}


// Scenario 2: Nested dictionary access

func parseNestedDictBuggy(_ json: [String: Any]) {
    // 🐛 BUG: Multiple force unwraps
    let user = json["user"] as! [String: Any]  // 💥 Crash if missing
    let address = user["address"] as! [String: Any]  // 💥 Crash if missing
    let street = address["street"] as! String  // 💥 Crash if missing
    
    print("Street: \(street)")
}


// Scenario 3: Number type confusion in JSON

func parseJSONNumberBuggy(_ json: [String: Any]) {
    // 🐛 BUG: JSON numbers might be Double or Int
    let count = json["count"] as! Int  // 💥 Crash if JSON has 5.0 (Double)
    print("Count: \(count)")
}


// Scenario 4: Missing keys

func getUsernameBuggy(_ user: [String: String]) -> String {
    // 🐛 BUG: Force unwrapping optional value
    return user["username"]!  // 💥 Crash if key doesn't exist
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Dictionary subscript returns OPTIONAL because:
 1. Key might not exist
 2. Value might be wrong type (with [String: Any])
 
 Common issues:
 - Force unwrapping: dict["key"]! → crashes if missing
 - Force casting: dict["key"] as! String → crashes if wrong type
 - Not checking for nil values in JSON
 - Number type mismatches (Int vs Double)
 - Nested dictionary access without safety
 - Not handling missing keys gracefully
 
 JSON specifics:
 - All numbers are NSNumber in Foundation (can be Int or Double)
 - Null maps to NSNull, not nil
 - Nested structures need careful unwrapping
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Remember: dictionary["key"] returns Optional
 2. Use if let or guard let for safe unwrapping
 3. Check JSON structure before parsing
 4. Print dictionary contents for debugging
 5. Use Codable instead of manual parsing
 
 Debugging tips:
 - print(dict) to see all keys and values
 - dict.keys to see available keys
 - type(of: dict["key"]) to check value type
 - Use online JSON validators
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Safe unwrapping with guard let

struct UserProfileFixed {
    var name: String
    var age: Int
    var email: String
    
    init?(from dict: [String: Any]) {
        // ✅ Safe unwrapping with guard
        guard let name = dict["name"] as? String,
              let age = dict["age"] as? Int,
              let email = dict["email"] as? String else {
            print("⚠️ Missing or invalid required fields")
            return nil
        }
        
        self.name = name
        self.age = age
        self.email = email
    }
}


// SOLUTION 2: Optional chaining for nested dictionaries

func parseNestedDictFixed(_ json: [String: Any]) {
    // ✅ Safe nested access with optional chaining
    if let user = json["user"] as? [String: Any],
       let address = user["address"] as? [String: Any],
       let street = address["street"] as? String {
        print("Street: \(street)")
    } else {
        print("⚠️ Could not parse address")
    }
}


// SOLUTION 3: Handling number types from JSON

func parseJSONNumberFixed(_ json: [String: Any]) {
    // ✅ Handle both Int and Double
    if let count = json["count"] as? Int {
        print("Count (Int): \(count)")
    } else if let countDouble = json["count"] as? Double {
        print("Count (Double): \(Int(countDouble))")
    } else {
        print("⚠️ Count not found or wrong type")
    }
}

// Better: Use NSNumber
func parseJSONNumberBetter(_ json: [String: Any]) {
    // ✅ NSNumber handles both Int and Double
    if let countNumber = json["count"] as? NSNumber {
        let count = countNumber.intValue
        print("Count: \(count)")
    }
}


// SOLUTION 4: Nil coalescing for missing keys

func getUsernameFixed(_ user: [String: String]) -> String {
    // ✅ Provide default value
    return user["username"] ?? "Anonymous"
}


// SOLUTION 5: Using Codable (BEST PRACTICE)

struct User: Codable {
    var name: String
    var age: Int
    var email: String
    var address: Address?  // Optional nested type
    
    struct Address: Codable {
        var street: String
        var city: String
        var zipCode: String
        
        enum CodingKeys: String, CodingKey {
            case street
            case city
            case zipCode = "zip_code"  // Map snake_case to camelCase
        }
    }
}

func parseJSONWithCodable(_ jsonData: Data) {
    do {
        // ✅ BEST: Let Codable handle parsing
        let user = try JSONDecoder().decode(User.self, from: jsonData)
        print("User: \(user.name), Age: \(user.age)")
        
        if let address = user.address {
            print("Lives at: \(address.street), \(address.city)")
        }
    } catch {
        print("⚠️ Decoding error: \(error)")
    }
}


// SOLUTION 6: Custom decoding for complex scenarios

struct Product: Decodable {
    var id: String
    var name: String
    var price: Double
    var inStock: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, price
        case inStock = "in_stock"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        
        // ✅ Handle missing key with default value
        inStock = try container.decodeIfPresent(Bool.self, forKey: .inStock) ?? true
    }
}


// SOLUTION 7: Safe dictionary access helper

extension Dictionary {
    // ✅ Generic safe getter
    func getValue<T>(for key: Key, as type: T.Type) -> T? {
        return self[key] as? T
    }
    
    // ✅ With default value
    func getValue<T>(for key: Key, as type: T.Type, default defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
}


// SOLUTION 8: Validating dictionary structure

func validateUserDict(_ dict: [String: Any]) -> Bool {
    let requiredKeys: Set<String> = ["name", "age", "email"]
    let dictKeys = Set(dict.keys)
    
    // ✅ Check all required keys exist
    guard requiredKeys.isSubset(of: dictKeys) else {
        let missing = requiredKeys.subtracting(dictKeys)
        print("⚠️ Missing required keys: \(missing)")
        return false
    }
    
    // ✅ Validate types
    guard dict["name"] is String,
          dict["age"] is Int,
          dict["email"] is String else {
        print("⚠️ Invalid types for fields")
        return false
    }
    
    return true
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample09() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 9: DICTIONARY TYPE MISMATCHES")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Valid dictionary
    print("Test Case 1: Valid User Dictionary")
    let validDict: [String: Any] = [
        "name": "Alice",
        "age": 25,
        "email": "alice@example.com"
    ]
    
    if let user = UserProfileFixed(from: validDict) {
        print("✅ User: \(user.name), Age: \(user.age)")
    } else {
        print("❌ Failed to parse user")
    }
    print()
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Invalid dictionary (missing key)
    print("Test Case 2: Invalid Dictionary (Missing Email)")
    let invalidDict: [String: Any] = [
        "name": "Bob",
        "age": 30
        // Missing email
    ]
    
    if let user = UserProfileFixed(from: invalidDict) {
        print("User: \(user.name)")
    } else {
        print("✅ Correctly rejected invalid data")
    }
    print()
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Nested dictionary
    print("Test Case 3: Nested Dictionary")
    let nestedDict: [String: Any] = [
        "user": [
            "address": [
                "street": "123 Main St"
            ]
        ]
    ]
    
    parseNestedDictFixed(nestedDict)
    print()
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Number type handling
    print("Test Case 4: Number Type Handling")
    let numberDict1: [String: Any] = ["count": 42]
    let numberDict2: [String: Any] = ["count": 42.0]
    
    parseJSONNumberFixed(numberDict1)
    parseJSONNumberFixed(numberDict2)
    print()
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 5: Codable parsing
    print("Test Case 5: Codable JSON Parsing")
    let jsonString = """
    {
        "name": "Charlie",
        "age": 28,
        "email": "charlie@example.com",
        "address": {
            "street": "456 Oak Ave",
            "city": "San Francisco",
            "zip_code": "94102"
        }
    }
    """
    
    if let jsonData = jsonString.data(using: .utf8) {
        parseJSONWithCodable(jsonData)
    }
    print()
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 6: Dictionary validation
    print("Test Case 6: Dictionary Validation")
    let testDict: [String: Any] = [
        "name": "David",
        "age": "not a number",  // Wrong type!
        "email": "david@example.com"
    ]
    
    let isValid = validateUserDict(testDict)
    print("Dictionary valid: \(isValid ? "✅" : "❌")")
    print()
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Dictionary subscript ALWAYS returns Optional:
    - dict["key"] → Value? (might be nil)
    - Must unwrap safely with if let, guard let, or ??
 
 2. Type casting with dictionaries:
    - dict["key"] as? Type (safe, returns nil if wrong type)
    - dict["key"] as! Type (unsafe, crashes if wrong type)
    - NEVER use as! unless absolutely certain
 
 3. JSON parsing:
    - Prefer Codable over manual dictionary parsing
    - Use JSONDecoder for automatic parsing
    - Handle optional fields with decodeIfPresent
    - Use CodingKeys for name mapping
 
 4. Number types in JSON:
    - JSON numbers can be Int or Double
    - Use NSNumber for compatibility
    - Or check both types explicitly
 
 5. Nested dictionaries:
    - Chain optional unwrapping with 'if let'
    - Each level might be missing or wrong type
    - Consider Codable for nested structures
 
 6. Best practices:
    - Use Codable instead of [String: Any]
    - Validate required keys before parsing
    - Provide default values for optional fields
    - Use guard let for early exit
    - Create helper methods for common patterns
 
 7. Error handling:
    - Return nil for invalid data (failable init)
    - Use Result type for detailed errors
    - Log parsing errors for debugging
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "Why does dictionary subscript return an Optional?"
 A1: Because the key might not exist in the dictionary. This prevents
     crashes from accessing missing keys and enforces safe handling.
 
 Q2: "What's the difference between Encodable and Decodable?"
 A2: Encodable converts Swift types to external representations (JSON).
     Decodable converts external data to Swift types. Codable is a
     typealias combining both: Encodable & Decodable.
 
 Q3: "How do you handle optional fields in Codable?"
 A3: Make the property Optional (Type?) in the struct. Use
     decodeIfPresent() for custom decoding. Decoder automatically
     handles missing keys for optional properties.
 
 Q4: "What's CodingKeys used for?"
 A4: To map between Swift property names and JSON keys. Useful for
     converting snake_case JSON to camelCase Swift properties, or
     when JSON keys differ from property names.
 
 Q5: "How do you parse heterogeneous JSON arrays?"
 A5: Use [Any] or create a wrapper enum that conforms to Codable with
     custom decoding logic. Or use separate Decodable types and try
     decoding each type until one succeeds.
 
 Q6: "What's the difference between decode and decodeIfPresent?"
 A6: decode throws an error if the key is missing or value is null.
     decodeIfPresent returns nil for missing or null values without
     throwing. Use for optional fields.
*/


// 💡 ADVANCED: JSON Parsing Patterns
// ═══════════════════════════════════════════════════════════════════

// Pattern 1: Custom date parsing
struct Event: Codable {
    var name: String
    var date: Date
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func decode(from jsonData: Data) throws -> Event {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode(Event.self, from: jsonData)
    }
}


// Pattern 2: Polymorphic JSON (different types in array)
enum APIResponse: Codable {
    case user(User)
    case error(ErrorResponse)
    
    struct ErrorResponse: Codable {
        var message: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let user = try? container.decode(User.self) {
            self = .user(user)
        } else if let error = try? container.decode(ErrorResponse.self) {
            self = .error(error)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath,
                                    debugDescription: "Invalid response")
            )
        }
    }
}


// Pattern 3: Result type for parsing
func parseUser(from json: [String: Any]) -> Result<UserProfileFixed, ParseError> {
    guard let user = UserProfileFixed(from: json) else {
        return .failure(.invalidData)
    }
    return .success(user)
}

enum ParseError: Error {
    case invalidData
    case missingKey(String)
    case wrongType(String)
}


// Uncomment to run:
// runExample09()
