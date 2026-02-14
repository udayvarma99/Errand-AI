// Example 5 FIXED: Check optional before using
// Optional chaining with assignment: the whole expression can "fail silently"

import Foundation

class User {
    var profile: Profile?
}

class Profile {
    var displayName: String = ""
}

let user = User()

// Option 1: Create profile if needed before mutating
if user.profile == nil {
    user.profile = Profile()
}
user.profile?.displayName = "John"  // ✅ Now it works

// Option 2: Use optional binding when reading
if let profile = user.profile {
    print(profile.displayName)  // Safe - we know it exists
} else {
    print("No profile")  // Handle the nil case
}
