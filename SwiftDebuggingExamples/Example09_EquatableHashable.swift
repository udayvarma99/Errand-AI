// =============================================================================
// EXAMPLE 9: Equatable & Hashable Pitfalls
// =============================================================================
//
// DIFFICULTY: Intermediate
// TOPIC: Equatable, Hashable, Set, Dictionary Keys, Custom Equality
// APPLE INTERVIEW TIP: Understanding equality and hashing is important for
//   working with collections efficiently. Incorrect Hashable implementations
//   can cause insidious bugs with Sets and Dictionaries.
//
// WHAT YOU WILL LEARN:
//   - The contract between Equatable and Hashable
//   - How incorrect implementations cause bugs
//   - When automatic synthesis works vs when you need custom implementations
//   - How Sets and Dictionaries depend on Hashable
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bugs before scrolling down!
// ---------------------------------------------------------------------------

/*

// BUG 1: Hashable contract violation
struct Employee: Hashable {
    let id: Int
    let name: String
    let department: String
    
    // Custom Equatable: Two employees are "equal" if they have the same ID
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.id == rhs.id
    }
    
    // BUG: Hash function uses ALL properties, but == only checks id
    // This violates the contract: if a == b, then a.hashValue == b.hashValue
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)        // BUG: included in hash but not in ==
        hasher.combine(department)   // BUG: included in hash but not in ==
    }
}

let emp1 = Employee(id: 1, name: "Tim", department: "Executive")
let emp2 = Employee(id: 1, name: "Timothy", department: "CEO")

print(emp1 == emp2)  // true (same ID)
print(emp1.hashValue == emp2.hashValue)  // false! Hash values differ!

// This causes bugs with Set and Dictionary:
var employees: Set<Employee> = [emp1]
employees.insert(emp2)
print(employees.count)  // 2! But they're "equal"! Should be 1!


// BUG 2: Forgetting that class types need explicit conformance
class Animal {
    let species: String
    let name: String
    
    init(species: String, name: String) {
        self.species = species
        self.name = name
    }
}

// BUG: Classes don't get automatic Equatable/Hashable synthesis
let cat1 = Animal(species: "Cat", name: "Whiskers")
let cat2 = Animal(species: "Cat", name: "Whiskers")
// print(cat1 == cat2)  // ERROR: Binary operator '==' cannot be applied

*/


// ---------------------------------------------------------------------------
// WHY ARE THESE BUGS?
// ---------------------------------------------------------------------------
//
// THE HASHABLE CONTRACT:
// If two values are equal (a == b), they MUST have the same hash value.
// The reverse is NOT required — different values CAN have the same hash
// (this is called a hash collision and is normal).
//
//   RULE: a == b  →  a.hashValue == b.hashValue  (MUST be true)
//         a.hashValue == b.hashValue  →  a == b   (NOT necessarily true)
//
// If you violate this contract:
//   - Set may store "duplicate" equal elements
//   - Dictionary may have "duplicate" keys
//   - Contains/lookup operations may fail to find existing elements
//
// BUG 1 violates the contract because == checks only id, but hash uses
// id + name + department. Two employees with the same id but different
// names will be "equal" but have different hash values.
//
// BUG 2: Classes don't get automatic Equatable/Hashable synthesis like
// structs do. You must explicitly conform and implement the methods.
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE
// ---------------------------------------------------------------------------

// FIX 1: Hash must use the same (or fewer) properties as ==
struct Employee: Hashable {
    let id: Int
    let name: String
    let department: String
    
    // Custom Equatable: Two employees are "equal" if they have the same ID
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.id == rhs.id
    }
    
    // FIX: Hash uses ONLY the properties that == uses
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        // Don't include name or department — they're not part of equality
    }
}


// FIX 2: Explicit Equatable/Hashable for classes
class Animal: Hashable {
    let species: String
    let name: String
    
    init(species: String, name: String) {
        self.species = species
        self.name = name
    }
    
    // Must implement == for classes
    static func == (lhs: Animal, rhs: Animal) -> Bool {
        return lhs.species == rhs.species && lhs.name == rhs.name
    }
    
    // Must implement hash(into:) for classes
    func hash(into hasher: inout Hasher) {
        hasher.combine(species)
        hasher.combine(name)
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify correct behavior
// ---------------------------------------------------------------------------

print("=== Employee Equality & Hashing ===")

let emp1 = Employee(id: 1, name: "Tim", department: "Executive")
let emp2 = Employee(id: 1, name: "Timothy", department: "CEO")
let emp3 = Employee(id: 2, name: "Craig", department: "Engineering")

print("emp1 == emp2: \(emp1 == emp2)")  // true (same id)
print("emp1 == emp3: \(emp1 == emp3)")  // false (different id)

// Hash values must be equal for equal objects
print("emp1.hashValue == emp2.hashValue: \(emp1.hashValue == emp2.hashValue)")  // true!

// Set correctly treats emp1 and emp2 as the same element
var employees: Set<Employee> = [emp1]
employees.insert(emp2)
print("Set count (should be 1): \(employees.count)")  // 1 — correct!

employees.insert(emp3)
print("Set count after adding emp3 (should be 2): \(employees.count)")  // 2

// Dictionary with Employee keys works correctly
var salaries: [Employee: Double] = [emp1: 100000.0]
salaries[emp2] = 150000.0  // Updates emp1's entry (same id)
print("Salary entries (should be 1): \(salaries.count)")  // 1


print("\n=== Animal Equality ===")

let cat1 = Animal(species: "Cat", name: "Whiskers")
let cat2 = Animal(species: "Cat", name: "Whiskers")
let dog1 = Animal(species: "Dog", name: "Buddy")

print("cat1 == cat2: \(cat1 == cat2)")  // true
print("cat1 == dog1: \(cat1 == dog1)")  // false

// Identity vs Equality for classes
print("cat1 === cat2: \(cat1 === cat2)")  // false — different instances
print("cat1 === cat1: \(cat1 === cat1)")  // true — same instance

var animalSet: Set<Animal> = [cat1, cat2, dog1]
print("Animal set count (should be 2): \(animalSet.count)")  // 2 (cat1 and cat2 are equal)


// ---------------------------------------------------------------------------
// BONUS: When to use automatic synthesis vs custom
// ---------------------------------------------------------------------------

// AUTOMATIC SYNTHESIS works when:
// - All stored properties are Equatable/Hashable
// - For structs and enums (not classes)

struct Point: Hashable {
    let x: Double
    let y: Double
    // Swift automatically generates == and hash(into:) using ALL properties
    // No manual implementation needed!
}

let p1 = Point(x: 1.0, y: 2.0)
let p2 = Point(x: 1.0, y: 2.0)
print("\n=== Automatic Synthesis ===")
print("Points equal: \(p1 == p2)")  // true — auto-generated


// CUSTOM IMPLEMENTATION needed when:
// - You want equality based on a subset of properties (like Employee.id)
// - You're working with classes
// - Properties include non-Hashable types

struct CacheEntry: Hashable {
    let url: String
    let data: [UInt8]
    let timestamp: Date
    
    // We only care about the URL for caching purposes
    static func == (lhs: CacheEntry, rhs: CacheEntry) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

let entry1 = CacheEntry(url: "https://api.example.com/data", data: [1, 2, 3], timestamp: Date())
let entry2 = CacheEntry(url: "https://api.example.com/data", data: [4, 5, 6], timestamp: Date())
print("\nCache entries equal (same URL): \(entry1 == entry2)")  // true


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "You have a struct used as a Dictionary key, but lookups are returning
//     nil even though you know the key exists. What could be wrong?"
//
// A: The most likely cause is a Hashable/Equatable contract violation:
//
//    1. The hash(into:) and == methods are inconsistent:
//       - If hash uses different properties than ==, equal objects may hash
//         to different buckets, making lookups fail.
//
//    2. Mutable properties changed after insertion:
//       - If you use 'var' properties and modify them after inserting into
//         a Set/Dictionary, the hash changes but the element stays in the
//         old bucket. Lookups in the new bucket find nothing.
//       - Solution: Use 'let' for properties involved in hashing.
//
//    3. Floating-point edge cases:
//       - NaN != NaN in IEEE 754, which can cause issues with Float/Double
//         properties in Hashable types.
//
//    Debugging steps:
//    1. Print the hash values of the key you're looking up and the stored key
//    2. Verify == returns true for those keys
//    3. Check that hash values match for equal keys
//    4. Use breakpoints in custom == and hash(into:) methods
// ---------------------------------------------------------------------------
