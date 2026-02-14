// Example 4 FIXED: Use var for mutability
// With structs (value types): let = immutable, var = mutable

import Foundation

struct Config {
    var items: [String] = []
}

// Option 1: Use var when you need to mutate
var config = Config()
config.items.append("new item")  // ✅ Works

// Option 2: If you need let, create new instance
let config2 = Config()
let updatedConfig = Config(items: config2.items + ["new item"])  // ✅ Immutable approach
