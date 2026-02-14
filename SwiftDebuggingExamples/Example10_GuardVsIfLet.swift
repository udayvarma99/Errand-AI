// =============================================================================
// EXAMPLE 10: Guard vs If-Let, Early Exit & Pyramid of Doom
// =============================================================================
//
// DIFFICULTY: Beginner
// TOPIC: guard, if-let, Early Exit, Code Readability
// APPLE INTERVIEW TIP: Clean, readable code matters at Apple. They value
//   developers who write clear, maintainable code. Understanding guard vs
//   if-let shows you know idiomatic Swift.
//
// WHAT YOU WILL LEARN:
//   - The "Pyramid of Doom" anti-pattern and how to fix it
//   - When to use guard-let vs if-let
//   - How guard makes code more readable with early exit
//   - Handling multiple optional values cleanly
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the problems before scrolling down!
// ---------------------------------------------------------------------------

/*

// BUG 1: "Pyramid of Doom" — deeply nested if-let statements
struct UserProfile {
    let name: String?
    let email: String?
    let age: Int?
    let address: String?
}

func createAccount(from profile: UserProfile) -> String {
    // This works but is HARD TO READ and MAINTAIN
    if let name = profile.name {
        if let email = profile.email {
            if let age = profile.age {
                if age >= 18 {
                    if let address = profile.address {
                        // We're 5 levels deep! This is the "Pyramid of Doom"
                        return "Account created for \(name), \(email), age \(age), at \(address)"
                    } else {
                        return "Error: Address is required"
                    }
                } else {
                    return "Error: Must be 18 or older"
                }
            } else {
                return "Error: Age is required"
            }
        } else {
            return "Error: Email is required"
        }
    } else {
        return "Error: Name is required"
    }
}


// BUG 2: Using if-let when guard-let would be clearer
func processOrder(itemID: String?, quantity: Int?, couponCode: String?) -> String {
    var result = ""
    
    if let id = itemID {
        if let qty = quantity {
            if qty > 0 {
                result = "Order: \(qty)x item \(id)"
                
                if let code = couponCode {
                    result += " with coupon \(code)"
                }
            } else {
                result = "Error: Invalid quantity"
            }
        } else {
            result = "Error: Quantity required"
        }
    } else {
        result = "Error: Item ID required"
    }
    
    return result
}


// BUG 3: guard used incorrectly — not for early exit
func validate(input: String?) {
    guard let text = input else {
        // This is fine
        print("No input")
        return
    }
    
    // BUG: Using guard for a non-exit condition
    // guard is meant for "if this fails, EXIT"
    guard text.count > 5 else {
        // This forces a return, but maybe we still want to process short text!
        print("Text too short, skipping")
        return  // We lose the ability to handle short text differently
    }
    
    print("Processing: \(text)")
}

*/


// ---------------------------------------------------------------------------
// WHY ARE THESE BUGS?
// ---------------------------------------------------------------------------
//
// BUG 1: The "Pyramid of Doom" makes code:
//   - Hard to read (too many nesting levels)
//   - Hard to maintain (adding a condition means more nesting)
//   - Hard to follow the error paths (they're at the END of each level)
//   - Prone to mistakes (easy to close a brace at the wrong level)
//
// BUG 2: Same pyramid problem. Using if-let for validation creates deep
//   nesting when guard-let would keep the code flat.
//
// BUG 3: guard is for REQUIREMENTS that must be met to continue.
//   If you might want to handle both cases (not just exit), use if-let instead.
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE
// ---------------------------------------------------------------------------

struct UserProfile {
    let name: String?
    let email: String?
    let age: Int?
    let address: String?
}

// FIX 1: Use guard-let for flat, readable code
func createAccount(from profile: UserProfile) -> String {
    // Each guard validates ONE requirement and exits early if it fails
    // The "happy path" stays at the left margin — easy to follow!
    
    guard let name = profile.name else {
        return "Error: Name is required"
    }
    
    guard let email = profile.email else {
        return "Error: Email is required"
    }
    
    guard let age = profile.age else {
        return "Error: Age is required"
    }
    
    guard age >= 18 else {
        return "Error: Must be 18 or older (got \(age))"
    }
    
    guard let address = profile.address else {
        return "Error: Address is required"
    }
    
    // All validations passed! All variables are non-optional and in scope.
    return "Account created for \(name), \(email), age \(age), at \(address)"
}


// FIX 2: Flat structure with guard-let
func processOrder(itemID: String?, quantity: Int?, couponCode: String?) -> String {
    guard let id = itemID else {
        return "Error: Item ID required"
    }
    
    guard let qty = quantity else {
        return "Error: Quantity required"
    }
    
    guard qty > 0 else {
        return "Error: Invalid quantity (\(qty))"
    }
    
    // Happy path — all requirements met
    var result = "Order: \(qty)x item \(id)"
    
    // if-let is fine for OPTIONAL enhancements (not requirements)
    if let code = couponCode {
        result += " with coupon \(code)"
    }
    
    return result
}


// FIX 3: Use if-let when you want to handle BOTH cases
func processText(_ input: String?) {
    // guard for the absolute requirement
    guard let text = input else {
        print("No input provided")
        return
    }
    
    // if-let / if-else for branching logic (not early exit)
    if text.count > 5 {
        print("Long text: \(text)")
    } else {
        print("Short text (still valid!): \(text)")
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify all fixes work correctly
// ---------------------------------------------------------------------------

print("=== Account Creation (guard-let) ===")

let validProfile = UserProfile(name: "Tim Cook", email: "tim@apple.com", age: 63, address: "Cupertino, CA")
print(createAccount(from: validProfile))

let noName = UserProfile(name: nil, email: "test@test.com", age: 25, address: "NYC")
print(createAccount(from: noName))

let tooYoung = UserProfile(name: "Kid", email: "kid@test.com", age: 15, address: "LA")
print(createAccount(from: tooYoung))

let noAddress = UserProfile(name: "Jane", email: "jane@test.com", age: 30, address: nil)
print(createAccount(from: noAddress))


print("\n=== Order Processing ===")

print(processOrder(itemID: "MAC-001", quantity: 2, couponCode: "SAVE20"))
print(processOrder(itemID: "MAC-001", quantity: 2, couponCode: nil))
print(processOrder(itemID: nil, quantity: 2, couponCode: nil))
print(processOrder(itemID: "MAC-001", quantity: 0, couponCode: nil))
print(processOrder(itemID: "MAC-001", quantity: nil, couponCode: nil))


print("\n=== Text Processing (if-let for branching) ===")

processText("Hello, World!")
processText("Hi")
processText(nil)


// ---------------------------------------------------------------------------
// BONUS: Advanced Pattern — Multiple Optional Binding
// ---------------------------------------------------------------------------

print("\n=== Multiple Optional Binding ===")

// You can bind multiple optionals in a single guard/if statement!
func formatFullName(first: String?, middle: String?, last: String?) -> String {
    // Bind multiple optionals at once — ALL must be non-nil
    guard let first = first, let last = last else {
        return "Error: First and last name are required"
    }
    
    // Middle name is optional — use if-let
    if let middle = middle {
        return "\(first) \(middle) \(last)"
    } else {
        return "\(first) \(last)"
    }
}

print(formatFullName(first: "Steve", middle: "Paul", last: "Jobs"))
print(formatFullName(first: "Tim", middle: nil, last: "Cook"))
print(formatFullName(first: nil, middle: nil, last: "Cook"))


// You can also combine optional binding with boolean conditions
func validatePassword(_ password: String?) -> String {
    guard let password = password,
          !password.isEmpty,
          password.count >= 8,
          password.count <= 64 else {
        return "Invalid: Password must be 8-64 characters"
    }
    
    // All conditions met
    return "Password '\(password)' is valid (\(password.count) chars)"
}

print("\n=== Password Validation ===")
print(validatePassword("MySecureP@ss"))
print(validatePassword("short"))
print(validatePassword(nil))
print(validatePassword(""))


// ---------------------------------------------------------------------------
// CHEAT SHEET: guard vs if-let
// ---------------------------------------------------------------------------
//
// USE guard-let WHEN:
//   ✓ You require a value to continue — exit early if missing
//   ✓ You want the unwrapped value available for the REST of the function
//   ✓ You're validating inputs at the top of a function
//   ✓ The failure case is the "exceptional" path
//
// USE if-let WHEN:
//   ✓ You want to do something ONLY IF a value exists
//   ✓ You need the unwrapped value only in a small scope
//   ✓ Both the nil and non-nil cases are equally valid
//   ✓ You're handling an optional enhancement (not a requirement)
//
// GOLDEN RULE:
//   guard → "I need this to continue. If I don't have it, I'm done."
//   if-let → "If this exists, great! If not, that's okay too."
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "Refactor this function to be more readable and Swifty."
//
//   func getUserInfo(json: [String: Any]) -> (String, Int)? {
//       if json["name"] != nil {
//           if json["name"] is String {
//               let name = json["name"] as! String
//               if json["age"] != nil {
//                   if json["age"] is Int {
//                       let age = json["age"] as! Int
//                       if age > 0 {
//                           return (name, age)
//                       }
//                   }
//               }
//           }
//       }
//       return nil
//   }
//
// A: Use guard-let with conditional casting:
//
//   func getUserInfo(json: [String: Any]) -> (String, Int)? {
//       guard let name = json["name"] as? String,
//             let age = json["age"] as? Int,
//             age > 0 else {
//           return nil
//       }
//       return (name, age)
//   }
//
//   The 'as?' operator combines nil-check, type-check, and casting in one step.
//   Combined with guard-let, it turns 12 lines of nested code into 6 flat lines.
//   This is the kind of clean, idiomatic Swift that Apple interviewers love.
// ---------------------------------------------------------------------------
