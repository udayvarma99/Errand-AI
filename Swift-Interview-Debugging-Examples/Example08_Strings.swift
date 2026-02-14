// ============================================================================
// EXAMPLE 8: String & Character Handling
// Difficulty: Beginner
// Topic: Swift String indexing, Unicode, common string manipulation pitfalls
// ============================================================================

// ============================================================================
// WHY ARE SWIFT STRINGS TRICKY?
// ============================================================================
// Unlike many languages (Python, Java, JavaScript), Swift strings do NOT
// support integer indexing like `myString[3]`. This is because Swift handles
// Unicode correctly — some characters (like emojis) take up more memory than
// others, so you can't just jump to position N.
//
//   "Hello"[0]  // ERROR in Swift! (works in Python, not here)
//
// Instead, Swift uses String.Index — a special type for navigating strings.
// This is confusing at first, but it prevents bugs with international text
// and emojis.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Trying to use integer subscripts on strings
let message = "Hello, World!"
let firstChar = message[0]  // 💥 ERROR: Cannot subscript String with Int
let fifthChar = message[4]  // 💥 Same error


// Bug 2: Comparing strings with wrong case sensitivity
let userInput = "Apple"
let expected = "apple"

if userInput == expected {
    print("Match!")
} else {
    print("No match!")  // BUG: "Apple" != "apple" — case mismatch!
}


// Bug 3: String length with emojis gives unexpected results
let emoji = "👨‍👩‍👧‍👦"  // Family emoji (one visual character, but complex)
print(emoji.count)         // Prints: 1
print(emoji.utf16.count)   // Prints: 11

// Developer iterates assuming each character is 1 unit:
let text = "Hi 👋🏽"
for i in 0..<text.utf16.count {
    // Trying to access characters by UTF-16 offset — WRONG approach
    // This will mishandle the emoji
}


// Bug 4: String splitting edge cases
let csv = "apple,,cherry,"
let items = csv.components(separatedBy: ",")
print(items)        // ["apple", "", "cherry", ""]
print(items.count)  // 4 — developer expected 3 (forgot about empty strings)


// Bug 5: Modifying a string while iterating
var text2 = "Hello"
for char in text2 {
    if char == "l" {
        // text2.remove(at: ...)  // Can't easily do this during iteration
        // It's very error-prone with String.Index
    }
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Swift strings don't support integer subscripting because characters
//         can be different sizes in memory (Unicode).
//
// Bug 2: String comparison in Swift is case-sensitive by default.
//         "Apple" and "apple" are not equal.
//
// Bug 3: Emojis can be composed of multiple Unicode scalars. `.count` gives
//         the number of visible characters, but UTF-16 length can be much more.
//
// Bug 4: `components(separatedBy:)` includes empty strings between consecutive
//         delimiters and at trailing delimiters.
//
// Bug 5: Mutating a collection while iterating over it is unsafe and
//         String.Index makes manual removal during iteration complex.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Use String.Index for character access
let message = "Hello, World!"

// Get the first character
let firstChar = message[message.startIndex]
print("First character: \(firstChar)")  // "H"

// Get the 5th character (index 4)
let fifthIndex = message.index(message.startIndex, offsetBy: 4)
let fifthChar = message[fifthIndex]
print("Fifth character: \(fifthChar)")  // "o"

// Get the last character
let lastChar = message[message.index(before: message.endIndex)]
print("Last character: \(lastChar)")  // "!"

// Even better — use .first and .last (they return Optional)
print("First: \(message.first ?? "?")")  // "H"
print("Last: \(message.last ?? "?")")    // "!"

// Get a substring (characters 0 through 4)
let start = message.startIndex
let end = message.index(start, offsetBy: 5)
let substring = message[start..<end]
print("Substring: \(substring)")  // "Hello"

// CONVENIENT EXTENSION: Add integer subscript support
extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    subscript(range: Range<Int>) -> Substring {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }
}

// Now you can use integer subscripts!
let greeting = "Hello"
print(greeting[0])      // "H"
print(greeting[1..<4])  // "ell"


// Fix 2: Use case-insensitive comparison
let userInput = "Apple"
let expected = "apple"

// Method 1: lowercased() comparison
if userInput.lowercased() == expected.lowercased() {
    print("Match!")  // Prints: "Match!"
}

// Method 2: caseInsensitiveCompare (more proper for localized strings)
if userInput.caseInsensitiveCompare(expected) == .orderedSame {
    print("Match!")  // Prints: "Match!"
}

// Method 3: Using range with .caseInsensitive option
if userInput.range(of: expected, options: .caseInsensitive) != nil {
    print("Contains match!")
}


// Fix 3: Handle emojis and Unicode correctly
let text = "Hi 👋🏽 World"

// Use .count for the number of human-visible characters
print("Character count: \(text.count)")  // Correct human-readable count

// Iterate characters safely
for (index, char) in text.enumerated() {
    print("Position \(index): \(char)")
}

// Check if a string contains emoji
extension Character {
    var isEmoji: Bool {
        // A simple heuristic
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && scalar.value > 0x238C
    }
}

for char in text {
    if char.isEmoji {
        print("\(char) is an emoji!")
    }
}


// Fix 4: Handle empty strings when splitting
let csv = "apple,,cherry,"
let items = csv.components(separatedBy: ",")

// Filter out empty strings
let cleanItems = items.filter { !$0.isEmpty }
print("Clean items: \(cleanItems)")  // ["apple", "cherry"]

// Or use split() which skips empty subsequences by default!
let betterItems = csv.split(separator: ",")
print("Better items: \(betterItems)")  // ["apple", "cherry"]

// If you WANT to keep empty strings with split:
let allItems = csv.split(separator: ",", omittingEmptySubsequences: false)
print("All items: \(allItems)")  // ["apple", "", "cherry", ""]


// Fix 5: Use functional methods instead of mutating during iteration
var text2 = "Hello, World!"

// Remove all occurrences of a character
let withoutLs = text2.filter { $0 != "l" }
print(withoutLs)  // "Heo, Word!"

// Replace characters
let replaced = text2.replacingOccurrences(of: "l", with: "L")
print(replaced)  // "HeLLo, WorLd!"

// Remove specific characters
let lettersOnly = text2.filter { $0.isLetter }
print(lettersOnly)  // "HelloWorld"


// ============================================================================
// BONUS: Useful String methods for interviews
// ============================================================================

let sample = "  Swift Programming  "

// Trim whitespace
print(sample.trimmingCharacters(in: .whitespaces))  // "Swift Programming"

// Check prefix/suffix
print("Hello".hasPrefix("He"))   // true
print("Hello".hasSuffix("lo"))   // true

// Reverse a string
let reversed = String("Hello".reversed())
print(reversed)  // "olleH"

// Check if palindrome
func isPalindrome(_ str: String) -> Bool {
    let cleaned = str.lowercased().filter { $0.isLetter }
    return cleaned == String(cleaned.reversed())
}

print(isPalindrome("racecar"))          // true
print(isPalindrome("A man a plan a canal Panama"))  // true
print(isPalindrome("hello"))            // false


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "Why can't you use integer subscripts on Swift strings?"
//    Answer: Swift strings support full Unicode. Characters can be composed
//    of multiple Unicode scalars with varying byte lengths. Integer indexing
//    would be O(n) and could split characters incorrectly.
//
// 2. "What's the difference between `.count` and `.utf16.count`?"
//    Answer: `.count` gives human-visible character count (grapheme clusters).
//    `.utf16.count` gives the number of UTF-16 code units (what NSString uses).
//
// 3. Know the difference between `String`, `Substring`, and `Character`.
//    Substring is a view into the original string (efficient, no copy).
//    Convert to String when you need to store it long-term.
//
// 4. Common interview coding tasks: reverse a string, check palindrome,
//    find anagrams, count character frequency. Practice these!
// ============================================================================
