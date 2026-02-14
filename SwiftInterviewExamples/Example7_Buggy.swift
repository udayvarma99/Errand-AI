// EXAMPLE 7: Reference vs Value Comparison (Medium)
// BUG: Using == on class instances without Equatable
// Expected: Check if two users are the same

class User {
    let id: Int
    let name: String
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

let user1 = User(id: 1, name: "Alice")
let user2 = User(id: 1, name: "Alice")

// print(user1 == user2)  // 💥 Compiler error: User doesn't conform to Equatable
// Classes compare by REFERENCE by default - two different instances are never "equal"
