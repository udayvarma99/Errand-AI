/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 1: OPTIONAL UNWRAPPING
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Force unwrapping vs safe unwrapping
 Common Interview Question: "How do you safely handle optionals in Swift?"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

class UserProfileBuggy {
    var username: String
    var email: String?
    var phoneNumber: String?
    
    init(username: String, email: String? = nil, phoneNumber: String? = nil) {
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    // BUG: Force unwrapping can crash the app!
    func displayContactInfo() {
        print("Username: \(username)")
        print("Email: \(email!)")              // 💥 CRASH if email is nil
        print("Phone: \(phoneNumber!)")        // 💥 CRASH if phoneNumber is nil
    }
}

// Test case that will crash:
// let user = UserProfileBuggy(username: "john_doe")
// user.displayContactInfo()  // 💥 Fatal error: Unexpectedly found nil


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 The bug occurs because we're using force unwrapping (!) on optional values
 that might be nil. When email or phoneNumber is nil, the app will crash
 with "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
 
 This is one of the MOST COMMON crashes in Swift applications!
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Look for the "!" operator - this is a red flag
 2. Check if the variable is an Optional (String?, Int?, etc.)
 3. Ask: "Is there any scenario where this could be nil?"
 4. Use Xcode's warning: "Force unwrapping should be avoided"
 5. Set a breakpoint and check the value before unwrapping
 
 LLDB Commands:
 - breakpoint set -f Example01.swift -l 22
 - po email
 - po phoneNumber
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

class UserProfileFixed {
    var username: String
    var email: String?
    var phoneNumber: String?
    
    init(username: String, email: String? = nil, phoneNumber: String? = nil) {
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    // SOLUTION 1: Optional Binding (if let)
    func displayContactInfo_Solution1() {
        print("Username: \(username)")
        
        if let email = email {
            print("Email: \(email)")
        } else {
            print("Email: Not provided")
        }
        
        if let phoneNumber = phoneNumber {
            print("Phone: \(phoneNumber)")
        } else {
            print("Phone: Not provided")
        }
    }
    
    // SOLUTION 2: Nil Coalescing Operator (??)
    func displayContactInfo_Solution2() {
        print("Username: \(username)")
        print("Email: \(email ?? "Not provided")")
        print("Phone: \(phoneNumber ?? "Not provided")")
    }
    
    // SOLUTION 3: Optional Chaining + Guard
    func displayContactInfo_Solution3() {
        print("Username: \(username)")
        
        guard let email = email else {
            print("Email: Not provided")
            return
        }
        print("Email: \(email)")
        
        guard let phoneNumber = phoneNumber else {
            print("Phone: Not provided")
            return
        }
        print("Phone: \(phoneNumber)")
    }
    
    // SOLUTION 4: String Interpolation (handles optionals automatically)
    func displayContactInfo_Solution4() {
        print("Username: \(username)")
        print("Email: \(email ?? "Not provided")")
        print("Phone: \(phoneNumber ?? "Not provided")")
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample01() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 1: OPTIONAL UNWRAPPING")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: User with all information
    print("Test Case 1: Complete Profile")
    let user1 = UserProfileFixed(
        username: "jane_smith",
        email: "jane@example.com",
        phoneNumber: "+1-555-0123"
    )
    user1.displayContactInfo_Solution2()
    
    print("\n" + String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: User with missing information
    print("Test Case 2: Incomplete Profile")
    let user2 = UserProfileFixed(username: "john_doe")
    user2.displayContactInfo_Solution2()
    
    print("\n" + String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: User with partial information
    print("Test Case 3: Partial Profile")
    let user3 = UserProfileFixed(username: "alice", email: "alice@example.com")
    user3.displayContactInfo_Solution2()
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. NEVER use force unwrapping (!) unless you're 100% certain the value exists
 
 2. Prefer these safe unwrapping methods:
    - if let / guard let (Optional Binding)
    - Nil Coalescing (??)
    - Optional Chaining (?.)
    
 3. When to use each:
    - if let: When you need to use the value in a block
    - guard let: When you want to exit early if nil
    - ??: When you want a default value
    - ?.: When calling methods on optional objects
    
 4. Force unwrapping IS acceptable when:
    - Using implicitly unwrapped optionals from APIs
    - After explicitly checking for nil
    - In test code with controlled inputs
    
 5. Interview Tip: Always explain your choice of unwrapping method
    and discuss edge cases where values might be nil
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between if let and guard let?"
 A1: if let creates a scope for the unwrapped value, while guard let
     exits the current scope if nil, keeping the unwrapped value available
     for the rest of the function.
 
 Q2: "When would you use implicitly unwrapped optionals?"
 A2: For properties that are initialized after init (like IBOutlets) or
     when working with Objective-C APIs that can't be nil after setup.
 
 Q3: "How do you chain multiple optional checks?"
 A3: Use optional chaining: user?.profile?.email?.lowercased()
     or combine with nil coalescing for defaults.
*/

// Uncomment to run:
// runExample01()
