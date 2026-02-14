// BUGGY: Index out of range - Classic interview question!
func getFifthElement(from array: [Int]) -> Int {
    return array[4]  // 💥 CRASH if array has fewer than 5 elements
}

let numbers = [1, 2, 3]
print(getFifthElement(from: numbers))  // 💥 CRASH: Index out of range
