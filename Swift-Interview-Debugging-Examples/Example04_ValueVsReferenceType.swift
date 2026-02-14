// =============================================================================
// EXAMPLE 4: Value Type vs Reference Type Mutation
// =============================================================================
// Difficulty: Intermediate
// Topic:      Structs vs Classes, Copy Semantics, Mutability
//
// SCENARIO:
// You are building a game. A player has a score, and you write a function to
// add bonus points. But the score never changes! The bug is caused by
// misunderstanding how structs (value types) work differently from classes
// (reference types).
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

struct PlayerBuggy {
    var name: String
    var score: Int
}

func addBonusPointsBuggy(player: PlayerBuggy, bonus: Int) {
    // BUG: 'player' is a VALUE TYPE (struct). When passed to a function,
    // Swift creates a COPY. Modifying the copy does nothing to the original.
    var mutablePlayer = player   // This is a COPY, not the original!
    mutablePlayer.score += bonus
    print("Inside function: \(mutablePlayer.name) score = \(mutablePlayer.score)")
}

func demoBuggy() {
    var player = PlayerBuggy(name: "Alice", score: 100)
    addBonusPointsBuggy(player: player, bonus: 50)
    // The original player's score is UNCHANGED!
    print("Outside function: \(player.name) score = \(player.score)")
    // Prints: "Outside function: Alice score = 100"  (Expected: 150)
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// In Swift, there are two kinds of types:
//
// VALUE TYPES (struct, enum, tuple):
//   - Passed by COPY. Changes to the copy don't affect the original.
//   - Examples: Int, String, Array, Dictionary, all structs
//
// REFERENCE TYPES (class):
//   - Passed by REFERENCE. All variables point to the SAME object.
//   - Changes through any reference affect the shared object.
//
// The bug: PlayerBuggy is a struct (value type). When passed to
// addBonusPointsBuggy(), Swift copies the entire struct. The function
// modifies the copy, and the original is never changed.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Three approaches
// ─────────────────────────────────────────────────────────────────────────────

// FIX APPROACH 1: Use 'inout' parameter to pass the struct by reference
struct PlayerFixed1 {
    var name: String
    var score: Int
}

func addBonusPointsInout(player: inout PlayerFixed1, bonus: Int) {
    // 'inout' means: "I will modify the original, not a copy."
    player.score += bonus
    print("[inout] Inside function: \(player.name) score = \(player.score)")
}

// FIX APPROACH 2: Use a mutating method on the struct itself
struct PlayerFixed2 {
    var name: String
    var score: Int

    // 'mutating' allows a struct method to modify its own properties.
    mutating func addBonus(_ bonus: Int) {
        score += bonus
        print("[mutating] After bonus: \(name) score = \(score)")
    }
}

// FIX APPROACH 3: Use a class (reference type) instead of a struct
class PlayerFixed3 {
    var name: String
    var score: Int

    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}

func addBonusPointsClass(player: PlayerFixed3, bonus: Int) {
    // Classes are reference types — we are modifying the ORIGINAL object.
    player.score += bonus
    print("[class] Inside function: \(player.name) score = \(player.score)")
}

func demoFixed() {
    // Approach 1: inout
    print("--- Approach 1: inout ---")
    var player1 = PlayerFixed1(name: "Alice", score: 100)
    addBonusPointsInout(player: &player1, bonus: 50)  // Note the '&'
    print("Outside function: \(player1.name) score = \(player1.score)")  // 150

    // Approach 2: mutating method
    print("\n--- Approach 2: mutating method ---")
    var player2 = PlayerFixed2(name: "Bob", score: 200)
    player2.addBonus(75)
    print("After method call: \(player2.name) score = \(player2.score)")  // 275

    // Approach 3: class (reference type)
    print("\n--- Approach 3: class (reference type) ---")
    let player3 = PlayerFixed3(name: "Charlie", score: 300)
    addBonusPointsClass(player: player3, bonus: 100)
    print("Outside function: \(player3.name) score = \(player3.score)")  // 400
    // Note: player3 is 'let' but we can still modify its properties
    // because classes are reference types. 'let' only prevents reassigning
    // the reference, not modifying the object.
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. STRUCTS are VALUE TYPES — passed by copy. Changes to copies don't
//    affect the original.
//
// 2. CLASSES are REFERENCE TYPES — all variables point to the same instance.
//    Changes through any reference affect the shared object.
//
// 3. Use 'inout' when you need a function to modify a struct parameter.
//    Callers must use '&' prefix: addBonus(player: &myPlayer, bonus: 50)
//
// 4. Use 'mutating' for struct methods that modify the struct's properties.
//
// 5. Apple's RECOMMENDATION: Prefer structs over classes unless you
//    specifically need reference semantics (shared mutable state).
//
// 6. 'let' on a class instance: prevents reassigning the variable, but
//    you CAN still modify the object's properties.
//    'let' on a struct instance: prevents ALL modification — the entire
//    struct is immutable.
//
// 7. Common interview question: "When would you use a class instead of
//    a struct?" Answer: When you need shared mutable state, inheritance,
//    or identity (===) comparison.
// ─────────────────────────────────────────────────────────────────────────────
