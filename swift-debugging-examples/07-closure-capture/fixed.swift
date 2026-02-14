// FIXED: Capture value at closure creation time
var closures: [() -> Void] = []

for i in 0..<3 {
    closures.append { [i] in  // ✅ Capture i by value at this moment
        print(i)
    }
}

closures[0]()  // Prints 0 ✅
closures[1]()  // Prints 1 ✅
closures[2]()  // Prints 2 ✅

// Alternative: Use a local copy
for j in 0..<3 {
    let value = j
    closures.append {
        print(value)
    }
}
