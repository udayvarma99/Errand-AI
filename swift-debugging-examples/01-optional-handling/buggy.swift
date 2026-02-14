// BUGGY: Crashes when name is nil - Very common in interviews!
func greet(name: String?) {
    let message = "Hello, " + name!  // 💥 Force unwrap - CRASH if nil!
    print(message)
}

greet(name: "Alice")  // Works
greet(name: nil)      // 💥 CRASH: Unexpectedly found nil
