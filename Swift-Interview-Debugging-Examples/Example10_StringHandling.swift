// =============================================================================
// EXAMPLE 10: String and Substring Handling
// =============================================================================
// Difficulty: Intermediate
// Topic:      Strings, Unicode, String.Index, Substrings
//
// SCENARIO:
// You are building a text processing utility. The code tries to manipulate
// strings using integer indices (like in C or Python). This doesn't work in
// Swift because Swift strings are Unicode-aware and don't support integer
// subscripting.
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

func getCharacterAtIndexBuggy(string: String, index: Int) -> Character {
    // BUG: Swift strings do NOT support integer subscripting!
    // This code will NOT compile:
    // return string[index]  // ERROR: 'subscript(_:)' is unavailable

    // Some developers try this "fix" which is INEFFICIENT:
    let characters = Array(string)  // Converts entire string to array — O(n)!
    return characters[index]        // Then uses integer index — and can crash!
}

func reverseSentenceBuggy(sentence: String) -> String {
    // BUG: This reverses the CHARACTERS, not the WORDS.
    // "Hello World" becomes "dlroW olleH" instead of "World Hello"
    return String(sentence.reversed())
}

func truncateBuggy(string: String, maxLength: Int) -> String {
    // BUG: Using .count for comparison but then trying to subscript with Int
    if string.count <= maxLength {
        return string
    }
    // This won't compile: string[0..<maxLength]
    // And this is wasteful: String(Array(string)[0..<maxLength])
    let arr = Array(string)
    return String(arr[0..<maxLength]) + "..."
}

func demoBuggy() {
    let greeting = "Hello, World!"

    print("Character at index 7: \(getCharacterAtIndexBuggy(string: greeting, index: 7))")
    // Works but is O(n) — creates a whole array just to get one character!

    let sentence = "Hello World"
    print("Reversed sentence: \(reverseSentenceBuggy(sentence: sentence))")
    // Prints "dlroW olleH" instead of "World Hello"

    let longText = "This is a very long piece of text that should be truncated"
    print("Truncated: \(truncateBuggy(string: longText, maxLength: 20))")
    // Works but is inefficient — converts to Array first
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// Swift strings are different from most other languages:
//
// 1. NO INTEGER SUBSCRIPTING: string[5] does NOT work.
//    Why? Because Swift strings are Unicode-aware. Characters like "é" or
//    "👨‍👩‍👧‍👦" may be composed of multiple Unicode scalars. An integer index
//    would be misleading — is it counting bytes? Scalars? Characters?
//
// 2. String.Index: Swift uses opaque String.Index values instead of integers.
//    You must use string.startIndex, string.index(after:), etc.
//
// 3. PERFORMANCE: Converting to Array(string) is O(n) and allocates memory.
//    Swift's String.Index approach is designed for efficient traversal.
//
// 4. Logic bugs: Reversing characters vs reversing words are different
//    operations. Read the requirements carefully!
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Proper Swift string handling
// ─────────────────────────────────────────────────────────────────────────────

// FIX 1: Access characters using String.Index
func getCharacterAtIndexFixed(string: String, index: Int) -> Character? {
    // Safety check
    guard index >= 0 && index < string.count else {
        return nil
    }
    // Use String.Index to navigate to the correct position
    let stringIndex = string.index(string.startIndex, offsetBy: index)
    return string[stringIndex]
}

// You can also create a handy extension:
extension String {
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    // Safe substring using integer range
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0 && range.upperBound <= count else { return nil }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}

// FIX 2: Reverse WORDS, not characters
func reverseSentenceFixed(sentence: String) -> String {
    // Split into words, reverse the array, then join back
    let words = sentence.split(separator: " ")
    let reversed = words.reversed()
    return reversed.joined(separator: " ")

    // Or in one line:
    // return sentence.split(separator: " ").reversed().joined(separator: " ")
}

// FIX 3: Proper string truncation using String.Index
func truncateFixed(string: String, maxLength: Int) -> String {
    guard string.count > maxLength else {
        return string
    }
    // Use prefix() — the most Swifty approach
    return String(string.prefix(maxLength)) + "..."
}

func demoFixed() {
    let greeting = "Hello, World!"

    // Safe character access
    print("--- Character Access ---")
    if let char = getCharacterAtIndexFixed(string: greeting, index: 7) {
        print("Character at index 7: \(char)")  // "W"
    }
    print("Using extension: \(greeting[safe: 0] ?? "?")")   // "H"
    print("Out of bounds: \(greeting[safe: 99] ?? "?")")     // "?" (safe!)

    // Reverse words
    print("\n--- Reverse Words ---")
    let sentence = "Hello World"
    print("Reversed words: \(reverseSentenceFixed(sentence: sentence))")
    // "World Hello" ✓

    // Proper truncation
    print("\n--- Truncation ---")
    let longText = "This is a very long piece of text that should be truncated"
    print("Truncated: \(truncateFixed(string: longText, maxLength: 20))")
    // "This is a very long ..."

    // Working with Unicode
    print("\n--- Unicode ---")
    let emoji = "Hello 👋🏽"
    print("Count: \(emoji.count)")        // 7 (counts grapheme clusters correctly)
    print("UTF-8 count: \(emoji.utf8.count)")  // More than 7 (multi-byte characters)
    print("First: \(emoji[safe: 0] ?? "?")")   // "H"
    print("Last: \(emoji[safe: 6] ?? "?")")    // "👋🏽"

    // Useful String methods to know for interviews
    print("\n--- Useful String Methods ---")
    let text = "  Hello, Swift Developer!  "
    print("Trimmed: '\(text.trimmingCharacters(in: .whitespaces))'")
    print("Lowercase: \(text.lowercased())")
    print("Contains: \(text.contains("Swift"))")
    print("Starts with: \(text.hasPrefix("  Hello"))")
    print("Ends with: \(text.hasSuffix("!  "))")
    print("Replace: \(text.replacingOccurrences(of: "Swift", with: "iOS"))")
    print("Split: \(text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })")
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Swift strings do NOT support integer subscripting (string[5]).
//    Use String.Index: string.index(string.startIndex, offsetBy: 5)
//
// 2. Use .prefix(n), .suffix(n), .dropFirst(n), .dropLast(n) for common
//    substring operations — they are efficient and readable.
//
// 3. string.count counts GRAPHEME CLUSTERS (user-perceived characters).
//    "👨‍👩‍👧‍👦".count == 1 (one family emoji, even though it's many scalars).
//
// 4. Use .split(separator:) to break strings into substrings.
//    Use .components(separatedBy:) from Foundation for more options.
//
// 5. Substring (type returned by string[range]) shares memory with the
//    original string. Convert to String() if you need an independent copy.
//
// 6. Common interview string problems:
//    - Reverse words in a sentence (not characters!)
//    - Check for palindrome
//    - Find first non-repeating character
//    - Validate parentheses
//    All of these require understanding Swift's String API.
//
// 7. Performance: Iterating through characters is O(n) because grapheme
//    cluster boundaries must be computed. Random access is O(n), not O(1).
//    If you need O(1) random access, consider converting to Array<Character>.
// ─────────────────────────────────────────────────────────────────────────────
