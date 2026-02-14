// Example 1: Force Unwrap Crash
// BUG: Using ! on optional that can be nil crashes the app
// Common in Apple interviews - they want to see you handle optionals safely

import Foundation

func getUserName(from dict: [String: String]) -> String {
    return dict["name"]!  // 💥 CRASH if "name" key doesn't exist
}

let user1 = ["name": "Alice", "age": "30"]
print(getUserName(from: user1))  // Works

let user2 = ["age": "25"]  // Missing "name"!
print(getUserName(from: user2))  // CRASH: Unexpectedly found nil
