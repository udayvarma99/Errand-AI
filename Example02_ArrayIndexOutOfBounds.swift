/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 2: ARRAY INDEX OUT OF BOUNDS
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Safe array access patterns
 Common Interview Question: "How do you safely access array elements?"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

class PlaylistManagerBuggy {
    var songs: [String] = []
    
    func addSong(_ song: String) {
        songs.append(song)
    }
    
    // BUG: Accessing array without bounds checking
    func getFirstSong() -> String {
        return songs[0]  // 💥 CRASH if array is empty
    }
    
    func getLastSong() -> String {
        return songs[songs.count - 1]  // 💥 CRASH if array is empty
    }
    
    func getSongAt(index: Int) -> String {
        return songs[index]  // 💥 CRASH if index out of bounds
    }
    
    func removeSongAt(index: Int) {
        songs.remove(at: index)  // 💥 CRASH if index invalid
    }
}

// Test case that will crash:
// let playlist = PlaylistManagerBuggy()
// let song = playlist.getFirstSong()  // 💥 Fatal error: Index out of range


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Array index out of bounds is a common crash in Swift. It happens when:
 1. Accessing an empty array with [0]
 2. Using an index >= array.count
 3. Using negative indices (Swift doesn't support negative indexing)
 4. Using count - 1 on an empty array (0 - 1 = -1, which is invalid)
 
 Unlike some languages, Swift arrays don't return nil for invalid indices
 - they crash immediately!
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Check if the array could be empty
 2. Verify the index is within valid range: 0 ..< array.count
 3. Look for operations that modify array size during iteration
 4. Use Xcode's runtime sanitizers
 5. Add assertions in debug builds
 
 LLDB Commands:
 - breakpoint set -f Example02.swift -l 19
 - po songs.count
 - po index
 - expr songs.indices.contains(index)
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

class PlaylistManagerFixed {
    var songs: [String] = []
    
    func addSong(_ song: String) {
        songs.append(song)
    }
    
    // SOLUTION 1: Using first and last properties (return Optional)
    func getFirstSong_Solution1() -> String? {
        return songs.first  // Returns nil if empty
    }
    
    func getLastSong_Solution1() -> String? {
        return songs.last  // Returns nil if empty
    }
    
    // SOLUTION 2: Using isEmpty check
    func getFirstSong_Solution2() -> String? {
        guard !songs.isEmpty else { return nil }
        return songs[0]
    }
    
    // SOLUTION 3: Using indices.contains for arbitrary index
    func getSongAt_Solution3(index: Int) -> String? {
        guard songs.indices.contains(index) else {
            return nil
        }
        return songs[index]
    }
    
    // SOLUTION 4: Using safe subscript extension (best practice)
    func getSongAt_Solution4(index: Int) -> String? {
        return songs[safe: index]
    }
    
    // SOLUTION 5: Safe removal with validation
    func removeSongAt(index: Int) -> Bool {
        guard songs.indices.contains(index) else {
            print("⚠️ Invalid index: \(index). Array has \(songs.count) elements.")
            return false
        }
        songs.remove(at: index)
        return true
    }
    
    // SOLUTION 6: Using count check (less elegant than indices)
    func getSongAt_Solution6(index: Int) -> String? {
        guard index >= 0 && index < songs.count else {
            return nil
        }
        return songs[index]
    }
}


// 🔧 SAFE SUBSCRIPT EXTENSION (Recommended Pattern)
// ═══════════════════════════════════════════════════════════════════

extension Array {
    // Add safe subscript that returns nil instead of crashing
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Now you can safely access any array:
// let value = myArray[safe: 10]  // Returns nil if index 10 doesn't exist


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

func runExample02() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 2: ARRAY INDEX OUT OF BOUNDS")
    print("═══════════════════════════════════════════════════════\n")
    
    let playlist = PlaylistManagerFixed()
    
    // Test Case 1: Empty array
    print("Test Case 1: Empty Playlist")
    print("First song: \(playlist.getFirstSong_Solution1() ?? "No songs available")")
    print("Last song: \(playlist.getLastSong_Solution1() ?? "No songs available")")
    
    print("\n" + String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Add songs and access
    print("Test Case 2: Playlist with Songs")
    playlist.addSong("Bohemian Rhapsody")
    playlist.addSong("Stairway to Heaven")
    playlist.addSong("Hotel California")
    
    print("First song: \(playlist.getFirstSong_Solution1() ?? "None")")
    print("Last song: \(playlist.getLastSong_Solution1() ?? "None")")
    print("Song at index 1: \(playlist.getSongAt_Solution3(index: 1) ?? "None")")
    
    print("\n" + String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Invalid indices
    print("Test Case 3: Invalid Index Access")
    print("Song at index -1: \(playlist.getSongAt_Solution3(index: -1) ?? "Invalid index")")
    print("Song at index 100: \(playlist.getSongAt_Solution4(index: 100) ?? "Invalid index")")
    
    print("\n" + String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Safe removal
    print("Test Case 4: Safe Removal")
    print("Remove at index 1: \(playlist.removeSongAt(index: 1) ? "Success" : "Failed")")
    print("Remove at index 100: \(playlist.removeSongAt(index: 100) ? "Success" : "Failed")")
    print("Remaining songs: \(playlist.songs)")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Arrays in Swift crash on invalid indices - they don't return nil
 
 2. Safe access methods:
    - array.first / array.last (returns Optional)
    - array.indices.contains(index) (check before access)
    - Custom safe subscript extension
    - isEmpty check before accessing [0]
    
 3. Common patterns that cause crashes:
    - array[0] without checking isEmpty
    - array[array.count - 1] on empty array
    - Using invalid indices from user input
    - Off-by-one errors in loops
    
 4. Best practices:
    - Always validate indices before access
    - Use first/last instead of [0] and [count-1]
    - Create safe subscript extensions
    - Use array.indices for iteration
    
 5. When accessing by index:
    - Prefer: for (index, element) in array.enumerated()
    - Over: for i in 0..<array.count
    
 6. Interview Tip: Mention that Swift is bounds-checked for safety,
    unlike C/C++ where out-of-bounds access causes undefined behavior
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between array[0] and array.first?"
 A1: array[0] crashes if empty, while array.first returns an Optional
     that's nil if empty. first is safer for unknown array states.
 
 Q2: "How would you safely iterate over an array while removing elements?"
 A2: Iterate in reverse (for i in array.indices.reversed()) or use
     filter/removeAll(where:) to avoid index shifting issues.
 
 Q3: "What's the time complexity of checking array.indices.contains(index)?"
 A3: O(1) - indices is a range, so contains is a simple comparison,
     not a linear search.
 
 Q4: "How do you handle user input that could be an invalid index?"
 A4: Validate with indices.contains() or use a safe subscript. Never
     trust user input directly for array access.
*/


// 💡 ADVANCED PATTERN: Functional Safe Access
// ═══════════════════════════════════════════════════════════════════

extension Collection {
    // Generic safe subscript for any Collection
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Works with Arrays, Strings, and other Collections:
let numbers = [1, 2, 3, 4, 5]
let safeValue = numbers[safe: 10]  // nil

let text = "Hello"
let safeChar = text[safe: text.startIndex]  // Optional("H")


// Uncomment to run:
// runExample02()
