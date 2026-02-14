// EXAMPLE 4: Mutating Collection in Loop (Medium)
// BUG: Modifying array while iterating over it
// Expected: Remove all even numbers from array

var numbers = [1, 2, 3, 4, 5, 6]

for (index, num) in numbers.enumerated() {
    if num % 2 == 0 {
        numbers.remove(at: index)  // 💥 Undefined behavior! Indices shift
    }
}
// Result is unpredictable - indices change as we remove
