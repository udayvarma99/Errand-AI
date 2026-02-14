// Example 4: Value Type Mutation (let vs var)
// BUG: Trying to mutate a struct property when instance is let
// "Why can't I change this array?" - common interview question

import Foundation

struct Config {
    var items: [String] = []
}

let config = Config()  // 'let' makes config immutable
config.items.append("new item")  // 💥 Error: Cannot mutate property of immutable value
