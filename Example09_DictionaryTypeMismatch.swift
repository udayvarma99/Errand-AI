/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 9: DICTIONARY TYPE MISMATCH AND CASTING
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Type Safety, Casting, and JSON Parsing
 Common In: 80% of Swift interviews
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - FORCE CASTING AND TYPE MISMATCHES
// ═══════════════════════════════════════════════════════════════

class JSONParserBuggy {
    func parseUserData(json: [String: Any]) -> String {
        // 🐛 BUG: Force casting can crash
        let name = json["name"] as! String  // Crashes if not String or nil
        let age = json["age"] as! Int       // Crashes if not Int
        
        return "\(name) is \(age) years old"
    }
    
    func parseArray(json: [String: Any]) -> [String] {
        // 🐛 BUG: Force unwrap + force cast = double danger
        let items = json["items"]! as! [String]  // Double crash potential!
        return items
    }
    
    func parseNestedData(json: [String: Any]) -> String {
        // 🐛 BUG: No type checking for nested dictionaries
        let user = json["user"] as! [String: Any]
        let address = user["address"] as! [String: Any]
        let city = address["city"] as! String
        
        return city
    }
}

/*
 CRASH SCENARIOS:
 1. json["name"] is nil → crash
 2. json["name"] is Int instead of String → crash
 3. json["items"] is nil → crash on !
 4. json["items"] is [Int] instead of [String] → crash on as!
 5. Any level of nesting is wrong → crash
*/


// ❌ BUGGY CODE - TYPE INFERENCE ISSUES
// ═══════════════════════════════════════════════════════════════

class DataProcessorBuggy {
    func processData() {
        // 🐛 BUG: Type mismatch in dictionary
        var userData: [String: String] = [:]
        userData["name"] = "Alice"
        userData["age"] = "30"  // Works
        // userData["score"] = 100  // ⚠️ Won't compile - Int, not String
    }
    
    func mixedTypeData() {
        // Using Any loses type safety
        var data: [String: Any] = [:]
        data["name"] = "Bob"
        data["age"] = 25
        
        // 🐛 BUG: Need to cast everything back
        let name = data["name"]  // Type is Any?, not String
        // let uppercased = name.uppercased()  // ⚠️ Won't compile
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. FORCE CASTING (as!):
    - Crashes if type doesn't match
    - No recovery possible
    - Common in JSON parsing gone wrong
 
 2. FORCE UNWRAPPING (!):
    - Crashes if key doesn't exist
    - Doesn't help with type safety
    - Should use optional binding
 
 3. ANY TYPE:
    - Loses type information
    - Requires casting to use
    - Should use Codable instead
 
 4. NO ERROR HANDLING:
    - Can't recover from parsing errors
    - App crashes instead of showing error
    - No way to provide feedback
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Optional Binding + Conditional Casting
// ═══════════════════════════════════════════════════════════════

class JSONParserFixed1 {
    func parseUserData(json: [String: Any]) -> String? {
        // ✅ Safe optional binding with as?
        guard let name = json["name"] as? String,
              let age = json["age"] as? Int else {
            print("Invalid JSON format")
            return nil
        }
        
        return "\(name) is \(age) years old"
    }
    
    func parseArray(json: [String: Any]) -> [String]? {
        // ✅ Conditional cast returns optional
        guard let items = json["items"] as? [String] else {
            print("Items not found or wrong type")
            return nil
        }
        
        return items
    }
    
    func parseNestedData(json: [String: Any]) -> String? {
        // ✅ Safe chaining of optional casts
        guard let user = json["user"] as? [String: Any],
              let address = user["address"] as? [String: Any],
              let city = address["city"] as? String else {
            return nil
        }
        
        return city
    }
    
    // ✅ Provide default values
    func parseWithDefaults(json: [String: Any]) -> (String, Int) {
        let name = json["name"] as? String ?? "Unknown"
        let age = json["age"] as? Int ?? 0
        
        return (name, age)
    }
}


// ✅ FIXED CODE - SOLUTION 2: Codable (Best Practice)
// ═══════════════════════════════════════════════════════════════

struct User: Codable {
    let name: String
    let age: Int
    let email: String?  // Optional field
    let address: Address?
    
    struct Address: Codable {
        let street: String
        let city: String
        let zipCode: String
        
        enum CodingKeys: String, CodingKey {
            case street
            case city
            case zipCode = "zip_code"  // Map to different JSON key
        }
    }
}

class JSONParserFixed2 {
    func parseUser(jsonData: Data) -> User? {
        let decoder = JSONDecoder()
        
        do {
            let user = try decoder.decode(User.self, from: jsonData)
            return user
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
    
    func parseUsers(jsonData: Data) -> [User]? {
        let decoder = JSONDecoder()
        
        do {
            let users = try decoder.decode([User].self, from: jsonData)
            return users
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}


// ✅ FIXED CODE - SOLUTION 3: Type-Safe Dictionary Access
// ═══════════════════════════════════════════════════════════════

extension Dictionary where Key == String, Value == Any {
    func string(forKey key: String) -> String? {
        return self[key] as? String
    }
    
    func int(forKey key: String) -> Int? {
        return self[key] as? Int
    }
    
    func double(forKey key: String) -> Double? {
        // ✅ Also try to convert from Int
        if let value = self[key] as? Double {
            return value
        }
        if let value = self[key] as? Int {
            return Double(value)
        }
        return nil
    }
    
    func bool(forKey key: String) -> Bool? {
        return self[key] as? Bool
    }
    
    func array<T>(forKey key: String) -> [T]? {
        return self[key] as? [T]
    }
    
    func dictionary(forKey key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}

class JSONParserFixed3 {
    func parseUserData(json: [String: Any]) -> String? {
        // ✅ Use type-safe extensions
        guard let name = json.string(forKey: "name"),
              let age = json.int(forKey: "age") else {
            return nil
        }
        
        return "\(name) is \(age) years old"
    }
    
    func parseNestedData(json: [String: Any]) -> String? {
        guard let user = json.dictionary(forKey: "user"),
              let address = user.dictionary(forKey: "address"),
              let city = address.string(forKey: "city") else {
            return nil
        }
        
        return city
    }
}


// ✅ ADVANCED: Custom Decoding Logic
// ═══════════════════════════════════════════════════════════════

struct Product: Codable {
    let id: Int
    let name: String
    let price: Double
    let inStock: Bool
    let tags: [String]
    
    // ✅ Custom decoding to handle different formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // ✅ Handle price as String or Double
        if let priceDouble = try? container.decode(Double.self, forKey: .price) {
            price = priceDouble
        } else if let priceString = try? container.decode(String.self, forKey: .price),
                  let priceDouble = Double(priceString) {
            price = priceDouble
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .price,
                in: container,
                debugDescription: "Price must be Double or String"
            )
        }
        
        // ✅ Handle bool as Int or Bool
        if let boolValue = try? container.decode(Bool.self, forKey: .inStock) {
            inStock = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .inStock) {
            inStock = intValue != 0
        } else {
            inStock = false  // Default value
        }
        
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}


// ✅ ADVANCED: Result Type for Error Handling
// ═══════════════════════════════════════════════════════════════

enum ParseError: Error {
    case missingField(String)
    case invalidType(String)
    case decodingFailed(Error)
}

class JSONParserAdvanced {
    func parseUser(jsonData: Data) -> Result<User, ParseError> {
        let decoder = JSONDecoder()
        
        do {
            let user = try decoder.decode(User.self, from: jsonData)
            return .success(user)
        } catch {
            return .failure(.decodingFailed(error))
        }
    }
    
    func parseUserData(json: [String: Any]) -> Result<(String, Int), ParseError> {
        guard let name = json["name"] as? String else {
            return .failure(.missingField("name"))
        }
        
        guard let age = json["age"] as? Int else {
            return .failure(.invalidType("age must be Int"))
        }
        
        return .success((name, age))
    }
}


// ✅ REAL-WORLD EXAMPLE: API Response Parser
// ═══════════════════════════════════════════════════════════════

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case error
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        success = try container.decode(Bool.self, forKey: .success)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        error = try container.decodeIfPresent(String.self, forKey: .error)
        
        // ✅ Handle timestamp as Unix timestamp or ISO8601
        if let timestamp = try? container.decode(Date.self, forKey: .timestamp) {
            self.timestamp = timestamp
        } else if let timestampInt = try? container.decode(Int.self, forKey: .timestamp) {
            self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestampInt))
        } else if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            self.timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            self.timestamp = Date()
        }
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. NEVER USE as! (force cast):
    - Use as? (conditional cast) instead
    - Returns optional - safe to unwrap
    - Won't crash on type mismatch
 
 2. DICTIONARY ACCESS:
    - Subscript returns Optional
    - Use as? for type casting
    - Combine with guard let or if let
 
 3. PREFER CODABLE:
    - Type-safe by default
    - Compiler-generated implementations
    - Better error handling
    - Industry standard
 
 4. ERROR HANDLING:
    - Return Optional for simple cases
    - Return Result<T, Error> for detailed errors
    - Throw errors for exceptional cases
    - Never crash on bad data
 
 5. TYPE CONVERSIONS:
    - Int to Double: Explicit conversion
    - String to Int: Use Int(string)
    - Bool from Int: Manual conversion
    - Handle multiple formats in custom decoders
 
 6. JSON BEST PRACTICES:
    - Use Codable, not [String: Any]
    - Handle optional fields explicitly
    - Map JSON keys with CodingKeys
    - Custom decoders for complex logic
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "I see force casting with as! which will crash if the type doesn't match. 
    I'd use as? for conditional casting."
 
 2. "For JSON parsing, I'd use Codable instead of [String: Any] - it's 
    type-safe and handles errors better."
 
 3. "I'd use guard-let to unwrap the optional and cast in one step, with 
    early return if parsing fails."
 
 4. "For production code, I'd return a Result type or throw errors instead 
    of returning optionals, so the caller knows what went wrong."
 
 5. "I'd write unit tests with malformed JSON to ensure the parser handles 
    errors gracefully."
 
 BONUS POINTS:
 ✅ Discuss Codable vs manual parsing
 ✅ Mention JSONEncoder/JSONDecoder
 ✅ Know about CodingKeys for custom mapping
 ✅ Understand custom encode/decode methods
 ✅ Discuss date/data decoding strategies
 
 EXAMPLE:
 ```swift
 decoder.dateDecodingStrategy = .iso8601
 decoder.keyDecodingStrategy = .convertFromSnakeCase
 ```
 
 RED FLAGS:
 ❌ Using as! without justification
 ❌ Not knowing about Codable
 ❌ Returning nil without logging errors
 ❌ Using Any everywhere
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What's the difference between as, as?, and as!?"
 A: "as is for upcasting and compile-time conversions. as? is conditional 
     casting that returns optional. as! is force casting that crashes on 
     failure - avoid it."
 
 Q: "How do you handle missing fields in JSON?"
 A: "Make the property optional in the Codable struct, or use 
     decodeIfPresent in a custom decoder, or provide a default value."
 
 Q: "When would you use manual parsing instead of Codable?"
 A: "When the JSON structure is very dynamic, has inconsistent types, or 
     requires complex transformation logic that's easier to do manually."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample9() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 9: DICTIONARY TYPE MISMATCH")
    print("═══════════════════════════════════════════════════════\n")
    
    let validJSON: [String: Any] = [
        "name": "Alice",
        "age": 30,
        "email": "alice@example.com"
    ]
    
    let invalidJSON: [String: Any] = [
        "name": 123,  // Wrong type!
        "age": "thirty"  // Wrong type!
    ]
    
    print("❌ BUGGY VERSION with valid JSON:")
    let buggyParser = JSONParserBuggy()
    print(buggyParser.parseUserData(json: validJSON))
    
    print("\n❌ BUGGY VERSION with invalid JSON:")
    // buggyParser.parseUserData(json: invalidJSON)  // ⚠️ CRASHES! Commented out
    print("(Would crash - commented out)\n")
    
    print("✅ FIXED VERSION 1 (Optional binding):")
    let parser1 = JSONParserFixed1()
    if let result = parser1.parseUserData(json: validJSON) {
        print(result)
    }
    if let result = parser1.parseUserData(json: invalidJSON) {
        print(result)
    } else {
        print("Failed to parse invalid JSON")
    }
    print()
    
    print("✅ FIXED VERSION 1 (With defaults):")
    let (name, age) = parser1.parseWithDefaults(json: invalidJSON)
    print("Name: \(name), Age: \(age)")
    print()
    
    print("✅ FIXED VERSION 2 (Codable):")
    let jsonString = """
    {
        "name": "Bob",
        "age": 25,
        "email": "bob@example.com",
        "address": {
            "street": "123 Main St",
            "city": "San Francisco",
            "zip_code": "94102"
        }
    }
    """
    
    if let jsonData = jsonString.data(using: .utf8) {
        let parser2 = JSONParserFixed2()
        if let user = parser2.parseUser(jsonData: jsonData) {
            print("Parsed user: \(user.name), age \(user.age)")
            if let address = user.address {
                print("City: \(address.city)")
            }
        }
    }
    print()
    
    print("✅ FIXED VERSION 3 (Type-safe extensions):")
    let parser3 = JSONParserFixed3()
    if let result = parser3.parseUserData(json: validJSON) {
        print(result)
    }
    print()
    
    print("✅ ADVANCED (Result type):")
    let advancedParser = JSONParserAdvanced()
    let result = advancedParser.parseUserData(json: invalidJSON)
    
    switch result {
    case .success(let (name, age)):
        print("Success: \(name), \(age)")
    case .failure(let error):
        print("Error: \(error)")
    }
    print()
}

// Uncomment to run:
// runExample9()
