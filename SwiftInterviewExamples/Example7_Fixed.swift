// EXAMPLE 7: Reference vs Value Comparison (FIXED)
// Conform to Equatable for value-based comparison

class User: Equatable {
    let id: Int
    let name: String
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

let user1 = User(id: 1, name: "Alice")
let user2 = User(id: 1, name: "Alice")
// user1 == user2  // true (same id and name)
// user1 === user2 // false (different instances - use === for identity)
