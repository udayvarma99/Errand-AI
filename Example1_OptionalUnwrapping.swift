/*
 ============================================
 EXAMPLE 1: OPTIONAL UNWRAPPING CRASHES
 ============================================
 
 Common Issue: Force unwrapping nil values causes runtime crashes
 Apple Interview Focus: Safe optional handling is crucial
 */

import Foundation

// ❌ BUGGY CODE - This will crash!
class BuggyUserProfile {
    var name: String?
    var email: String?
    var age: Int?
    
    func displayUserInfo() {
        // 🐛 BUG: Force unwrapping without checking if value exists
        print("Name: \(name!)")        // Crashes if name is nil
        print("Email: \(email!)")      // Crashes if email is nil
        print("Age: \(age!)")          // Crashes if age is nil
    }
    
    func getUserEmail() -> String {
        // 🐛 BUG: Assuming optional always has a value
        return email!  // Fatal error if email is nil
    }
}

// Example of the crash:
func demonstrateBug() {
    let user = BuggyUserProfile()
    // user.displayUserInfo()  // 💥 CRASH: Fatal error: Unexpectedly found nil
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Set a breakpoint on the crashing line
 2. Check the variable in the debugger - you'll see it's nil
 3. Look for the exclamation mark (!) - it's a red flag
 4. Enable Exception Breakpoint in Xcode to catch at crash point
 */

// ✅ FIXED CODE - Multiple Safe Approaches

class FixedUserProfile {
    var name: String?
    var email: String?
    var age: Int?
    
    // SOLUTION 1: Optional Binding (if let)
    func displayUserInfo_IfLet() {
        if let name = name {
            print("Name: \(name)")
        } else {
            print("Name: Not provided")
        }
        
        if let email = email {
            print("Email: \(email)")
        } else {
            print("Email: Not provided")
        }
        
        if let age = age {
            print("Age: \(age)")
        } else {
            print("Age: Not provided")
        }
    }
    
    // SOLUTION 2: Guard Statement (cleaner for early returns)
    func displayUserInfo_Guard() {
        guard let name = name else {
            print("Name: Not provided")
            return
        }
        print("Name: \(name)")
        
        guard let email = email else {
            print("Email: Not provided")
            return
        }
        print("Email: \(email)")
        
        guard let age = age else {
            print("Age: Not provided")
            return
        }
        print("Age: \(age)")
    }
    
    // SOLUTION 3: Nil Coalescing Operator
    func displayUserInfo_NilCoalescing() {
        print("Name: \(name ?? "Not provided")")
        print("Email: \(email ?? "Not provided")")
        print("Age: \(age.map(String.init) ?? "Not provided")")
    }
    
    // SOLUTION 4: Optional Chaining
    func getEmailLength() -> Int {
        return email?.count ?? 0  // Safe: returns 0 if email is nil
    }
    
    // SOLUTION 5: Providing default values
    func getUserEmail() -> String {
        return email ?? "no-email@example.com"
    }
    
    // SOLUTION 6: Multiple unwrapping in one if-let
    func displayCompleteInfo() {
        if let name = name, let email = email, let age = age {
            print("Complete Profile: \(name), \(email), Age: \(age)")
        } else {
            print("Incomplete profile information")
        }
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    let user = FixedUserProfile()
    user.name = "Alice"
    user.email = "alice@apple.com"
    // age is still nil
    
    print("=== Using if-let ===")
    user.displayUserInfo_IfLet()
    
    print("\n=== Using nil coalescing ===")
    user.displayUserInfo_NilCoalescing()
    
    print("\n=== Getting email safely ===")
    print("Email: \(user.getUserEmail())")
    
    print("\n=== Email length ===")
    print("Length: \(user.getEmailLength())")
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. NEVER use force unwrap (!) unless you're 100% certain value exists
 2. Prefer optional binding (if let, guard let) for clarity
 3. Use nil coalescing (??) when you have a good default value
 4. Guard statements make code more readable with early returns
 5. Optional chaining (?.) is great for nested optionals
 
 🎯 WHEN TO USE EACH:
 
 - if let: When you need the unwrapped value in a scope
 - guard let: When you want early return if nil
 - ?? (nil coalescing): When you have a sensible default
 - ?. (optional chaining): For nested optional properties/methods
 
 ⚠️  EXCEPTION: Force unwrap is OK only when:
 - IBOutlets (after viewDidLoad)
 - Implicitly unwrapped optionals you control
 - After explicit nil check
 
 Example of safe force unwrap:
 if user.email != nil {
     let email = user.email!  // Safe here, but still prefer if-let
 }
 */

// Run the demonstration
demonstrateFix()
