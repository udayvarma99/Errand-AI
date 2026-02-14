// ============================================================================
// EXAMPLE 4: Value Types vs Reference Types
// Difficulty: Intermediate
// Topic: struct (value type) vs class (reference type) behavior differences
// ============================================================================

// ============================================================================
// WHAT ARE VALUE TYPES AND REFERENCE TYPES?
// ============================================================================
// In Swift:
//   - Structs, Enums, Tuples are VALUE TYPES — they are COPIED when assigned.
//   - Classes are REFERENCE TYPES — they share the SAME instance.
//
// Think of it this way:
//   - Value type = making a photocopy of a document. Changes to the copy
//                  don't affect the original.
//   - Reference type = sharing a Google Doc link. Everyone edits the SAME doc.
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Expecting struct to behave like a class (shared reference)
struct SettingsValue {
    var darkMode: Bool = false
    var fontSize: Int = 14
}

var userSettings = SettingsValue()
var savedSettings = userSettings  // Makes a COPY, not a reference!

savedSettings.darkMode = true
savedSettings.fontSize = 18

print("User settings: darkMode=\(userSettings.darkMode), fontSize=\(userSettings.fontSize)")
// Prints: darkMode=false, fontSize=14
// Bug: Developer expected both variables to reflect the change!


// Bug 2: Expecting class to behave like a struct (independent copy)
class SettingsReference {
    var darkMode: Bool = false
    var fontSize: Int = 14
}

var originalSettings = SettingsReference()
var backupSettings = originalSettings  // Both point to the SAME object!

backupSettings.darkMode = true  // This ALSO changes originalSettings!

print("Original darkMode: \(originalSettings.darkMode)")
// Prints: true   <-- Bug: Developer expected original to remain false!


// Bug 3: Mutating a struct inside a function doesn't affect the original
struct Score {
    var points: Int = 0
}

func addBonus(score: Score) {
    // score.points += 10  // This won't even compile!
    // Parameters are constants by default in Swift.
    // Even if you use `var`, it's a local copy — original unchanged.
}


// Bug 4: Array of classes — unintended shared state
class Student {
    var name: String
    var grade: Int

    init(name: String, grade: Int) {
        self.name = name
        self.grade = grade
    }
}

let student = Student(name: "Alice", grade: 85)
var students = [student, student, student]  // Three references to SAME object!

students[0].grade = 100  // Changes ALL of them!
for s in students {
    print("\(s.name): \(s.grade)")  // ALL print 100!
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Structs are value types. When you write `var b = a`, Swift makes a
//         complete independent copy. Changing `b` never affects `a`.
//
// Bug 2: Classes are reference types. When you write `var b = a`, both
//         variables point to the SAME object in memory. Changing one changes both.
//
// Bug 3: Function parameters are constants. Even if you copy to a `var`,
//         it's a local copy of the struct — the original is untouched.
//
// Bug 4: Putting the same class instance in an array 3 times means you have
//         3 references to ONE object, not 3 separate objects.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Use a class when you need shared state
class SettingsShared {
    var darkMode: Bool = false
    var fontSize: Int = 14
}

let userSettings = SettingsShared()
let savedSettings = userSettings  // Same object — changes are shared

savedSettings.darkMode = true
savedSettings.fontSize = 18

print("User: darkMode=\(userSettings.darkMode), fontSize=\(userSettings.fontSize)")
// Prints: darkMode=true, fontSize=18  — Shared as intended!


// Fix 2: Manually copy a class when you need independence
class SettingsReference {
    var darkMode: Bool
    var fontSize: Int

    init(darkMode: Bool = false, fontSize: Int = 14) {
        self.darkMode = darkMode
        self.fontSize = fontSize
    }

    // Create a copy method
    func copy() -> SettingsReference {
        return SettingsReference(darkMode: self.darkMode, fontSize: self.fontSize)
    }
}

let original = SettingsReference()
let backup = original.copy()  // Now it's a separate object!

backup.darkMode = true
print("Original darkMode: \(original.darkMode)")  // false — unchanged!
print("Backup darkMode: \(backup.darkMode)")       // true — independent copy!


// Fix 3: Use `inout` when you need a function to modify a struct
struct Score {
    var points: Int = 0
}

// Use `inout` to pass by reference
func addBonus(score: inout Score) {
    score.points += 10
}

var myScore = Score(points: 85)
addBonus(score: &myScore)  // Note the & — required for inout
print("Score after bonus: \(myScore.points)")  // 95


// Fix 4: Create separate instances for each array element
class Student {
    var name: String
    var grade: Int

    init(name: String, grade: Int) {
        self.name = name
        self.grade = grade
    }
}

// Create 3 SEPARATE Student objects
var students = [
    Student(name: "Alice", grade: 85),
    Student(name: "Alice", grade: 85),
    Student(name: "Alice", grade: 85)
]

students[0].grade = 100  // Only changes the first one
for s in students {
    print("\(s.name): \(s.grade)")
}
// Prints: Alice: 100, Alice: 85, Alice: 85  — Correct!


// ============================================================================
// BONUS: When to use struct vs class
// ============================================================================

// USE STRUCT when:
// - You want independent copies (value semantics)
// - The data is small and simple
// - You don't need inheritance
// - Thread safety is important (value types are inherently safer)
// Examples: CGPoint, CGRect, Date, URL, Array, String, Int

// USE CLASS when:
// - You need shared state (reference semantics)
// - You need inheritance
// - You need deinit (cleanup when object is destroyed)
// - You need identity (checking if two variables point to the same object)
// Examples: UIViewController, UIView, NSObject subclasses

// Quick demo of identity vs equality:
class Dog {
    var name: String
    init(name: String) { self.name = name }
}

let dog1 = Dog(name: "Rex")
let dog2 = dog1         // Same object
let dog3 = Dog(name: "Rex")  // Different object, same name

print(dog1 === dog2)  // true  — same object in memory (identity)
print(dog1 === dog3)  // false — different objects (even though name is same)


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "What's the difference between struct and class in Swift?"
//    Answer: Structs are value types (copied on assignment), classes are
//    reference types (shared on assignment). Structs can't use inheritance
//    or deinit.
//
// 2. "When would you use a struct over a class?"
//    Answer: When you want independent copies, don't need inheritance,
//    and want thread safety. Apple recommends starting with structs.
//
// 3. "What does `===` do?"
//    Answer: It checks identity — whether two variables point to the exact
//    same object in memory. Only works with classes (reference types).
//
// 4. "What is `inout`?"
//    Answer: It allows a function to modify a value type parameter.
//    The original variable is updated when the function returns.
// ============================================================================
