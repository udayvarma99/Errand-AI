// ============================================================================
// EXAMPLE 1: Optionals & Force Unwrapping
// Difficulty: Beginner
// Topic: Understanding Swift Optionals, nil safety, and safe unwrapping
// ============================================================================

// ============================================================================
// WHAT ARE OPTIONALS?
// ============================================================================
// In Swift, an Optional is a type that can hold either a value OR nil (nothing).
// Think of it like a box that might be empty.
//
//   var name: String  = "Alice"   // Always has a value
//   var name: String? = nil       // Might be empty (the ? makes it Optional)
//
// This is one of Swift's most important safety features. It forces you to
// handle the case where a value might not exist.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Force unwrapping a nil optional — CRASH!
func getUserName() -> String? {
    // Simulating a case where the user hasn't set their name yet
    return nil
}

let userName: String = getUserName()!  // 💥 CRASH: Force unwrapping nil!
print("Hello, \(userName)")


// Bug 2: Implicitly unwrapped optional used without checking
var userAge: Int! = nil
let nextBirthdayAge = userAge + 1  // 💥 CRASH: userAge is nil!
print("Next birthday you'll be \(nextBirthdayAge)")


// Bug 3: Force casting that will fail
let someValue: Any = "Hello"
let number: Int = someValue as! Int  // 💥 CRASH: String is not Int!
print(number)


// Bug 4: Chained optional access without safety
class Address {
    var street: String?
}

class Person {
    var address: Address?
}

let person = Person()
let streetLength: Int = person.address!.street!.count  // 💥 CRASH: address is nil!
print("Street name has \(streetLength) characters")

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: The `!` operator (force unwrap) tells Swift: "I'm 100% sure this
//         is NOT nil, just give me the value." But getUserName() returns nil,
//         so the app crashes with: "Unexpectedly found nil while unwrapping."
//
// Bug 2: `Int!` is an implicitly unwrapped optional. It can be nil, but Swift
//         treats it as if it always has a value. When you do math with nil, crash!
//
// Bug 3: `as!` is a force cast. It will crash if the types don't match.
//         A String cannot be cast to an Int this way.
//
// Bug 4: Chaining `!` on multiple optionals is extremely dangerous. If ANY
//         value in the chain is nil, the entire line crashes.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Use "if let" to safely unwrap the optional
func getUserName() -> String? {
    return nil
}

if let userName = getUserName() {
    print("Hello, \(userName)")
} else {
    print("Hello, Guest!")  // Safe fallback when nil
}

// Alternative Fix 1b: Use the nil-coalescing operator (??)
let userName = getUserName() ?? "Guest"
print("Hello, \(userName)")  // Prints: "Hello, Guest!"


// Fix 2: Use "guard let" for early exit (common in functions)
func celebrateBirthday(age: Int?) {
    guard let currentAge = age else {
        print("We don't know your age!")
        return  // Exit the function safely
    }
    let nextAge = currentAge + 1
    print("Next birthday you'll be \(nextAge)")
}

celebrateBirthday(age: nil)   // Prints: "We don't know your age!"
celebrateBirthday(age: 25)    // Prints: "Next birthday you'll be 26"


// Fix 3: Use "as?" for safe casting (returns nil if cast fails)
let someValue: Any = "Hello"

if let number = someValue as? Int {
    print("The number is \(number)")
} else {
    print("That value is not a number — it's a \(type(of: someValue))")
}
// Prints: "That value is not a number — it's a String"


// Fix 4: Use optional chaining (?.) for safe property access
class Address {
    var street: String?
}

class Person {
    var address: Address?
}

let person = Person()
let streetLength: Int? = person.address?.street?.count  // Safe! Returns nil.

if let length = streetLength {
    print("Street name has \(length) characters")
} else {
    print("No street address on file")  // This prints safely
}


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// Apple interviewers LOVE asking about optionals. Key points to remember:
//
// 1. NEVER force unwrap (!) unless you are 100% certain the value exists.
// 2. Prefer "if let" or "guard let" for safe unwrapping.
// 3. Use ?? (nil-coalescing) when you have a sensible default value.
// 4. Use ?. (optional chaining) when accessing properties of optional objects.
// 5. Use "as?" instead of "as!" for safe type casting.
//
// Common interview question: "What's the difference between if let and guard let?"
// Answer: Both safely unwrap optionals. "if let" creates a new scope (the value
//         only exists inside the if block). "guard let" makes the value available
//         for the REST of the function and forces an early exit if nil.
// ============================================================================
