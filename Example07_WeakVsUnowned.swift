/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 7: WEAK VS UNOWNED REFERENCES
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Memory Management and Reference Types
 Common In: 75% of Swift interviews
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - INCORRECT USE OF UNOWNED
// ═══════════════════════════════════════════════════════════════

class CustomerBuggy {
    let name: String
    var creditCard: CreditCardBuggy?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}

class CreditCardBuggy {
    let number: String
    unowned let customer: CustomerBuggy  // 🐛 BUG: Using unowned
    
    init(number: String, customer: CustomerBuggy) {
        self.number = number
        self.customer = customer
    }
    
    func displayInfo() {
        // ⚠️ DANGER: If customer is deallocated, this CRASHES!
        print("Card \(number) belongs to \(customer.name)")
    }
    
    deinit {
        print("Card \(number) is being deinitialized")
    }
}

/*
 SCENARIO THAT CAUSES CRASH:
 1. Create customer and card
 2. Store card separately
 3. Customer is deallocated
 4. Try to use card.displayInfo()
 5. CRASH! customer is nil but unowned doesn't allow nil
*/


// ❌ BUGGY CODE - SHOULD USE WEAK BUT DOESN'T
// ═══════════════════════════════════════════════════════════════

class ViewControllerBuggy {
    var name: String
    var onDismiss: (() -> Void)?
    
    init(name: String) {
        self.name = name
    }
    
    func setupDismissHandler(parent: ViewControllerBuggy) {
        // 🐛 BUG: Strong reference cycle
        onDismiss = {
            parent.childDidDismiss()  // Strong reference to parent
        }
    }
    
    func childDidDismiss() {
        print("\(name): Child dismissed")
    }
    
    deinit {
        print("\(name) deinitialized")  // Never called due to cycle
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. UNOWNED CRASHES ON NIL:
    - unowned doesn't increase retain count
    - Accessing deallocated unowned reference = CRASH
    - No nil check possible (it's not optional)
 
 2. WHEN TO USE WHAT:
    - weak: Reference might become nil (optional)
    - unowned: Reference should never be nil (non-optional)
    - strong: You own it / need to keep it alive
 
 3. COMMON MISTAKE:
    - Using unowned when you're not 100% sure lifetime
    - Should use weak for safety in most cases
    - unowned is optimization, weak is safety
 
 4. THE UNOWNED RULE:
    - Only use if referenced object ALWAYS outlives this object
    - Example: Person always outlives their Passport
    - When in doubt, use weak!
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Use Weak When Appropriate
// ═══════════════════════════════════════════════════════════════

class CustomerFixed1 {
    let name: String
    var creditCard: CreditCardFixed1?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("✅ \(name) is being deinitialized")
    }
}

class CreditCardFixed1 {
    let number: String
    weak var customer: CustomerFixed1?  // ✅ Use weak - card might outlive customer
    
    init(number: String, customer: CustomerFixed1) {
        self.number = number
        self.customer = customer
    }
    
    func displayInfo() {
        // ✅ Safe to check for nil
        if let customer = customer {
            print("Card \(number) belongs to \(customer.name)")
        } else {
            print("Card \(number) has no owner")
        }
    }
    
    deinit {
        print("✅ Card \(number) is being deinitialized")
    }
}


// ✅ FIXED CODE - SOLUTION 2: Correct Use of Unowned
// ═══════════════════════════════════════════════════════════════

class Person {
    let name: String
    var passport: Passport?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("✅ \(name) is being deinitialized")
    }
}

class Passport {
    let number: String
    unowned let owner: Person  // ✅ Correct use: Passport can't outlive Person
    
    init(number: String, owner: Person) {
        self.number = number
        self.owner = owner
    }
    
    func displayInfo() {
        // ✅ Safe: owner is ALWAYS valid during passport's lifetime
        print("Passport \(number) belongs to \(owner.name)")
    }
    
    deinit {
        print("✅ Passport \(number) is being deinitialized")
    }
}


// ✅ FIXED CODE - SOLUTION 3: Delegate Pattern with Weak
// ═══════════════════════════════════════════════════════════════

protocol DataFetcherDelegate: AnyObject {  // ✅ AnyObject = class-only protocol
    func dataFetcher(_ fetcher: DataFetcher, didFetch data: String)
    func dataFetcher(_ fetcher: DataFetcher, didFailWithError error: Error)
}

class DataFetcher {
    weak var delegate: DataFetcherDelegate?  // ✅ Always weak for delegates
    
    func fetchData() {
        // Simulate async fetch
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.delegate?.dataFetcher(self, didFetch: "Sample Data")
        }
    }
}

class ViewController: DataFetcherDelegate {
    let name: String
    var fetcher: DataFetcher?
    
    init(name: String) {
        self.name = name
        self.fetcher = DataFetcher()
        fetcher?.delegate = self  // ✅ No retain cycle due to weak delegate
    }
    
    func dataFetcher(_ fetcher: DataFetcher, didFetch data: String) {
        print("\(name) received: \(data)")
    }
    
    func dataFetcher(_ fetcher: DataFetcher, didFailWithError error: Error) {
        print("\(name) error: \(error)")
    }
    
    deinit {
        print("✅ ViewController \(name) deinitialized")
    }
}


// ✅ REAL-WORLD EXAMPLE: Parent-Child Relationship
// ═══════════════════════════════════════════════════════════════

class ParentViewController {
    var name: String
    var children: [ChildViewController] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addChild(_ child: ChildViewController) {
        children.append(child)
        child.parent = self
    }
    
    func removeChild(_ child: ChildViewController) {
        children.removeAll { $0 === child }
        child.parent = nil
    }
    
    func childDidUpdate(_ child: ChildViewController) {
        print("\(name): Child \(child.name) updated")
    }
    
    deinit {
        print("✅ Parent \(name) deinitialized")
    }
}

class ChildViewController {
    var name: String
    weak var parent: ParentViewController?  // ✅ Weak to avoid cycle
    
    init(name: String) {
        self.name = name
    }
    
    func notifyParent() {
        parent?.childDidUpdate(self)
    }
    
    deinit {
        print("✅ Child \(name) deinitialized")
    }
}


// ✅ ADVANCED: Unowned Self in Closures
// ═══════════════════════════════════════════════════════════════

class ResourceManager {
    var resources: [String] = []
    
    func loadResources(completion: @escaping () -> Void) {
        // ✅ Use weak for most cases
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.resources.append("Resource")
            completion()
        }
    }
    
    func processResources() {
        // ✅ Use unowned ONLY if you're certain self outlives the closure
        // Dangerous! Only use if closure executes before self can be deallocated
        DispatchQueue.global().async { [unowned self] in
            // If self is deallocated before this runs = CRASH
            print("Processing \(self.resources.count) resources")
        }
    }
    
    deinit {
        print("ResourceManager deinitialized")
    }
}


// ✅ COMPARISON TABLE
// ═══════════════════════════════════════════════════════════════

/*
 ┌─────────────┬──────────────────┬──────────────────┬──────────────────┐
 │             │ strong           │ weak             │ unowned          │
 ├─────────────┼──────────────────┼──────────────────┼──────────────────┤
 │ Retain      │ Increases count  │ No increase      │ No increase      │
 │ Can be nil  │ Depends on type  │ YES (Optional)   │ NO (crashes)     │
 │ When to use │ Ownership        │ Might outlive    │ Never outlives   │
 │ Cycle risk  │ YES              │ NO               │ NO               │
 │ Performance │ Standard         │ Slight overhead  │ Fastest          │
 │ Safety      │ Safe             │ Safe             │ Unsafe if wrong  │
 └─────────────┴──────────────────┴──────────────────┴──────────────────┘
*/


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. USE WEAK WHEN:
    - Delegates (always!)
    - Parent references from children
    - Cache entries
    - Observers/listeners
    - Closure captures that might outlive object
    - When in doubt!
 
 2. USE UNOWNED WHEN:
    - Child owns parent lifetime (rare)
    - Certain object always outlives this one
    - Classic example: Person and Passport
    - Optimization after profiling
 
 3. USE STRONG WHEN:
    - You own the object
    - Need to keep it alive
    - Child objects you're responsible for
    - Most properties
 
 4. DELEGATE PATTERN:
    - Always weak var delegate
    - Protocol should be class-only (: AnyObject)
    - Prevents retain cycles
 
 5. CLOSURE CAPTURE LISTS:
    - [weak self]: Safe, recommended
    - [unowned self]: Dangerous, rarely needed
    - Use guard let self after weak
 
 6. DEBUGGING:
    - Use Instruments (Leaks tool)
    - Check deinit is called
    - Xcode Memory Graph Debugger
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "I see unowned being used here, but if the customer is deallocated before 
    the card, this will crash. I'd use weak for safety."
 
 2. "Weak makes the reference optional and safe - it becomes nil when the 
    object is deallocated. Unowned is non-optional and crashes if accessed 
    after deallocation."
 
 3. "For delegates, I always use weak to prevent retain cycles. The protocol 
    should be class-only with ': AnyObject'."
 
 4. "I'd only use unowned if I can guarantee the referenced object will 
    always outlive this one, like a passport and its owner."
 
 5. "In closures, I prefer [weak self] over [unowned self] because it's 
    safer and the performance difference is negligible."
 
 BONUS POINTS:
 ✅ Explain the difference with a diagram/example
 ✅ Mention weak references have slight overhead (nil checking)
 ✅ Discuss unowned(unsafe) for even more dangerous optimization
 ✅ Know about capture lists in closures
 ✅ Understand why delegates should be class-only protocols
 
 RED FLAGS:
 ❌ "I always use unowned because it's faster"
 ❌ Not knowing when to use weak vs unowned
 ❌ Using strong references for delegates
 ❌ Not using AnyObject for delegate protocols
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "Can you use weak with structs?"
 A: "No, weak and unowned only work with reference types (classes). Structs 
     are value types and don't have reference counting."
 
 Q: "What's unowned(unsafe)?"
 A: "It's like unowned but doesn't even check if the object is valid. It's 
     like a raw pointer - extremely dangerous but slightly faster. Almost 
     never use it."
 
 Q: "Why use AnyObject for delegate protocols?"
 A: "Because weak and unowned only work with classes. AnyObject makes it a 
     class-only protocol so we can use weak var delegate."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample7() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 7: WEAK VS UNOWNED")
    print("═══════════════════════════════════════════════════════\n")
    
    print("✅ WEAK REFERENCE (Safe):")
    do {
        let customer = CustomerFixed1(name: "Alice")
        let card = CreditCardFixed1(number: "1234", customer: customer)
        customer.creditCard = card
        
        card.displayInfo()
    }  // customer deallocated here
    
    print("Card still exists but customer is gone\n")
    
    print("✅ UNOWNED REFERENCE (Correct use):")
    do {
        let person = Person(name: "Bob")
        let passport = Passport(number: "A123456", owner: person)
        person.passport = passport
        
        passport.displayInfo()
    }  // Both deallocated together
    print()
    
    print("✅ DELEGATE PATTERN:")
    do {
        let vc = ViewController(name: "MainVC")
        vc.fetcher?.fetchData()
        sleep(2)  // Wait for async completion
    }
    print()
    
    print("✅ PARENT-CHILD RELATIONSHIP:")
    do {
        let parent = ParentViewController(name: "ParentVC")
        let child1 = ChildViewController(name: "Child1")
        let child2 = ChildViewController(name: "Child2")
        
        parent.addChild(child1)
        parent.addChild(child2)
        
        child1.notifyParent()
        
        parent.removeChild(child1)
    }
    print()
}

// Uncomment to run:
// runExample7()
