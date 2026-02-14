// Example 1 FIXED: Safe Optional Handling
// Use optional binding, ?? nil-coalescing, or guard

import Foundation

func getUserName(from dict: [String: String]) -> String? {
    return dict["name"]  // Returns Optional - no crash
}

// OR with default value:
func getUserNameWithDefault(from dict: [String: String]) -> String {
    return dict["name"] ?? "Unknown"  // Safe default
}

let user1 = ["name": "Alice", "age": "30"]
print(getUserName(from: user1) ?? "Unknown")  // Alice

let user2 = ["age": "25"]
print(getUserName(from: user2) ?? "Unknown")  // Unknown - no crash!
