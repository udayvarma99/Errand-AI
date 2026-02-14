// BUGGY: Can't use == or contains() - Custom type needs Equatable!
struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "Alice", age: 30),
    Person(name: "Bob", age: 25)
]

let alice = Person(name: "Alice", age: 30)

// 💥 Error: Cannot convert value of type 'Person' to expected argument type 'Equatable'
if people.contains(alice) {
    print("Found Alice!")
}

// 💥 Error: Binary operator '==' cannot be applied to two 'Person' operands
if people[0] == alice {
    print("Same person")
}
