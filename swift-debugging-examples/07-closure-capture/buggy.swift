// BUGGY: Closure captures wrong value - Classic "loop variable" bug
var closures: [() -> Void] = []

for i in 0..<3 {
    closures.append {
        print(i)  // 💥 All print 3! (captures i by reference, not value)
    }
}

closures[0]()  // Expected: 0, Actual: 3
closures[1]()  // Expected: 1, Actual: 3
closures[2]()  // Expected: 2, Actual: 3
