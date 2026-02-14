/*
 ============================================
 EXAMPLE 8: STRING MANIPULATION BUGS
 ============================================
 
 Common Issue: Incorrect string indexing and Unicode handling
 Apple Interview Focus: String vs NSString, Unicode, indices
 */

import Foundation

// ❌ BUGGY CODE - String Manipulation Issues!

class BuggyStringHandler {
    
    func getFirstCharacter() {
        let text = "Hello"
        
        // 🐛 BUG: Strings don't use integer indices like arrays
        // let first = text[0]  // ❌ Compile error!
        
        // This compiles but is wrong:
        // let index = text.index(text.startIndex, offsetBy: 0)
        // let first = text[index]  // Works, but overly complex
    }
    
    func getSubstring() {
        let text = "Hello, World!"
        
        // 🐛 BUG: Can't use range with integers
        // let sub = text[0...4]  // ❌ Compile error!
        
        // This might crash with emojis or special characters:
        let nsString = text as NSString
        let sub = nsString.substring(with: NSRange(location: 0, length: 5))
        print(sub)  // Works for ASCII, but wrong for emoji!
    }
    
    func handleEmoji() {
        let text = "Hello 👨‍👩‍👧‍👦 World"  // Family emoji is 1 character but many bytes
        
        // 🐛 BUG: Using count incorrectly
        print("Characters: \(text.count)")  // Correct: 13
        
        let nsString = text as NSString
        print("NSString length: \(nsString.length)")  // Wrong: 20!
        
        // 🐛 BUG: Substring with NSString breaks emoji
        let broken = nsString.substring(with: NSRange(location: 0, length: 8))
        print("Broken: \(broken)")  // 💥 Might split emoji in half!
    }
    
    func iterateWrong() {
        let text = "Swift"
        
        // 🐛 BUG: Can't iterate with integer indices
        // for i in 0..<text.count {
        //     print(text[i])  // ❌ Compile error!
        // }
    }
    
    func removeCharacterUnsafe() {
        var text = "Hello"
        
        // 🐛 BUG: Assuming string isn't empty
        text.removeFirst()  // 💥 Crashes if string is empty!
        print(text)
    }
    
    func splitWithoutValidation() {
        let csv = "name,age,city"
        let parts = csv.split(separator: ",")
        
        // 🐛 BUG: Assuming exactly 3 parts
        let name = parts[0]
        let age = parts[1]
        let city = parts[2]
        let country = parts[3]  // 💥 Index out of bounds!
        
        print("\(name), \(age), \(city), \(country)")
    }
}

// Examples of issues
func demonstrateBug() {
    print("=== STRING MANIPULATION BUGS ===\n")
    
    let handler = BuggyStringHandler()
    
    print("--- Emoji handling issue ---")
    handler.handleEmoji()
    
    print("\n⚠️  Other crashes prevented by commenting out buggy code\n")
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Print string.count vs (string as NSString).length
 2. Visualize with print(Array(string)) to see characters
 3. Check for empty strings before manipulation
 4. Use string.isEmpty instead of string.count == 0
 5. Debug Unicode with: print(string.unicodeScalars)
 6. Use Xcode's Quick Look to view string contents
 */

// ✅ FIXED CODE - Safe String Manipulation

class FixedStringHandler {
    
    // SOLUTION 1: Safe character access
    func getFirstCharacter_Safe() {
        let text = "Hello"
        
        // Method 1: Use .first property
        if let first = text.first {
            print("First character: \(first)")
        }
        
        // Method 2: Use string index
        if !text.isEmpty {
            let firstChar = text[text.startIndex]
            print("First: \(firstChar)")
        }
        
        // Getting last character
        if let last = text.last {
            print("Last character: \(last)")
        }
    }
    
    // SOLUTION 2: Safe substring extraction
    func getSubstring_Safe() {
        let text = "Hello, World!"
        
        // Method 1: Using prefix/suffix
        let first5 = text.prefix(5)
        print("First 5: \(first5)")  // "Hello"
        
        let last6 = text.suffix(6)
        print("Last 6: \(last6)")  // "World!"
        
        // Method 2: Using string indices
        if let endIndex = text.index(text.startIndex, offsetBy: 5, limitedBy: text.endIndex) {
            let sub = text[text.startIndex..<endIndex]
            print("Substring: \(sub)")
        }
        
        // Method 3: Using range
        if let range = text.range(of: "World") {
            let word = text[range]
            print("Found: \(word)")
        }
    }
    
    // SOLUTION 3: Proper emoji handling
    func handleEmoji_Safe() {
        let text = "Hello 👨‍👩‍👧‍👦 World"
        
        // ✅ Correct: Use Swift String methods
        print("Character count: \(text.count)")  // 13
        
        // Iterate over characters properly
        for (index, char) in text.enumerated() {
            print("\(index): \(char)")
        }
        
        // Safe prefix that respects character boundaries
        let first = text.prefix(8)
        print("First 8 chars: \(first)")  // Won't break emoji!
    }
    
    // SOLUTION 4: Safe iteration
    func iterate_Safe() {
        let text = "Swift"
        
        // Method 1: Iterate over characters
        for char in text {
            print(char)
        }
        
        // Method 2: Enumerated for index + character
        for (index, char) in text.enumerated() {
            print("\(index): \(char)")
        }
        
        // Method 3: Using indices
        for index in text.indices {
            print(text[index])
        }
    }
    
    // SOLUTION 5: Safe character removal
    func removeCharacter_Safe() {
        var text = "Hello"
        
        // Check if not empty
        if !text.isEmpty {
            text.removeFirst()
            print("After removing first: \(text)")
        }
        
        // Alternative: Use dropFirst (doesn't mutate)
        let text2 = "Hello"
        let withoutFirst = text2.dropFirst()
        print("Without first: \(withoutFirst)")
    }
    
    // SOLUTION 6: Safe string splitting
    func splitWithValidation() {
        let csv = "name,age,city"
        let parts = csv.split(separator: ",")
        
        // Validate before accessing
        guard parts.count >= 3 else {
            print("❌ Invalid CSV format")
            return
        }
        
        let name = parts[0]
        let age = parts[1]
        let city = parts[2]
        
        print("Name: \(name), Age: \(age), City: \(city)")
        
        // Safe access to optional field
        let country = parts.count > 3 ? String(parts[3]) : "Unknown"
        print("Country: \(country)")
    }
    
    // SOLUTION 7: String validation
    func validateAndProcess(_ input: String) {
        // Check if empty
        guard !input.isEmpty else {
            print("❌ Input is empty")
            return
        }
        
        // Check minimum length
        guard input.count >= 3 else {
            print("❌ Input too short")
            return
        }
        
        // Safe processing
        let first = input.prefix(3)
        print("First 3 characters: \(first)")
    }
    
    // SOLUTION 8: Character-aware truncation
    func truncate(_ text: String, to maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        
        let truncated = text.prefix(maxLength)
        return truncated + "..."
    }
    
    // SOLUTION 9: Safe character replacement
    func replaceCharacters() {
        let text = "Hello, World!"
        
        // Replace all occurrences
        let replaced = text.replacingOccurrences(of: "o", with: "0")
        print("Replaced: \(replaced)")
        
        // Replace with range
        if let range = text.range(of: "World") {
            var mutable = text
            mutable.replaceSubrange(range, with: "Swift")
            print("Modified: \(mutable)")
        }
    }
    
    // SOLUTION 10: Unicode-safe operations
    func unicodeOperations() {
        let flag = "🇺🇸"  // US flag: actually 2 unicode scalars
        
        print("Characters: \(flag.count)")  // 1 (correct)
        print("Unicode scalars: \(flag.unicodeScalars.count)")  // 2
        print("UTF-8 code units: \(flag.utf8.count)")  // 8
        
        // Iterate unicode scalars
        for scalar in flag.unicodeScalars {
            print("Scalar: \(scalar) (\(scalar.value))")
        }
    }
}

// String extensions for common safe operations
extension String {
    // Safe subscript with integer (use with caution)
    subscript(safe offset: Int) -> Character? {
        guard offset >= 0, offset < count else { return nil }
        return self[index(startIndex, offsetBy: offset)]
    }
    
    // Safe substring
    func substring(from: Int, to: Int) -> String? {
        guard from >= 0, to >= from, to <= count else { return nil }
        
        let startIdx = index(startIndex, offsetBy: from)
        let endIdx = index(startIndex, offsetBy: to)
        
        return String(self[startIdx..<endIdx])
    }
    
    // Check if contains only alphanumeric
    var isAlphanumeric: Bool {
        return !isEmpty && allSatisfy { $0.isLetter || $0.isNumber }
    }
    
    // Safe trim
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Common string patterns
class StringPatterns {
    
    // Email validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    // Parse key-value pairs
    func parseKeyValue(_ input: String) -> [String: String] {
        var result: [String: String] = [:]
        
        let pairs = input.split(separator: "&")
        for pair in pairs {
            let components = pair.split(separator: "=", maxSplits: 1)
            guard components.count == 2 else { continue }
            
            let key = String(components[0])
            let value = String(components[1])
            result[key] = value
        }
        
        return result
    }
    
    // Word count (Unicode-aware)
    func wordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== SAFE STRING MANIPULATION ===\n")
    
    let handler = FixedStringHandler()
    
    print("--- Safe character access ---")
    handler.getFirstCharacter_Safe()
    
    print("\n--- Safe substring ---")
    handler.getSubstring_Safe()
    
    print("\n--- Proper emoji handling ---")
    handler.handleEmoji_Safe()
    
    print("\n--- Safe iteration ---")
    handler.iterate_Safe()
    
    print("\n--- Safe removal ---")
    handler.removeCharacter_Safe()
    
    print("\n--- Safe splitting ---")
    handler.splitWithValidation()
    
    print("\n--- String validation ---")
    handler.validateAndProcess("Hello")
    handler.validateAndProcess("Hi")
    handler.validateAndProcess("")
    
    print("\n--- Truncation ---")
    print(handler.truncate("This is a very long string", to: 10))
    
    print("\n--- Unicode operations ---")
    handler.unicodeOperations()
    
    print("\n--- Extension examples ---")
    let text = "Hello, World!"
    print("Character at 7: \(text[safe: 7] ?? Character(" "))")
    print("Substring 7-12: \(text.substring(from: 7, to: 12) ?? "")")
    
    print("\n--- Pattern examples ---")
    let patterns = StringPatterns()
    print("Valid email: \(patterns.isValidEmail("test@apple.com"))")
    print("Invalid email: \(patterns.isValidEmail("invalid"))")
    
    let kvPairs = patterns.parseKeyValue("name=Alice&age=25&city=Cupertino")
    print("Parsed: \(kvPairs)")
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. Swift Strings are NOT arrays - they use String.Index
 2. Use .first and .last for first/last characters
 3. Use prefix() and suffix() for substrings
 4. String.count counts Characters (grapheme clusters), not bytes
 5. NSString.length counts UTF-16 code units (wrong for emoji!)
 6. Always check isEmpty before removing characters
 7. Use components(separatedBy:) or split() safely
 
 🎯 STRING ACCESS PATTERNS:
 
 // ❌ WRONG
 let char = string[0]              // Compile error
 let sub = string[0...4]           // Compile error
 string.removeFirst()              // Crashes if empty
 
 // ✅ CORRECT
 let char = string.first           // Optional<Character>
 let sub = string.prefix(5)        // Safe
 if !string.isEmpty {
     string.removeFirst()          // Safe
 }
 
 ⚠️  COMMON STRING MISTAKES:
 
 1. Treating strings like arrays (string[0])
 2. Using NSString for Unicode text
 3. Not handling empty strings
 4. Splitting without validation
 5. Breaking emoji/Unicode characters
 6. Using .count for byte size (use .utf8.count)
 
 💡 BEST PRACTICES:
 
 // Getting characters
 let first = string.first          // ✅ Safe
 let last = string.last            // ✅ Safe
 
 // Substrings
 let prefix = string.prefix(5)     // ✅ Safe
 let suffix = string.suffix(5)     // ✅ Safe
 let drop = string.dropFirst()     // ✅ Safe, returns Substring
 
 // Checking
 if string.isEmpty { }             // ✅ Better than count == 0
 if string.contains("word") { }    // ✅ Search
 
 // Iteration
 for char in string { }            // ✅ Over characters
 for index in string.indices { }   // ✅ Over indices
 
 🛠️  STRING VS SUBSTRING:
 
 - prefix(), suffix(), dropFirst() return Substring
 - Substring shares memory with original (efficient)
 - Convert to String when storing: String(substring)
 - Be aware of memory implications
 
 ⚡ INTERVIEW TOPICS:
 
 - String is a value type (struct)
 - Character can be multiple Unicode scalars
 - Grapheme clusters vs Unicode scalars
 - UTF-8, UTF-16, UTF-32 encodings
 - NSString vs String bridging
 - String interpolation
 - Regular expressions
 
 🎓 ADVANCED STRING CONCEPTS:
 
 // Unicode concepts
 "café".count                      // 4 characters
 "café".unicodeScalars.count       // 4 or 5 (é = e + ́)
 "café".utf8.count                 // Bytes: varies
 
 // Grapheme clusters
 "👨‍👩‍👧‍👦".count                      // 1 character!
 "👨‍👩‍👧‍👦".unicodeScalars.count       // 7 scalars!
 
 // String indices
 let index = string.index(string.startIndex, offsetBy: 5)
 let char = string[index]
 
 // Range operations
 if let range = string.range(of: "pattern") {
     let match = string[range]
     string.replaceSubrange(range, with: "new")
 }
 */

// Run demonstrations
print("🐛 BUGGY VERSION:")
demonstrateBug()

print("\n" + String(repeating: "=", count: 50) + "\n")
demonstrateFix()
