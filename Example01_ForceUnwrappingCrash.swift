/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 1: FORCE UNWRAPPING CRASH
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Optional Handling and Nil Safety
 Common In: 90% of Swift interviews
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - DO NOT USE
// ═══════════════════════════════════════════════════════════════

class UserManagerBuggy {
    var users: [String: String] = [
        "john": "John Doe",
        "jane": "Jane Smith"
    ]
    
    func getUserName(userId: String) -> String {
        // 🐛 BUG: Force unwrapping can crash if key doesn't exist
        let name = users[userId]!
        return name
    }
    
    func displayUser(userId: String) {
        let userName = getUserName(userId: userId)
        print("User: \(userName)")
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. FORCE UNWRAPPING (!)
    - users[userId]! will crash if userId doesn't exist
    - Dictionary subscript returns Optional<String>, not String
    - Runtime crash: "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
 
 2. NO NIL CHECKING
    - No validation if the user exists
    - No graceful error handling
 
 3. WHY IT CRASHES:
    - If you call getUserName(userId: "unknown")
    - users["unknown"] returns nil
    - Forcing nil with ! causes immediate crash
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Optional Binding
// ═══════════════════════════════════════════════════════════════

class UserManagerFixed1 {
    var users: [String: String] = [
        "john": "John Doe",
        "jane": "Jane Smith"
    ]
    
    func getUserName(userId: String) -> String? {
        // ✅ Return optional - let caller handle nil
        return users[userId]
    }
    
    func displayUser(userId: String) {
        // ✅ Use if-let for safe unwrapping
        if let userName = getUserName(userId: userId) {
            print("User: \(userName)")
        } else {
            print("User not found with ID: \(userId)")
        }
    }
}


// ✅ FIXED CODE - SOLUTION 2: Guard Statement
// ═══════════════════════════════════════════════════════════════

class UserManagerFixed2 {
    var users: [String: String] = [
        "john": "John Doe",
        "jane": "Jane Smith"
    ]
    
    func getUserName(userId: String) -> String? {
        return users[userId]
    }
    
    func displayUser(userId: String) {
        // ✅ Use guard for early return - cleaner code
        guard let userName = getUserName(userId: userId) else {
            print("User not found with ID: \(userId)")
            return
        }
        
        print("User: \(userName)")
        // userName is available in this scope
    }
}


// ✅ FIXED CODE - SOLUTION 3: Nil Coalescing
// ═══════════════════════════════════════════════════════════════

class UserManagerFixed3 {
    var users: [String: String] = [
        "john": "John Doe",
        "jane": "Jane Smith"
    ]
    
    func getUserName(userId: String) -> String {
        // ✅ Provide default value with nil coalescing operator (??)
        return users[userId] ?? "Unknown User"
    }
    
    func displayUser(userId: String) {
        let userName = getUserName(userId: userId)
        print("User: \(userName)")
    }
}


// ✅ FIXED CODE - SOLUTION 4: Optional Chaining
// ═══════════════════════════════════════════════════════════════

class UserManagerFixed4 {
    var users: [String: String] = [
        "john": "John Doe",
        "jane": "Jane Smith"
    ]
    
    func displayUser(userId: String) {
        // ✅ Optional chaining - only prints if user exists
        if let userName = users[userId] {
            print("User: \(userName)")
        }
        
        // Or use map for functional approach
        users[userId].map { print("User: \($0)") }
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. NEVER use force unwrapping (!) unless you're 100% certain the value exists
 2. Dictionary subscript returns Optional - always handle the nil case
 3. Prefer these safe alternatives:
    - if let (optional binding)
    - guard let (early return pattern)
    - ?? (nil coalescing for defaults)
    - Optional chaining
 
 4. WHEN TO USE EACH:
    - if let: When you need to use the value in a local scope
    - guard let: When you want to exit early if nil (cleaner for multiple checks)
    - ??: When you have a reasonable default value
    - Optional chaining: For property/method access on optionals
 
 5. Force unwrapping is ONLY acceptable when:
    - Using IBOutlets (guaranteed to be set by Interface Builder)
    - After you've explicitly checked for nil
    - In test code where you WANT it to crash
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "I see force unwrapping here, which could cause a runtime crash if the 
    dictionary doesn't contain that key."
 
 2. "Dictionary subscripts return optionals, so we need to safely unwrap them."
 
 3. "I'd use guard-let here for early return, which makes the happy path 
    clearer and avoids nested if statements."
 
 4. "If there's a sensible default value, nil coalescing (??) would be cleanest."
 
 5. "Let me also consider: Should this method return an optional, throw an 
    error, or provide a default? What makes sense for the API consumer?"
 
 RED FLAGS (Don't say this):
 ❌ "I'll just use ! because it's easier"
 ❌ "Crashes are okay, the user probably exists"
 ❌ "I'll add a comment saying not to call this with invalid IDs"
 
 BONUS POINTS:
 ✅ Discuss API design: Should getUserName return Optional<String>?
 ✅ Consider error handling: Maybe throw a custom error?
 ✅ Mention testing: "I'd write unit tests for the nil case"
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample1() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 1: FORCE UNWRAPPING CRASH")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test buggy version
    print("❌ BUGGY VERSION:")
    let buggyManager = UserManagerBuggy()
    buggyManager.displayUser(userId: "john")  // Works
    // buggyManager.displayUser(userId: "unknown")  // ⚠️ CRASHES! Uncomment to see crash
    print("(Crashed with unknown user ID - commented out)\n")
    
    // Test fixed versions
    print("✅ FIXED VERSION 1 (if-let):")
    let manager1 = UserManagerFixed1()
    manager1.displayUser(userId: "john")
    manager1.displayUser(userId: "unknown")
    print()
    
    print("✅ FIXED VERSION 2 (guard-let):")
    let manager2 = UserManagerFixed2()
    manager2.displayUser(userId: "jane")
    manager2.displayUser(userId: "unknown")
    print()
    
    print("✅ FIXED VERSION 3 (nil coalescing):")
    let manager3 = UserManagerFixed3()
    manager3.displayUser(userId: "john")
    manager3.displayUser(userId: "unknown")
    print()
    
    print("✅ FIXED VERSION 4 (optional chaining):")
    let manager4 = UserManagerFixed4()
    manager4.displayUser(userId: "jane")
    manager4.displayUser(userId: "unknown")
    print()
}

// Uncomment to run:
// runExample1()
