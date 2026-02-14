// FIXED: Use String.Index for string subscripting
let greeting = "Hello, Swift!"

// Get first character
let startIndex = greeting.startIndex
let firstChar = greeting[startIndex]  // "H" ✅

// Get last character
let endIndex = greeting.index(before: greeting.endIndex)
let lastChar = greeting[endIndex]  // "!" ✅

// Get character at position 7
let index7 = greeting.index(greeting.startIndex, offsetBy: 7)
let char = greeting[index7]  // "S" ✅

// Safe subscript (returns Optional)
extension String {
    subscript(offset: Int) -> Character? {
        guard offset >= 0, offset < count else { return nil }
        let index = self.index(startIndex, offsetBy: offset)
        return self[index]
    }
}
print(greeting[7] ?? "?")  // "S" ✅
