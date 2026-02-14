// =============================================================================
// EXAMPLE 9: Incorrect Type Casting (as? vs as! vs as)
// =============================================================================
// INTERVIEW TIP: Use as? for safe casting; as! only when 100% sure
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Force cast (as!) when type might not match = CRASH
// -----------------------------------------------------------------------------

class Animal {}
class Dog: Animal {}
class Cat: Animal {}

func makeSound_BUG(animal: Animal) {
    let dog = animal as! Dog  // ❌ CRASH if animal is Cat
    print("Woof")
}
// makeSound_BUG(animal: Cat())  // FATAL: Could not cast

// -----------------------------------------------------------------------------
// ✅ FIX: Use optional cast (as?) and handle failure
// -----------------------------------------------------------------------------

func makeSound_FIX(animal: Animal) {
    if let dog = animal as? Dog {
        print("Woof")
    } else if animal is Cat {
        print("Meow")
    }
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Confusing as with as?
// -----------------------------------------------------------------------------

let anyValue: Any = "Hello"
let str = anyValue as! String  // Works if it's String, crashes otherwise

func processValue_BUG(_ value: Any) {
    let num = value as! Int  // ❌ Crashes if value is String
    print(num + 1)
}

// -----------------------------------------------------------------------------
// ✅ FIX: Safe cast with as?
// -----------------------------------------------------------------------------

func processValue_FIX(_ value: Any) {
    if let num = value as? Int {
        print(num + 1)
    } else {
        print("Not an Int")
    }
}

// -----------------------------------------------------------------------------
// When to use each:
// as?  → Optional cast, returns T?  → Use with if let
// as!  → Force cast, crashes if fails → Avoid
// as   → Compile-time guaranteed (e.g., String as CustomStringConvertible)
// -----------------------------------------------------------------------------

// 📌 KEY LESSON: Prefer as? with if let. Use as! only when the type is
//    guaranteed at compile time (e.g., from a typed collection).
