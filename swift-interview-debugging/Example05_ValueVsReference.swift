// =============================================================================
// EXAMPLE 5: Value vs Reference Type Confusion
// =============================================================================
// INTERVIEW TIP: Struct = value (copied), Class = reference (shared)
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Expecting a class to be copied, but it's shared
// -----------------------------------------------------------------------------

class Settings_BUG {
    var theme: String = "light"
}

func createDefaultSettings_BUG() -> Settings_BUG {
    let settings = Settings_BUG()
    return settings
}

let s1 = createDefaultSettings_BUG()
let s2 = s1
s2.theme = "dark"
// s1.theme is now "dark" too! ❌ (Same object, not a copy)

// -----------------------------------------------------------------------------
// ✅ FIX: Use struct for value semantics (Swift standard library style)
// -----------------------------------------------------------------------------

struct Settings_FIX {
    var theme: String = "light"
}

func createDefaultSettings_FIX() -> Settings_FIX {
    var settings = Settings_FIX()
    return settings  // Returns a COPY
}

let s3 = createDefaultSettings_FIX()
var s4 = s3
s4.theme = "dark"
// s3.theme is still "light" ✅ (Different copies)

// -----------------------------------------------------------------------------
// 🐛 BUG: Mutating a struct in a closure that captures by value
// -----------------------------------------------------------------------------

struct Counter_BUG {
    var count = 0
    
    mutating func increment() {
        count += 1
    }
}

var counter = Counter_BUG()
let closure = {
    counter.increment()  // ❌ Error: escaping closure captures mutating 'self'
}
// Struct methods are mutating; closure can't capture mutable struct easily

// -----------------------------------------------------------------------------
// ✅ FIX: Use a class for shared mutable state, or pass explicitly
// -----------------------------------------------------------------------------

class Counter_FIX {
    var count = 0
    
    func increment() {
        count += 1
    }
}

// 📌 KEY LESSON: struct = copied on assign/pass, class = shared reference.
//    Choose struct for "value" data, class when you need identity/sharing.
