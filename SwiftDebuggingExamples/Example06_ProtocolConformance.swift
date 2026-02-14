// =============================================================================
// EXAMPLE 6: Protocol Conformance Issues
// =============================================================================
//
// DIFFICULTY: Beginner-Intermediate
// TOPIC: Protocols, Delegates, Protocol Extensions
// APPLE INTERVIEW TIP: Protocols are the backbone of Swift and Apple's
//   frameworks. The delegate pattern (built on protocols) is used EVERYWHERE
//   in UIKit. Understanding protocol conformance is essential.
//
// WHAT YOU WILL LEARN:
//   - Common protocol conformance mistakes
//   - How the delegate pattern works
//   - Protocol extensions and default implementations
//   - Class-only protocols (AnyObject)
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

// BUG 1: Protocol with class-specific features used on a struct
protocol DataDelegate {
    func didReceiveData(_ data: [String])
    func didFailWithError(_ error: Error)
}

class NetworkManager {
    // BUG 2: Delegate should be weak to avoid retain cycles,
    // but 'weak' only works with class (reference) types
    var delegate: DataDelegate?  // Not weak — potential retain cycle!
    
    func fetchData() {
        // Simulate success
        delegate?.didReceiveData(["Result 1", "Result 2"])
    }
}

// BUG 3: Forgot to conform to all required protocol methods
class ViewController {
    let manager = NetworkManager()
    
    func setup() {
        manager.delegate = self  // ERROR: ViewController doesn't conform to DataDelegate
    }
}

// Incomplete conformance — missing didFailWithError
extension ViewController: DataDelegate {
    func didReceiveData(_ data: [String]) {
        print("Got data: \(data)")
    }
    // MISSING: func didFailWithError(_ error: Error) — compile error!
}

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// BUG 1 & 2: To use 'weak' with a delegate (which you almost always should),
// the protocol must be constrained to class types. Otherwise, a struct could
// conform to it, and structs can't be weak references.
//
// BUG 3: When you declare conformance to a protocol, you MUST implement ALL
// required methods. Missing even one causes a compile error. This is actually
// a safety feature — but you can use protocol extensions to provide defaults.
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE
// ---------------------------------------------------------------------------

// Define a custom error type for our examples
enum NetworkError: Error {
    case noConnection
    case timeout
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .noConnection: return "No internet connection"
        case .timeout: return "Request timed out"
        case .invalidResponse: return "Invalid server response"
        }
    }
}

// FIX 1: Constrain protocol to AnyObject (class-only)
// This allows the delegate to be 'weak'
protocol DataDelegate: AnyObject {
    func didReceiveData(_ data: [String])
    func didFailWithError(_ error: Error)
    
    // Optional-like method: provide a default in extension
    func didStartLoading()
    func didFinishLoading()
}

// FIX 2: Protocol extension provides default implementations
// Methods with defaults become "optional" — conforming types don't HAVE to implement them
extension DataDelegate {
    func didStartLoading() {
        print("Loading started... (default implementation)")
    }
    
    func didFinishLoading() {
        print("Loading finished. (default implementation)")
    }
}

class NetworkManager {
    // FIX 3: Now we can use 'weak' because DataDelegate is class-only
    weak var delegate: DataDelegate?
    
    func fetchData(shouldSucceed: Bool = true) {
        delegate?.didStartLoading()
        
        if shouldSucceed {
            delegate?.didReceiveData(["Result 1", "Result 2", "Result 3"])
        } else {
            delegate?.didFailWithError(NetworkError.noConnection)
        }
        
        delegate?.didFinishLoading()
    }
}

// FIX 4: Implement ALL required protocol methods
class ViewController: DataDelegate {
    let manager = NetworkManager()
    
    init() {
        manager.delegate = self
    }
    
    // Required: Must implement
    func didReceiveData(_ data: [String]) {
        print("ViewController received data: \(data)")
    }
    
    // Required: Must implement
    func didFailWithError(_ error: Error) {
        print("ViewController got error: \(error.localizedDescription)")
    }
    
    // Optional: didStartLoading and didFinishLoading have defaults,
    // but we can override didStartLoading with custom behavior:
    func didStartLoading() {
        print("Custom loading indicator shown...")
    }
    // didFinishLoading uses the default from the protocol extension
    
    deinit {
        print("ViewController deinitialized")
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify protocol conformance works correctly
// ---------------------------------------------------------------------------

print("=== Test 1: Successful data fetch ===")
var vc: ViewController? = ViewController()
vc?.manager.fetchData(shouldSucceed: true)

print("\n=== Test 2: Failed data fetch ===")
vc?.manager.fetchData(shouldSucceed: false)

print("\n=== Test 3: Verify weak delegate (no retain cycle) ===")
vc = nil  // Should print "ViewController deinitialized"


// ---------------------------------------------------------------------------
// BONUS: Protocol Composition & Multiple Conformance
// ---------------------------------------------------------------------------

protocol Displayable {
    var displayName: String { get }
}

protocol Searchable {
    func matches(query: String) -> Bool
}

// A struct can conform to multiple protocols
struct Contact: Displayable, Searchable {
    let firstName: String
    let lastName: String
    let email: String
    
    // Displayable conformance
    var displayName: String {
        return "\(firstName) \(lastName)"
    }
    
    // Searchable conformance
    func matches(query: String) -> Bool {
        let lowered = query.lowercased()
        return firstName.lowercased().contains(lowered)
            || lastName.lowercased().contains(lowered)
            || email.lowercased().contains(lowered)
    }
}

// Protocol composition: require BOTH protocols
func displaySearchResults(_ items: [Displayable & Searchable], query: String) {
    let results = items.filter { $0.matches(query: query) }
    if results.isEmpty {
        print("No results for '\(query)'")
    } else {
        print("Results for '\(query)':")
        results.forEach { print("  - \($0.displayName)") }
    }
}

print("\n=== Protocol Composition Test ===")
let contacts = [
    Contact(firstName: "Tim", lastName: "Cook", email: "tcook@apple.com"),
    Contact(firstName: "Craig", lastName: "Federighi", email: "hair@apple.com"),
    Contact(firstName: "Jony", lastName: "Ive", email: "design@apple.com")
]

displaySearchResults(contacts, query: "cook")
displaySearchResults(contacts, query: "apple")
displaySearchResults(contacts, query: "xyz")


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "What is the difference between a protocol method declared in the protocol
//     definition vs one declared only in a protocol extension?"
//
// A: This is about STATIC vs DYNAMIC dispatch:
//
//    protocol Animal {
//        func speak()           // Declared in protocol → DYNAMIC dispatch
//    }
//    extension Animal {
//        func speak() { print("...") }  // Default implementation
//        func eat() { print("nom") }    // ONLY in extension → STATIC dispatch
//    }
//
//    class Dog: Animal {
//        func speak() { print("Woof!") }
//        func eat() { print("Dog food!") }
//    }
//
//    let dog: Animal = Dog()
//    dog.speak()  // "Woof!" — Dynamic dispatch: calls Dog's implementation
//    dog.eat()    // "nom"   — Static dispatch: calls extension's implementation!
//                 //           Even though Dog has its own eat(), the protocol
//                 //           type uses the extension version because eat()
//                 //           wasn't declared in the protocol itself.
//
//    let dog2: Dog = Dog()
//    dog2.eat()   // "Dog food!" — When the type is Dog (not Animal), it
//                 //               calls Dog's version.
//
//    This is a VERY subtle bug source and a favorite interview topic.
// ---------------------------------------------------------------------------
