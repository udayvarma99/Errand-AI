// =============================================================================
// EXAMPLE 7: Equatable/Hashable for Custom Types
// =============================================================================
// Difficulty: Intermediate
// Topic:      Equatable, Hashable, Set, Dictionary
//
// SCENARIO:
// You are building a contact list. You create a Contact struct and try to
// use a Set to store unique contacts. But duplicates keep appearing because
// the type doesn't properly conform to Hashable and Equatable.
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

// This class does NOT conform to Hashable or Equatable.
// We can't use it in a Set or as a Dictionary key.
class ContactBuggy {
    var id: Int
    var name: String
    var email: String

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

// BUG 1: Making ContactBuggy conform to Equatable using '===' (identity)
// instead of value equality.
extension ContactBuggy: Equatable {
    static func == (lhs: ContactBuggy, rhs: ContactBuggy) -> Bool {
        // This checks if they are the SAME OBJECT in memory, not if they
        // have the same values. Two different Contact objects with id=1
        // will NOT be considered equal!
        return lhs === rhs
    }
}

// BUG 2: Hashable uses ObjectIdentifier (memory address), which means
// two objects with the same id will have DIFFERENT hashes.
extension ContactBuggy: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

func demoBuggy() {
    let contact1 = ContactBuggy(id: 1, name: "Alice", email: "alice@example.com")
    let contact2 = ContactBuggy(id: 1, name: "Alice", email: "alice@example.com")

    // Same data, but treated as different because == uses identity (===)
    print("Are they equal? \(contact1 == contact2)")  // false! (Should be true)

    var contactSet: Set<ContactBuggy> = [contact1, contact2]
    print("Set count: \(contactSet.count)")  // 2! (Should be 1 — they're duplicates)
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// For Set and Dictionary to work correctly, two rules must hold:
//
// RULE 1: If two values are equal (==), they MUST have the same hash value.
// RULE 2: Equality should be based on the VALUES you care about, not on
//         memory identity.
//
// The buggy code uses object IDENTITY (===) for equality and memory address
// for hashing. This means:
//   - Two different objects with id=1 are considered NOT equal.
//   - They get different hashes (different memory addresses).
//   - Set treats them as different elements → duplicates!
//
// IMPORTANT: For classes, Swift does NOT auto-synthesize Equatable/Hashable.
// You must implement them manually. (Structs get auto-synthesis if all
// properties are Equatable/Hashable.)
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Proper value-based equality and hashing
// ─────────────────────────────────────────────────────────────────────────────

// FIX APPROACH 1: Use a struct (auto-synthesized conformance)
struct ContactFixedStruct: Hashable {
    let id: Int
    let name: String
    let email: String
    // Swift AUTO-SYNTHESIZES Equatable and Hashable for structs
    // when all stored properties are Equatable/Hashable. Done!
}

// FIX APPROACH 2: Class with manual, correct Equatable/Hashable
class ContactFixedClass: Equatable, Hashable {
    let id: Int
    var name: String
    var email: String

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    // FIX: Compare based on VALUES, not memory identity
    static func == (lhs: ContactFixedClass, rhs: ContactFixedClass) -> Bool {
        return lhs.id == rhs.id  // Two contacts with the same id are equal
    }

    // FIX: Hash based on the same properties used for equality
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Must be consistent with ==
    }
}

func demoFixed() {
    // Approach 1: Struct (auto-synthesized)
    print("--- Struct (auto-synthesized Hashable) ---")
    let s1 = ContactFixedStruct(id: 1, name: "Alice", email: "alice@example.com")
    let s2 = ContactFixedStruct(id: 1, name: "Alice", email: "alice@example.com")
    print("Are they equal? \(s1 == s2)")  // true

    var structSet: Set<ContactFixedStruct> = [s1, s2]
    print("Set count: \(structSet.count)")  // 1 (correct — duplicate removed)

    // Approach 2: Class (manual implementation)
    print("\n--- Class (manual Hashable based on id) ---")
    let c1 = ContactFixedClass(id: 1, name: "Alice", email: "alice@example.com")
    let c2 = ContactFixedClass(id: 1, name: "Alice", email: "alice@example.com")
    print("Are they equal? \(c1 == c2)")  // true (same id)

    var classSet: Set<ContactFixedClass> = [c1, c2]
    print("Set count: \(classSet.count)")  // 1 (correct!)

    // Using as Dictionary keys
    print("\n--- Dictionary keys ---")
    var contactInfo: [ContactFixedClass: String] = [:]
    contactInfo[c1] = "VIP Customer"
    print("Lookup by c2: \(contactInfo[c2] ?? "not found")")  // "VIP Customer"
    // Works because c1 == c2 (same id) and same hash
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. For Set and Dictionary to work: if a == b, then a.hashValue == b.hashValue
//    (The reverse is NOT required — different values CAN have the same hash.)
//
// 2. STRUCTS: Swift auto-synthesizes Equatable and Hashable if all stored
//    properties conform. No extra code needed!
//
// 3. CLASSES: You must manually implement == and hash(into:).
//
// 4. Don't use === (identity) for Equatable unless you truly need identity
//    comparison. Use VALUE-based equality.
//
// 5. hash(into:) should combine the SAME properties used for ==.
//    If == only checks 'id', then hash should only combine 'id'.
//
// 6. Common interview follow-up: "What happens if two unequal objects have
//    the same hash?" Answer: They go into the same hash bucket. The Set/
//    Dictionary then uses == to distinguish them. Performance degrades but
//    correctness is maintained.
//
// 7. Prefer structs in Swift — they get free Equatable/Hashable and have
//    value semantics (safer, more predictable).
// ─────────────────────────────────────────────────────────────────────────────
