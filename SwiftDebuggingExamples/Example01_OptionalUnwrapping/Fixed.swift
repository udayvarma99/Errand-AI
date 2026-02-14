// Example 1: Optional Unwrapping - FIXED VERSION
// Proper optional handling prevents crashes

import Foundation

class UserProfile {
    var name: String?
    var age: Int?
    var email: String?
    var address: Address?
}

struct Address {
    var street: String
    var city: String
    var zipCode: String?
}

class UserManager {
    var currentUser: UserProfile?
    
    // FIX 1: Use optional binding (if let)
    func displayUserName() {
        if let user = currentUser, let name = user.name {
            print("User name: \(name)")
        } else {
            print("User name not available")
        }
    }
    
    // Alternative: Use guard let for early exit
    func displayUserNameWithGuard() {
        guard let user = currentUser, let name = user.name else {
            print("User name not available")
            return
        }
        print("User name: \(name)")
    }
    
    // FIX 2: Safe dictionary access with conditional casting
    func getUserAge(from userDict: [String: Any]) -> Int? {
        // Option 1: Conditional casting
        guard let age = userDict["age"] as? Int else {
            return nil
        }
        return age
    }
    
    // Alternative: Provide a default value
    func getUserAgeWithDefault(from userDict: [String: Any]) -> Int {
        return userDict["age"] as? Int ?? 0
    }
    
    // FIX 3: Optional chaining instead of force unwrapping
    func getUserCity() -> String? {
        return currentUser?.address?.city
    }
    
    // With default value
    func getUserCityWithDefault() -> String {
        return currentUser?.address?.city ?? "Unknown"
    }
    
    // FIX 4: Use regular optional and provide default
    var cachedData: String?
    
    func getCachedData() -> String {
        return cachedData ?? "No cached data"
    }
    
    // Or check before using
    func useCachedData() {
        if let data = cachedData {
            print("Cached: \(data)")
        } else {
            print("No cache available")
        }
    }
    
    // FIX 5: Proper error handling with do-catch
    func parseJSON(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch {
            print("JSON parsing error: \(error)")
            return nil
        }
    }
    
    // Alternative: Using Result type for better error handling
    func parseJSONWithResult(_ jsonString: String) -> Result<[String: Any], Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(NSError(domain: "Invalid string encoding", code: -1))
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return .success(json)
            } else {
                return .failure(NSError(domain: "Invalid JSON format", code: -2))
            }
        } catch {
            return .failure(error)
        }
    }
}

// Safe usage examples:
let manager = UserManager()

// Won't crash - handles nil gracefully
manager.displayUserName()  // Prints: "User name not available"

let user = UserProfile()
manager.currentUser = user
manager.displayUserName()  // Prints: "User name not available" (name is still nil)

user.name = "Alice"
manager.displayUserName()  // Prints: "User name: Alice"

// Safe dictionary access
let userDict: [String: Any] = ["name": "Bob", "age": 30]
if let age = manager.getUserAge(from: userDict) {
    print("Age: \(age)")
}

// Safe city access
if let city = manager.getUserCity() {
    print("City: \(city)")
} else {
    print("City not available")
}

// Safe JSON parsing
let jsonString = #"{"name": "Charlie", "age": 25}"#
if let parsed = manager.parseJSON(jsonString) {
    print("Parsed successfully: \(parsed)")
}

// Using Result type
let result = manager.parseJSONWithResult(jsonString)
switch result {
case .success(let json):
    print("Success: \(json)")
case .failure(let error):
    print("Error: \(error)")
}
