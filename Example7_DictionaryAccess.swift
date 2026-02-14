/*
 ============================================
 EXAMPLE 7: DICTIONARY ACCESS CRASHES
 ============================================
 
 Common Issue: Unsafe dictionary key access and type assumptions
 Apple Interview Focus: Safe collection handling, optionals
 */

import Foundation

// ❌ BUGGY CODE - Dictionary Access Issues!

class BuggyDictionaryHandler {
    
    func processUserData() {
        let userData: [String: String] = [
            "name": "Alice",
            "email": "alice@apple.com"
        ]
        
        // 🐛 BUG: Force unwrapping dictionary access
        let name = userData["name"]!      // Crashes if key doesn't exist
        let email = userData["email"]!
        let phone = userData["phone"]!    // 💥 CRASH: key doesn't exist!
        
        print("\(name), \(email), \(phone)")
    }
    
    func parseJSON() {
        let json: [String: Any] = [
            "user": [
                "name": "Bob",
                "age": 30
            ]
        ]
        
        // 🐛 BUG: Nested force unwrapping
        let user = json["user"] as! [String: Any]
        let name = user["name"] as! String
        let address = user["address"] as! String  // 💥 CRASH: key missing!
        
        print("\(name) lives at \(address)")
    }
    
    func updateCounter() {
        var counts: [String: Int] = ["apple": 5, "banana": 3]
        
        // 🐛 BUG: Assuming key exists before incrementing
        counts["orange"] = counts["orange"]! + 1  // 💥 CRASH: nil!
    }
    
    func iterateAssumingValues() {
        let scores: [String: Int?] = [
            "Alice": 95,
            "Bob": nil,  // No score yet
            "Charlie": 87
        ]
        
        // 🐛 BUG: Not handling optional values in dictionary
        for (name, score) in scores {
            print("\(name): \(score! + 10)")  // 💥 CRASH on Bob!
        }
    }
}

// Example of the crashes:
func demonstrateBug() {
    print("=== DICTIONARY ACCESS BUGS ===\n")
    print("⚠️  Crashes prevented by commenting out buggy code\n")
    
    // let handler = BuggyDictionaryHandler()
    // handler.processUserData()  // 💥 CRASH!
    // handler.parseJSON()        // 💥 CRASH!
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Print dictionary keys: po dictionary.keys
 2. Check if key exists: dictionary["key"] != nil
 3. Print entire dictionary: po dictionary
 4. Use breakpoint to inspect dictionary contents
 5. Check for nil values vs missing keys
 6. Use Xcode's Quick Look for dictionary visualization
 */

// ✅ FIXED CODE - Safe Dictionary Access

class FixedDictionaryHandler {
    
    // SOLUTION 1: Optional binding with if-let
    func processUserData_IfLet() {
        let userData: [String: String] = [
            "name": "Alice",
            "email": "alice@apple.com"
        ]
        
        if let name = userData["name"],
           let email = userData["email"] {
            print("User: \(name), \(email)")
        }
        
        // Handle optional key separately
        if let phone = userData["phone"] {
            print("Phone: \(phone)")
        } else {
            print("Phone: Not provided")
        }
    }
    
    // SOLUTION 2: Nil coalescing operator
    func processUserData_NilCoalescing() {
        let userData: [String: String] = [
            "name": "Alice",
            "email": "alice@apple.com"
        ]
        
        let name = userData["name"] ?? "Unknown"
        let email = userData["email"] ?? "no-email"
        let phone = userData["phone"] ?? "No phone number"
        
        print("\(name), \(email), \(phone)")
    }
    
    // SOLUTION 3: Guard statement for required keys
    func processUserData_Guard() {
        let userData: [String: String] = [
            "name": "Alice",
            "email": "alice@apple.com"
        ]
        
        guard let name = userData["name"],
              let email = userData["email"] else {
            print("❌ Missing required user data")
            return
        }
        
        print("User: \(name), \(email)")
        
        // Optional field
        let phone = userData["phone"] ?? "N/A"
        print("Phone: \(phone)")
    }
    
    // SOLUTION 4: Safe nested dictionary access
    func parseJSON_Safe() {
        let json: [String: Any] = [
            "user": [
                "name": "Bob",
                "age": 30
            ]
        ]
        
        // Use optional chaining
        if let user = json["user"] as? [String: Any],
           let name = user["name"] as? String {
            
            let address = user["address"] as? String ?? "Address not provided"
            print("\(name) lives at \(address)")
        } else {
            print("❌ Invalid user data")
        }
    }
    
    // SOLUTION 5: Safe counter increment
    func updateCounter_Safe() {
        var counts: [String: Int] = ["apple": 5, "banana": 3]
        
        // Method 1: Check and update
        if let current = counts["orange"] {
            counts["orange"] = current + 1
        } else {
            counts["orange"] = 1
        }
        
        // Method 2: Use default value
        counts["orange", default: 0] += 1
        
        print("Counts: \(counts)")
    }
    
    // SOLUTION 6: Handle optional values in dictionary
    func iterateHandlingOptionals() {
        let scores: [String: Int?] = [
            "Alice": 95,
            "Bob": nil,
            "Charlie": 87
        ]
        
        for (name, score) in scores {
            if let actualScore = score {
                print("\(name): \(actualScore + 10) (bonus applied)")
            } else {
                print("\(name): No score yet")
            }
        }
    }
    
    // SOLUTION 7: Custom subscript with default
    func usingDefaultSubscript() {
        let settings: [String: Bool] = [
            "notifications": true,
            "darkMode": false
        ]
        
        // Using default subscript (Swift 5.0+)
        let notifications = settings["notifications", default: false]
        let darkMode = settings["darkMode", default: false]
        let analytics = settings["analytics", default: true]  // Key doesn't exist
        
        print("Notifications: \(notifications)")
        print("Dark Mode: \(darkMode)")
        print("Analytics: \(analytics)")
    }
    
    // SOLUTION 8: Validating all required keys
    func validateRequiredKeys() {
        let data: [String: String] = [
            "name": "Alice",
            "email": "alice@apple.com"
        ]
        
        let requiredKeys = ["name", "email", "phone"]
        let missingKeys = requiredKeys.filter { data[$0] == nil }
        
        if missingKeys.isEmpty {
            print("✅ All required keys present")
        } else {
            print("❌ Missing keys: \(missingKeys.joined(separator: ", "))")
        }
    }
}

// Extension for safer dictionary access
extension Dictionary {
    func getValue(for key: Key, default defaultValue: Value) -> Value {
        return self[key] ?? defaultValue
    }
    
    func safeValue<T>(for key: Key, as type: T.Type) -> T? {
        return self[key] as? T
    }
}

// Type-safe configuration pattern
struct UserProfile {
    let name: String
    let email: String
    let phone: String?
    let age: Int?
    
    init?(from dictionary: [String: Any]) {
        // Required fields
        guard let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String else {
            return nil
        }
        
        self.name = name
        self.email = email
        
        // Optional fields
        self.phone = dictionary["phone"] as? String
        self.age = dictionary["age"] as? Int
    }
}

// Codable approach (best practice for structured data)
struct User: Codable {
    let name: String
    let email: String
    let phone: String?
    let age: Int?
}

class ModernDictionaryHandler {
    func parseWithCodable() {
        let jsonData = """
        {
            "name": "Alice",
            "email": "alice@apple.com",
            "age": 25
        }
        """.data(using: .utf8)!
        
        do {
            let user = try JSONDecoder().decode(User.self, from: jsonData)
            print("User: \(user.name), \(user.email)")
            print("Phone: \(user.phone ?? "Not provided")")
        } catch {
            print("❌ Decoding error: \(error)")
        }
    }
}

// Advanced: Result builder for dictionary validation
enum DictionaryError: Error {
    case missingKey(String)
    case invalidType(String)
}

struct DictionaryValidator {
    let dictionary: [String: Any]
    
    func require<T>(_ key: String, as type: T.Type) -> Result<T, DictionaryError> {
        guard let value = dictionary[key] else {
            return .failure(.missingKey(key))
        }
        
        guard let typedValue = value as? T else {
            return .failure(.invalidType(key))
        }
        
        return .success(typedValue)
    }
    
    func optional<T>(_ key: String, as type: T.Type) -> T? {
        return dictionary[key] as? T
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== SAFE DICTIONARY ACCESS ===\n")
    
    let handler = FixedDictionaryHandler()
    
    print("--- Using if-let ---")
    handler.processUserData_IfLet()
    
    print("\n--- Using nil coalescing ---")
    handler.processUserData_NilCoalescing()
    
    print("\n--- Using guard ---")
    handler.processUserData_Guard()
    
    print("\n--- Safe JSON parsing ---")
    handler.parseJSON_Safe()
    
    print("\n--- Safe counter increment ---")
    handler.updateCounter_Safe()
    
    print("\n--- Handling optional values ---")
    handler.iterateHandlingOptionals()
    
    print("\n--- Using default subscript ---")
    handler.usingDefaultSubscript()
    
    print("\n--- Validating required keys ---")
    handler.validateRequiredKeys()
    
    print("\n--- Type-safe initialization ---")
    let dict: [String: Any] = [
        "name": "Charlie",
        "email": "charlie@apple.com",
        "age": 28
    ]
    
    if let profile = UserProfile(from: dict) {
        print("Profile: \(profile.name), \(profile.email)")
        print("Age: \(profile.age ?? -1)")
    }
    
    print("\n--- Modern Codable approach ---")
    let modern = ModernDictionaryHandler()
    modern.parseWithCodable()
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. Dictionary access ALWAYS returns an optional
 2. NEVER force unwrap dictionary values with !
 3. Use nil coalescing (??) for default values
 4. Use [key, default: value] for safe access with defaults
 5. Validate required keys before processing
 6. Use Codable for structured JSON data
 7. Handle nested dictionaries carefully
 
 🎯 SAFE DICTIONARY PATTERNS:
 
 // ❌ DANGEROUS
 let value = dict["key"]!
 
 // ✅ SAFE OPTIONS:
 
 // Option 1: if-let
 if let value = dict["key"] {
     use(value)
 }
 
 // Option 2: guard-let
 guard let value = dict["key"] else { return }
 
 // Option 3: nil coalescing
 let value = dict["key"] ?? defaultValue
 
 // Option 4: default subscript (Swift 5.0+)
 let value = dict["key", default: defaultValue]
 
 ⚠️  COMMON DICTIONARY MISTAKES:
 
 1. Force unwrapping: dict["key"]!
 2. Assuming keys exist
 3. Not handling nested optionals: [String: Int?]
 4. Force casting values: as!
 5. Modifying dict while iterating
 6. Not validating JSON structure
 
 💡 BEST PRACTICES:
 
 1. Define required vs optional keys upfront
 2. Use type-safe models (structs/classes)
 3. Prefer Codable over raw dictionaries
 4. Validate early with guard statements
 5. Provide sensible defaults
 6. Use enums for dictionary keys to avoid typos
 
 🛠️  DICTIONARY TIPS:
 
 // Check if key exists
 if dict.keys.contains("key") { }
 
 // Get all values safely
 let values = dict.compactMapValues { $0 as? String }
 
 // Filter dictionary
 let filtered = dict.filter { $0.value > 10 }
 
 // Update value safely
 dict["key", default: 0] += 1
 
 // Merge dictionaries
 var dict1 = ["a": 1]
 let dict2 = ["b": 2]
 dict1.merge(dict2) { current, _ in current }
 
 ⚡ INTERVIEW PATTERNS:
 
 // Pattern 1: Required fields
 guard let name = dict["name"] as? String,
       let id = dict["id"] as? Int else {
     return nil
 }
 
 // Pattern 2: Optional fields with defaults
 let isActive = dict["active"] as? Bool ?? true
 let count = dict["count", default: 0]
 
 // Pattern 3: Nested dictionaries
 if let user = dict["user"] as? [String: Any],
    let name = user["name"] as? String {
     // Safe nested access
 }
 
 // Pattern 4: Type-safe wrapper
 struct Config {
     let dict: [String: Any]
     
     func string(_ key: String) -> String? {
         return dict[key] as? String
     }
     
     func int(_ key: String, default: Int = 0) -> Int {
         return dict[key] as? Int ?? `default`
     }
 }
 
 🎓 ADVANCED TOPICS:
 
 - Dictionary performance: O(1) average lookup
 - Hash collisions and hashValue
 - Codable with custom keys (CodingKeys)
 - JSON decoding strategies
 - KeyPath for type-safe access
 - Property wrappers for configuration
 */

// Run demonstrations
print("🐛 BUGGY VERSION:")
demonstrateBug()

print("\n" + String(repeating: "=", count: 50) + "\n")
demonstrateFix()
