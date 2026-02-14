/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 3: ARRAY INDEX OUT OF BOUNDS
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Beginner
 Topic: Safe Collection Access
 Common In: 85% of Swift interviews
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - CRASHES ON INVALID INDEX
// ═══════════════════════════════════════════════════════════════

class PlaylistManagerBuggy {
    var songs: [String] = ["Song A", "Song B", "Song C"]
    
    func playSong(at index: Int) {
        // 🐛 BUG: No bounds checking - crashes if index >= count
        let song = songs[index]
        print("Now playing: \(song)")
    }
    
    func getFirstSong() -> String {
        // 🐛 BUG: Crashes if array is empty
        return songs[0]
    }
    
    func getLastSong() -> String {
        // 🐛 BUG: Crashes if array is empty
        return songs[songs.count - 1]
    }
    
    func removeSongAndPlayNext(at index: Int) {
        // 🐛 BUG: Multiple issues here
        songs.remove(at: index)  // Could crash
        playSong(at: index)       // Definitely crashes if was last song
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. NO BOUNDS CHECKING:
    - Array subscript requires valid index: 0..<count
    - Accessing songs[5] when count is 3 = CRASH
    - Runtime error: "Fatal error: Index out of range"
 
 2. EMPTY ARRAY NOT HANDLED:
    - songs[0] crashes if songs.isEmpty
    - songs[songs.count - 1] crashes if empty (count - 1 = -1)
 
 3. LOGIC ERROR IN removeSongAndPlayNext:
    - After removing song at index 3, array has 3 items (indices 0-2)
    - Trying to play index 3 = CRASH
    - Should play index (index) which is now the next song
 
 4. NO ERROR COMMUNICATION:
    - Methods don't tell caller if operation failed
    - Just crash instead of returning optional or throwing error
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Bounds Checking + Optionals
// ═══════════════════════════════════════════════════════════════

class PlaylistManagerFixed1 {
    var songs: [String] = ["Song A", "Song B", "Song C"]
    
    func playSong(at index: Int) {
        // ✅ Check bounds before accessing
        guard index >= 0 && index < songs.count else {
            print("Invalid index: \(index)")
            return
        }
        
        let song = songs[index]
        print("Now playing: \(song)")
    }
    
    func getFirstSong() -> String? {
        // ✅ Use .first property (returns optional)
        return songs.first
    }
    
    func getLastSong() -> String? {
        // ✅ Use .last property (returns optional)
        return songs.last
    }
    
    func removeSongAndPlayNext(at index: Int) {
        guard index >= 0 && index < songs.count else {
            print("Cannot remove: Invalid index")
            return
        }
        
        songs.remove(at: index)
        
        // ✅ After removal, check if there's a song at that position
        if index < songs.count {
            playSong(at: index)  // Play the song that moved into this position
        } else {
            print("No more songs to play")
        }
    }
}


// ✅ FIXED CODE - SOLUTION 2: Using indices Property
// ═══════════════════════════════════════════════════════════════

class PlaylistManagerFixed2 {
    var songs: [String] = ["Song A", "Song B", "Song C"]
    
    func playSong(at index: Int) {
        // ✅ Check if index is in valid range using indices
        guard songs.indices.contains(index) else {
            print("Invalid index: \(index)")
            return
        }
        
        let song = songs[index]
        print("Now playing: \(song)")
    }
    
    func getSong(at index: Int) -> String? {
        // ✅ Elegant one-liner
        return songs.indices.contains(index) ? songs[index] : nil
    }
}


// ✅ FIXED CODE - SOLUTION 3: Safe Array Extension
// ═══════════════════════════════════════════════════════════════

extension Array {
    // ✅ Add safe subscript that returns optional
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class PlaylistManagerFixed3 {
    var songs: [String] = ["Song A", "Song B", "Song C"]
    
    func playSong(at index: Int) {
        // ✅ Use safe subscript
        if let song = songs[safe: index] {
            print("Now playing: \(song)")
        } else {
            print("Invalid index: \(index)")
        }
    }
    
    func getFirstSong() -> String? {
        return songs[safe: 0]  // Returns nil if empty
    }
    
    func getLastSong() -> String? {
        return songs[safe: songs.count - 1]  // Returns nil if empty
    }
}


// ✅ FIXED CODE - SOLUTION 4: Error Throwing
// ═══════════════════════════════════════════════════════════════

enum PlaylistError: Error {
    case indexOutOfBounds(index: Int, count: Int)
    case emptyPlaylist
    
    var localizedDescription: String {
        switch self {
        case .indexOutOfBounds(let index, let count):
            return "Index \(index) is out of bounds for playlist with \(count) songs"
        case .emptyPlaylist:
            return "Playlist is empty"
        }
    }
}

class PlaylistManagerFixed4 {
    var songs: [String] = ["Song A", "Song B", "Song C"]
    
    func playSong(at index: Int) throws {
        // ✅ Throw error instead of crashing
        guard index >= 0 && index < songs.count else {
            throw PlaylistError.indexOutOfBounds(index: index, count: songs.count)
        }
        
        let song = songs[index]
        print("Now playing: \(song)")
    }
    
    func getFirstSong() throws -> String {
        guard !songs.isEmpty else {
            throw PlaylistError.emptyPlaylist
        }
        return songs[0]
    }
}


// ✅ ADVANCED: Iterator Pattern
// ═══════════════════════════════════════════════════════════════

class PlaylistManagerAdvanced {
    private var songs: [String] = ["Song A", "Song B", "Song C"]
    private var currentIndex = 0
    
    func playCurrentSong() {
        guard let song = songs[safe: currentIndex] else {
            print("No song at current index")
            return
        }
        print("Now playing: \(song)")
    }
    
    func playNext() -> Bool {
        currentIndex += 1
        if currentIndex < songs.count {
            playCurrentSong()
            return true
        } else {
            print("End of playlist")
            return false
        }
    }
    
    func playPrevious() -> Bool {
        currentIndex -= 1
        if currentIndex >= 0 {
            playCurrentSong()
            return true
        } else {
            currentIndex = 0
            print("Already at first song")
            return false
        }
    }
    
    func shuffle() {
        songs.shuffle()
        currentIndex = 0
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. ALWAYS CHECK BOUNDS:
    - Use indices.contains(index) for clarity
    - Use index >= 0 && index < count for performance
    - Never assume array has elements
 
 2. SAFE ACCESSORS:
    - .first and .last return optionals (safe for empty arrays)
    - Create custom [safe: index] subscript for repeated use
    - Consider making extension for all Collections
 
 3. ERROR HANDLING STRATEGIES:
    - Return Optional: Simple, caller decides what to do with nil
    - Guard + Return: Good for void methods
    - Throw Error: Best for recoverable errors with context
    - Assert/Precondition: For programmer errors in debug mode
 
 4. COMMON PITFALLS:
    - Off-by-one errors (count vs count-1)
    - Assuming array isn't empty
    - Index becomes invalid after removal
    - Negative indices crash (unlike Python)
 
 5. COLLECTION SAFETY:
    - Works for all Collections, not just Array
    - Dictionary subscript returns Optional (safer than Array)
    - Set has no indices (use contains instead)
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "I see we're accessing the array without bounds checking. This will crash 
    if the index is out of range."
 
 2. "For empty array safety, I'd use .first or .last instead of [0] or 
    [count-1] since they return optionals."
 
 3. "I'd add bounds checking using indices.contains(index) or create a safe 
    subscript extension for cleaner code."
 
 4. "After removing an element, the indices shift, so we need to recheck 
    before accessing."
 
 5. "Depending on the API design, I might return an Optional, throw an error, 
    or use assertions. What's the expected behavior here?"
 
 BONUS POINTS:
 ✅ Mention .first, .last, .dropFirst(), .dropLast()
 ✅ Discuss enumerated() for index + element iteration
 ✅ Know the difference between removeFirst() and remove(at: 0)
 ✅ Understand Array is value type (copied on mutation in some cases)
 
 RED FLAGS:
 ❌ "I'll just make sure to never pass invalid indices"
 ❌ Using try! or force unwrapping without explanation
 ❌ Not considering empty array case
 ❌ Off-by-one errors
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample3() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 3: ARRAY INDEX OUT OF BOUNDS")
    print("═══════════════════════════════════════════════════════\n")
    
    print("❌ BUGGY VERSION:")
    let buggyPlaylist = PlaylistManagerBuggy()
    buggyPlaylist.playSong(at: 0)  // Works
    buggyPlaylist.playSong(at: 1)  // Works
    // buggyPlaylist.playSong(at: 10) // ⚠️ CRASHES! Uncomment to see
    print("(Crash avoided by commenting out invalid index)\n")
    
    print("✅ FIXED VERSION 1 (Bounds checking):")
    let playlist1 = PlaylistManagerFixed1()
    playlist1.playSong(at: 0)
    playlist1.playSong(at: 10)  // Handles gracefully
    if let first = playlist1.getFirstSong() {
        print("First song: \(first)")
    }
    print()
    
    print("✅ FIXED VERSION 2 (indices.contains):")
    let playlist2 = PlaylistManagerFixed2()
    playlist2.playSong(at: 2)
    playlist2.playSong(at: 5)  // Handles gracefully
    print()
    
    print("✅ FIXED VERSION 3 (Safe subscript):")
    let playlist3 = PlaylistManagerFixed3()
    playlist3.playSong(at: 1)
    playlist3.playSong(at: 100)  // Handles gracefully
    print()
    
    print("✅ FIXED VERSION 4 (Error throwing):")
    let playlist4 = PlaylistManagerFixed4()
    do {
        try playlist4.playSong(at: 0)
        try playlist4.playSong(at: 10)  // Throws error
    } catch let error as PlaylistError {
        print("Error: \(error.localizedDescription)")
    } catch {
        print("Unexpected error: \(error)")
    }
    print()
    
    print("✅ ADVANCED VERSION (Iterator pattern):")
    let advancedPlaylist = PlaylistManagerAdvanced()
    advancedPlaylist.playCurrentSong()
    advancedPlaylist.playNext()
    advancedPlaylist.playNext()
    advancedPlaylist.playNext()  // End of playlist
    print()
}

// Uncomment to run:
// runExample3()
