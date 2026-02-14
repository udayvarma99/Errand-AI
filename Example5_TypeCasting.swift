/*
 ============================================
 EXAMPLE 5: TYPE CASTING ISSUES
 ============================================
 
 Common Issue: Unsafe type casting causing runtime crashes
 Apple Interview Focus: Polymorphism, protocol types, safe casting
 */

import Foundation

// Define some types for our examples
protocol Animal {
    var name: String { get }
    func makeSound() -> String
}

class Dog: Animal {
    let name: String
    let breed: String
    
    init(name: String, breed: String) {
        self.name = name
        self.breed = breed
    }
    
    func makeSound() -> String {
        return "Woof!"
    }
    
    func fetch() {
        print("\(name) is fetching!")
    }
}

class Cat: Animal {
    let name: String
    let lives: Int
    
    init(name: String, lives: Int = 9) {
        self.name = name
        self.lives = lives
    }
    
    func makeSound() -> String {
        return "Meow!"
    }
    
    func scratch() {
        print("\(name) is scratching!")
    }
}

// ❌ BUGGY CODE - Unsafe Type Casting

class BuggyAnimalHandler {
    func processAnimals(_ animals: [Animal]) {
        for animal in animals {
            print("\(animal.name) says \(animal.makeSound())")
            
            // 🐛 BUG: Force casting without checking type
            let dog = animal as! Dog  // 💥 Crashes if animal is a Cat!
            dog.fetch()
        }
    }
    
    func handleMixedArray(_ items: [Any]) {
        for item in items {
            // 🐛 BUG: Assuming all items are Strings
            let text = item as! String  // 💥 Crashes if item is not a String
            print(text.uppercased())
        }
    }
    
    func downcastWithoutCheck(_ animal: Animal) -> Dog {
        // 🐛 BUG: Force downcasting
        return animal as! Dog  // 💥 Crashes if not a Dog
    }
    
    func parseJSON(_ json: [String: Any]) {
        // 🐛 BUG: Force casting dictionary values
        let name = json["name"] as! String  // Crashes if missing or wrong type
        let age = json["age"] as! Int       // Crashes if missing or wrong type
        let scores = json["scores"] as! [Int]  // Crashes if wrong type
        
        print("\(name) is \(age) years old")
    }
}

// Example of crashes
func demonstrateBug() {
    print("=== TYPE CASTING CRASHES ===\n")
    
    let handler = BuggyAnimalHandler()
    let animals: [Animal] = [
        Dog(name: "Buddy", breed: "Golden Retriever"),
        Cat(name: "Whiskers", lives: 9)
    ]
    
    // This will crash on the Cat
    // handler.processAnimals(animals)  // 💥 CRASH!
    
    let mixedItems: [Any] = ["Hello", 42, true, "World"]
    // handler.handleMixedArray(mixedItems)  // 💥 CRASH on number!
    
    print("Crashes prevented by commenting out buggy code\n")
}

/*
 🔍 DEBUGGING TECHNIQUES:
 
 1. Set breakpoint on crashing line
 2. Check actual type: po type(of: variable)
 3. Use LLDB: expr -l swift -- type(of: myVariable)
 4. Look at crash message: "Could not cast value of type..."
 5. Use Xcode's Quick Help to see type information
 6. Enable "Exception Breakpoint" for Swift errors
 */

// ✅ FIXED CODE - Safe Type Casting

class FixedAnimalHandler {
    
    // SOLUTION 1: Type checking with 'is'
    func processAnimals_TypeCheck(_ animals: [Animal]) {
        for animal in animals {
            print("\(animal.name) says \(animal.makeSound())")
            
            // Check type before casting
            if animal is Dog {
                let dog = animal as! Dog  // Now safe - we checked first
                dog.fetch()
            } else if animal is Cat {
                let cat = animal as! Cat
                cat.scratch()
            }
        }
    }
    
    // SOLUTION 2: Conditional casting with 'as?'
    func processAnimals_ConditionalCast(_ animals: [Animal]) {
        for animal in animals {
            print("\(animal.name) says \(animal.makeSound())")
            
            // Safe optional casting
            if let dog = animal as? Dog {
                dog.fetch()
            }
            
            if let cat = animal as? Cat {
                cat.scratch()
            }
        }
    }
    
    // SOLUTION 3: Switch with pattern matching (most elegant!)
    func processAnimals_Switch(_ animals: [Animal]) {
        for animal in animals {
            switch animal {
            case let dog as Dog:
                print("\(dog.name) (breed: \(dog.breed)) says \(dog.makeSound())")
                dog.fetch()
                
            case let cat as Cat:
                print("\(cat.name) (\(cat.lives) lives) says \(cat.makeSound())")
                cat.scratch()
                
            default:
                print("Unknown animal: \(animal.name)")
            }
        }
    }
    
    // SOLUTION 4: Safe Any array handling
    func handleMixedArray(_ items: [Any]) {
        for item in items {
            switch item {
            case let text as String:
                print("String: \(text.uppercased())")
                
            case let number as Int:
                print("Number: \(number * 2)")
                
            case let flag as Bool:
                print("Boolean: \(flag ? "YES" : "NO")")
                
            default:
                print("Unknown type: \(type(of: item))")
            }
        }
    }
    
    // SOLUTION 5: Safe downcasting with optional return
    func downcastSafely(_ animal: Animal) -> Dog? {
        return animal as? Dog
    }
    
    // SOLUTION 6: Safe JSON parsing
    func parseJSON(_ json: [String: Any]) -> (name: String, age: Int, scores: [Int])? {
        // Use optional casting with guard
        guard let name = json["name"] as? String,
              let age = json["age"] as? Int,
              let scores = json["scores"] as? [Int] else {
            print("⚠️  Invalid JSON format")
            return nil
        }
        
        print("\(name) is \(age) years old with scores: \(scores)")
        return (name, age, scores)
    }
    
    // SOLUTION 7: Type-safe JSON parsing with defaults
    func parseJSONWithDefaults(_ json: [String: Any]) {
        let name = json["name"] as? String ?? "Unknown"
        let age = json["age"] as? Int ?? 0
        let scores = json["scores"] as? [Int] ?? []
        
        print("\(name) is \(age) years old")
    }
    
    // SOLUTION 8: Using generics for type safety
    func getValue<T>(from dict: [String: Any], key: String, defaultValue: T) -> T {
        return dict[key] as? T ?? defaultValue
    }
}

// Codable approach (best for JSON)
struct Person: Codable {
    let name: String
    let age: Int
    let scores: [Int]
}

class ModernJSONHandler {
    func parseJSON(_ jsonData: Data) -> Person? {
        let decoder = JSONDecoder()
        do {
            let person = try decoder.decode(Person.self, from: jsonData)
            return person
        } catch {
            print("❌ JSON parsing error: \(error)")
            return nil
        }
    }
}

// Advanced: Protocol with associated types
protocol Container {
    associatedtype Item
    var items: [Item] { get }
    func process(_ item: Item)
}

class StringContainer: Container {
    var items: [String] = []
    
    func process(_ item: String) {
        items.append(item.uppercased())
    }
}

// ✅ Safe usage examples
func demonstrateFix() {
    print("=== SAFE TYPE CASTING ===\n")
    
    let handler = FixedAnimalHandler()
    let animals: [Animal] = [
        Dog(name: "Buddy", breed: "Golden Retriever"),
        Cat(name: "Whiskers", lives: 9),
        Dog(name: "Max", breed: "Labrador")
    ]
    
    print("--- Using conditional casting ---")
    handler.processAnimals_ConditionalCast(animals)
    
    print("\n--- Using switch pattern matching ---")
    handler.processAnimals_Switch(animals)
    
    print("\n--- Handling mixed array ---")
    let mixedItems: [Any] = ["Hello", 42, true, "World", 3.14]
    handler.handleMixedArray(mixedItems)
    
    print("\n--- Safe JSON parsing ---")
    let validJSON: [String: Any] = [
        "name": "Alice",
        "age": 25,
        "scores": [95, 87, 92]
    ]
    _ = handler.parseJSON(validJSON)
    
    let invalidJSON: [String: Any] = [
        "name": "Bob",
        "age": "twenty"  // Wrong type!
    ]
    _ = handler.parseJSON(invalidJSON)
    
    print("\n--- Using generics ---")
    let dict: [String: Any] = ["count": 42, "title": "Swift"]
    let count: Int = handler.getValue(from: dict, key: "count", defaultValue: 0)
    let title: String = handler.getValue(from: dict, key: "title", defaultValue: "")
    print("Count: \(count), Title: \(title)")
}

/*
 📝 KEY TAKEAWAYS FOR INTERVIEWS:
 
 1. NEVER use 'as!' unless you're 100% certain of the type
 2. Use 'as?' for safe optional casting
 3. Use 'is' to check types before casting
 4. Switch with pattern matching is elegant and safe
 5. For JSON, prefer Codable over manual casting
 6. Always provide fallbacks for optional casts
 
 🎯 TYPE CASTING OPERATORS:
 
 - as: Upcasting (safe, compile-time checked)
       let animal: Animal = dog as Animal
 
 - as?: Conditional downcast (returns optional)
        if let dog = animal as? Dog { }
 
 - as!: Forced downcast (crashes if wrong type)
        let dog = animal as! Dog  // ⚠️  Dangerous!
 
 - is: Type checking (returns Bool)
       if animal is Dog { }
 
 ⚠️  WHEN TO USE EACH:
 
 as  - Compile-time verified casts (always safe)
 as? - Runtime type checking (safe, returns nil on failure)
 as! - Only use when failure is truly impossible
 is  - Type checking without casting
 
 💡 BEST PRACTICES:
 
 1. Prefer protocols and generics over type casting
 2. Use switch with pattern matching for multiple types
 3. For JSON: Use Codable instead of [String: Any]
 4. Validate types before force casting
 5. Use guard let for early returns
 
 🔄 CASTING PATTERNS:
 
 // ❌ BAD
 let dog = animal as! Dog
 dog.fetch()
 
 // ✅ GOOD
 if let dog = animal as? Dog {
     dog.fetch()
 }
 
 // ✅ BETTER (with guard)
 guard let dog = animal as? Dog else { return }
 dog.fetch()
 
 // ✅ BEST (pattern matching)
 switch animal {
 case let dog as Dog:
     dog.fetch()
 case let cat as Cat:
     cat.scratch()
 default:
     break
 }
 
 🛠️  COMMON TYPE CASTING SCENARIOS:
 
 1. Protocol to concrete type
 2. Any/AnyObject to specific type
 3. JSON dictionary values
 4. Collection elements
 5. UIView to UIButton, etc.
 6. NSObject subclasses
 
 ⚡ INTERVIEW TIPS:
 
 - Explain difference between as, as?, and as!
 - Know when upcasting vs downcasting
 - Understand type erasure
 - Be familiar with Codable for JSON
 - Discuss generic constraints
 - Mention protocol-oriented programming
 
 🎓 ADVANCED CONCEPTS:
 
 - Type erasure with AnyHashable, AnySequence
 - Associated types in protocols
 - Generic constraints: <T: Protocol>
 - Conditional conformance
 - Opaque types (some Protocol)
 */

// Run demonstrations
print("🐛 BUGGY VERSION:")
demonstrateBug()

print("\n" + String(repeating: "=", count: 50) + "\n")
demonstrateFix()
