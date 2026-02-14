// EXAMPLE 4: Mutating Collection in Loop (FIXED)
// Option A: Iterate in reverse so indices stay valid
// Option B: Filter instead of mutating (idiomatic Swift)

// Option A - Reverse iteration:
var numbers = [1, 2, 3, 4, 5, 6]
for index in numbers.indices.reversed() {
    if numbers[index] % 2 == 0 {
        numbers.remove(at: index)
    }
}

// Option B - Filter (preferred):
numbers = [1, 2, 3, 4, 5, 6]
numbers = numbers.filter { $0 % 2 != 0 }
