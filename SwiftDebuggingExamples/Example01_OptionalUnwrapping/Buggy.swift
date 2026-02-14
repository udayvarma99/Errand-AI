// Example 1: Optional Unwrapping Crashes
// This code has several optional handling bugs that will cause crashes

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
    
    // BUG 1: Force unwrapping without checking if value exists
    func displayUserName() {
        print("User name: \(currentUser!.name!)")  // 💥 Crash if currentUser or name is nil
    }
    
    // BUG 2: Unsafe dictionary access
    func getUserAge(from userDict: [String: Any]) -> Int {
        let age = userDict["age"] as! Int  // 💥 Crash if key doesn't exist or wrong type
        return age
    }
    
    // BUG 3: Force unwrapping in a chain
    func getUserCity() -> String {
        return currentUser!.address!.city  // 💥 Crash if currentUser or address is nil
    }
    
    // BUG 4: Implicitly unwrapped optional used incorrectly
    var cachedData: String!
    
    func getCachedData() -> String {
        return cachedData  // 💥 Crash if never set
    }
    
    // BUG 5: Force try without error handling
    func parseJSON(_ jsonString: String) -> [String: Any] {
        let data = jsonString.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return json  // 💥 Crash if JSON is invalid
    }
}

// Example usage that will crash:
let manager = UserManager()
manager.displayUserName()  // 💥 Crash: currentUser is nil!

let user = UserProfile()
manager.currentUser = user
manager.displayUserName()  // 💥 Crash: name is nil!

let city = manager.getUserCity()  // 💥 Crash: address is nil!

let cached = manager.getCachedData()  // 💥 Crash: cachedData never initialized!
