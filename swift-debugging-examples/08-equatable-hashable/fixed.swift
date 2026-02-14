// FIXED: Conform to Equatable for == and contains()
struct Person: Equatable {
    let name: String
    let age: Int
    
    // Swift can synthesize this automatically for simple structs!
    // static func == (lhs: Person, rhs: Person) -> Bool
}

let people = [
    Person(name: "Alice", age: 30),
    Person(name: "Bob", age: 25)
]

let alice = Person(name: "Alice", age: 30)

if people.contains(alice) {  // ✅ Works!
    print("Found Alice!")
}

if people[0] == alice {  // ✅ Works!
    print("Same person")
}

// For use in Set/Dictionary, also need Hashable
struct PersonHashable: Hashable {
    let name: String
    let age: Int
}
