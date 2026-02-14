/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 4: MUTATING STRUCT METHODS
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Value Types vs Reference Types
 Common In: 75% of Swift interviews (Key Swift concept)
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - COMPILER ERRORS
// ═══════════════════════════════════════════════════════════════

struct PlayerBuggy {
    var name: String
    var score: Int
    var level: Int
    
    // 🐛 BUG: Missing 'mutating' keyword
    // Compiler error: "Cannot assign to property: 'self' is immutable"
    func increaseScore(by points: Int) {
        // score += points  // ⚠️ Compiler error!
        // This won't compile - uncomment to see error
    }
    
    func levelUp() {
        // level += 1  // ⚠️ Compiler error!
    }
    
    // 🐛 BUG: Trying to modify self without mutating
    func reset() {
        // self = PlayerBuggy(name: name, score: 0, level: 1)  // ⚠️ Error!
    }
}

struct GameStateBuggy {
    var players: [PlayerBuggy]
    
    func addPlayer(name: String) {
        // 🐛 BUG: Can't modify array in non-mutating method
        // players.append(PlayerBuggy(name: name, score: 0, level: 1))  // ⚠️ Error!
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. STRUCT = VALUE TYPE:
    - Structs are immutable by default
    - Methods can't modify properties unless marked 'mutating'
    - This is by design to prevent accidental mutations
 
 2. MISSING 'mutating' KEYWORD:
    - Any method that modifies struct properties MUST be mutating
    - This includes: changing properties, modifying arrays/dictionaries, replacing self
 
 3. CONSEQUENCES:
    - Code won't compile (good! Caught at compile time)
    - Developers coming from other languages often confused
    - Common mistake for beginners
 
 4. WHY SWIFT DOES THIS:
    - Value semantics make code predictable
    - Explicit mutation prevents bugs
    - Thread safety benefits
    - Functional programming principles
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Add mutating Keyword
// ═══════════════════════════════════════════════════════════════

struct PlayerFixed1 {
    var name: String
    var score: Int
    var level: Int
    
    // ✅ Add 'mutating' to modify properties
    mutating func increaseScore(by points: Int) {
        score += points
    }
    
    mutating func levelUp() {
        level += 1
        print("\(name) leveled up to level \(level)!")
    }
    
    mutating func reset() {
        score = 0
        level = 1
    }
    
    // ✅ Can also replace entire self
    mutating func resetCompletely() {
        self = PlayerFixed1(name: name, score: 0, level: 1)
    }
    
    // ✅ Non-mutating methods don't need the keyword
    func displayStats() {
        print("\(name): Level \(level), Score \(score)")
    }
}


// ✅ FIXED CODE - SOLUTION 2: Understanding Let vs Var
// ═══════════════════════════════════════════════════════════════

struct GameStateFixed {
    var players: [PlayerFixed1]
    
    // ✅ Mutating method to modify array
    mutating func addPlayer(name: String) {
        let newPlayer = PlayerFixed1(name: name, score: 0, level: 1)
        players.append(newPlayer)
    }
    
    mutating func removePlayer(named name: String) {
        players.removeAll { $0.name == name }
    }
    
    // ✅ Non-mutating: just reading data
    func getTopPlayer() -> PlayerFixed1? {
        return players.max { $0.score < $1.score }
    }
}


// ✅ COMPARISON: Class vs Struct
// ═══════════════════════════════════════════════════════════════

// Classes are reference types - no 'mutating' needed
class PlayerClass {
    var name: String
    var score: Int
    var level: Int
    
    init(name: String, score: Int, level: Int) {
        self.name = name
        self.score = score
        self.level = level
    }
    
    // ✅ No 'mutating' keyword needed for classes
    func increaseScore(by points: Int) {
        score += points
    }
    
    func levelUp() {
        level += 1
    }
}


// ✅ WHEN TO USE STRUCT VS CLASS
// ═══════════════════════════════════════════════════════════════

// Use STRUCT when:
// - Modeling simple data
// - Value semantics make sense (copies are independent)
// - No inheritance needed
// - Thread safety is important

struct Point {
    var x: Double
    var y: Double
    
    mutating func moveBy(dx: Double, dy: Double) {
        x += dx
        y += dy
    }
}

struct Rectangle {
    var origin: Point
    var size: CGSize
    
    mutating func translate(by offset: Point) {
        origin.x += offset.x
        origin.y += offset.y
    }
    
    func area() -> Double {
        return size.width * size.height
    }
}

// Use CLASS when:
// - Need inheritance
// - Need reference semantics (shared state)
// - Need deinitializers
// - Working with Objective-C APIs

class NetworkManager {
    static let shared = NetworkManager()  // Singleton - needs class
    
    private init() {}
    
    func fetchData() {
        // Reference type makes sense for singleton
    }
}


// ✅ ADVANCED: Mutating with Nested Types
// ═══════════════════════════════════════════════════════════════

struct Game {
    struct Player {
        var name: String
        var score: Int
        
        mutating func addPoints(_ points: Int) {
            score += points
        }
    }
    
    var players: [Player]
    var currentPlayerIndex: Int
    
    // ✅ Mutating method modifying nested struct
    mutating func currentPlayerScored(_ points: Int) {
        // This modifies the struct in the array
        players[currentPlayerIndex].addPoints(points)
    }
    
    mutating func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. MUTATING KEYWORD:
    - Required for ANY struct method that modifies properties
    - Not needed for classes (they're reference types)
    - Can't call mutating methods on 'let' constants
 
 2. VALUE SEMANTICS:
    - Structs are copied on assignment
    - Each copy is independent
    - Changes to copy don't affect original
 
 3. LET vs VAR:
    - let struct = immutable struct (can't call mutating methods)
    - var struct = mutable struct (can call mutating methods)
    - This is different from classes!
 
 4. WHEN MUTATIONS HAPPEN:
    - Changing any property
    - Modifying collection properties
    - Replacing self completely
    - Calling mutating methods on properties
 
 5. PERFORMANCE:
    - Structs use Copy-on-Write for collections
    - Small structs are very efficient
    - Don't avoid structs due to "copy overhead"
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "This method modifies the struct's properties, so it needs to be marked 
    as 'mutating' because structs are value types."
 
 2. "The 'mutating' keyword tells Swift that this method will modify self, 
    which prevents us from calling it on a let constant."
 
 3. "I'd use a struct here because we want value semantics - each instance 
    should be independent."
 
 4. "Classes don't need 'mutating' because they're reference types - we're 
    modifying the object in place, not creating a new value."
 
 5. "If we have a 'let' struct, we can't call mutating methods on it, which 
    helps prevent bugs."
 
 BONUS POINTS:
 ✅ Explain value vs reference semantics with examples
 ✅ Mention Copy-on-Write optimization
 ✅ Discuss when to use struct vs class
 ✅ Know that Swift standard library prefers structs (Array, Dictionary, String)
 ✅ Understand that enums can also have mutating methods
 
 RED FLAGS:
 ❌ "I always use classes because they're simpler"
 ❌ Not understanding the difference between value and reference types
 ❌ Thinking struct copies are slow (they're optimized!)
 ❌ Forgetting that let structs can't be mutated
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What happens if you call a mutating method on a let constant?"
 A: "Compiler error - you can't mutate an immutable value"
 
 Q: "Why does Swift prefer structs over classes?"
 A: "Value semantics provide better predictability, thread safety, and 
     functional programming benefits"
 
 Q: "When would you use a class instead of a struct?"
 A: "When you need inheritance, reference semantics, deinitializers, 
     or you're working with Objective-C APIs"
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample4() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 4: MUTATING STRUCT METHODS")
    print("═══════════════════════════════════════════════════════\n")
    
    print("✅ FIXED STRUCT with mutating methods:")
    var player1 = PlayerFixed1(name: "Alice", score: 0, level: 1)
    player1.displayStats()
    player1.increaseScore(by: 100)
    player1.levelUp()
    player1.displayStats()
    print()
    
    print("📝 VALUE SEMANTICS demonstration:")
    var player2 = player1  // Creates a COPY
    player2.name = "Bob"
    player2.increaseScore(by: 50)
    print("Original player:")
    player1.displayStats()  // Still Alice with original score
    print("Copied player:")
    player2.displayStats()  // Bob with different score
    print()
    
    print("🔒 LET vs VAR:")
    let immutablePlayer = PlayerFixed1(name: "Charlie", score: 100, level: 5)
    immutablePlayer.displayStats()  // ✅ Can call non-mutating methods
    // immutablePlayer.increaseScore(by: 10)  // ❌ Compiler error! Uncomment to see
    print("(Can't call mutating methods on 'let' constants)\n")
    
    print("✅ CLASS comparison (reference type):")
    let playerClass1 = PlayerClass(name: "David", score: 0, level: 1)
    let playerClass2 = playerClass1  // SAME REFERENCE, not a copy
    playerClass2.increaseScore(by: 100)
    print("Class player1 score: \(playerClass1.score)")  // Also 100!
    print("Class player2 score: \(playerClass2.score)")  // Same object
    print()
    
    print("✅ GAME STATE with mutating methods:")
    var game = GameStateFixed(players: [])
    game.addPlayer(name: "Player 1")
    game.addPlayer(name: "Player 2")
    if let topPlayer = game.getTopPlayer() {
        print("Top player: \(topPlayer.name)")
    }
    print()
}

// Uncomment to run:
// runExample4()
