// Example 5: Optional Chaining Pitfall
// BUG: Optional chaining returns Optional - don't assume non-nil type
// "Why is my UI not updating?" - the chain might short-circuit

import Foundation

class User {
    var profile: Profile?
}

class Profile {
    var displayName: String = ""
}

let user = User()
user.profile = nil

// This compiles but displayName is NEVER set - user.profile is nil!
user.profile?.displayName = "John"  // Silently does nothing

// Then somewhere else we assume it was set:
print(user.profile!.displayName)  // 💥 CRASH - profile was nil all along
