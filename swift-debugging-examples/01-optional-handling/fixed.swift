// FIXED: Safely handles nil - Apple loves this pattern
func greet(name: String?) {
    guard let name = name else {
        print("Hello, stranger!")
        return
    }
    let message = "Hello, " + name
    print(message)
}

// Alternative: Nil coalescing (??)
func greetAlternative(name: String?) {
    let message = "Hello, " + (name ?? "stranger")
    print(message)
}

greet(name: "Alice")  // "Hello, Alice"
greet(name: nil)      // "Hello, stranger!" ✅
