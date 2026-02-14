// =============================================================================
// EXAMPLE 7: Enum & Switch Exhaustiveness
// =============================================================================
//
// DIFFICULTY: Beginner-Intermediate
// TOPIC: Enums, Pattern Matching, Switch Statements, Associated Values
// APPLE INTERVIEW TIP: Swift enums are far more powerful than enums in most
//   other languages. They can have associated values, raw values, methods,
//   and computed properties. Mastering enums will impress interviewers.
//
// WHAT YOU WILL LEARN:
//   - Why switch must be exhaustive in Swift
//   - Dangers of using 'default' in switch
//   - Enums with associated values
//   - Common bugs with raw values
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bugs before scrolling down!
// ---------------------------------------------------------------------------

/*

// BUG 1: Using 'default' hides missing cases when enum evolves
enum PaymentMethod {
    case creditCard
    case debitCard
    case applePay
    case cash
}

func processPayment(_ method: PaymentMethod) {
    switch method {
    case .creditCard:
        print("Processing credit card...")
    case .debitCard:
        print("Processing debit card...")
    default:
        // BUG: When someone adds a new case (e.g., .crypto), this silently
        // handles it with the default — no compile warning that new cases
        // need special handling. This can lead to incorrect behavior.
        print("Processing other payment...")
    }
}


// BUG 2: Incorrect raw value comparison
enum HTTPStatus: Int {
    case ok = 200
    case notFound = 404
    case serverError = 500
}

func handleResponse(statusCode: Int) {
    // BUG: Comparing the enum directly to an Int without using rawValue
    let status = HTTPStatus(rawValue: statusCode)
    
    // BUG: Force-unwrapping — crashes if statusCode is not 200, 404, or 500
    print("Status: \(status!)")
}


// BUG 3: Missing associated value extraction
enum Result {
    case success(data: [String])
    case failure(error: String)
}

func handleResult(_ result: Result) {
    switch result {
    case .success:
        // BUG: Forgot to extract the associated value!
        print("Success! Data: ???")  // Can't access data
    case .failure:
        // BUG: Same — forgot to extract the error string
        print("Failed!")
    }
}

*/


// ---------------------------------------------------------------------------
// WHY ARE THESE BUGS?
// ---------------------------------------------------------------------------
//
// BUG 1: Using 'default' in a switch on your own enum defeats Swift's
// exhaustiveness checking. When you add a new enum case later, the compiler
// won't warn you that you forgot to handle it. This leads to subtle bugs
// that only appear at runtime.
//
// BUG 2: Force-unwrapping an enum created from rawValue crashes when the
// raw value doesn't match any case. Not all integers are valid HTTP statuses.
//
// BUG 3: Enum cases with associated values contain useful data. If you don't
// extract it in your switch, you lose access to that data.
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE
// ---------------------------------------------------------------------------

// FIX 1: Handle ALL cases explicitly — no default
enum PaymentMethod {
    case creditCard(last4: String)
    case debitCard(last4: String)
    case applePay
    case cash
    // If someone adds .crypto here, the compiler will immediately show errors
    // in every switch statement that doesn't handle it. This is GOOD!
}

func processPayment(_ method: PaymentMethod) -> String {
    // Handle every case explicitly
    switch method {
    case .creditCard(let last4):
        return "Processing credit card ending in \(last4)..."
    case .debitCard(let last4):
        return "Processing debit card ending in \(last4)..."
    case .applePay:
        return "Processing Apple Pay..."
    case .cash:
        return "Processing cash payment..."
    // NO default: If a new case is added, the compiler forces us to handle it
    }
}


// FIX 2: Safely handle raw value initialization
enum HTTPStatus: Int {
    case ok = 200
    case created = 201
    case noContent = 204
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case serverError = 500
}

func handleResponse(statusCode: Int) -> String {
    // rawValue init returns Optional — handle it safely
    guard let status = HTTPStatus(rawValue: statusCode) else {
        return "Unknown status code: \(statusCode)"
    }
    
    switch status {
    case .ok:
        return "Success (200)"
    case .created:
        return "Resource created (201)"
    case .noContent:
        return "No content (204)"
    case .badRequest:
        return "Bad request (400)"
    case .unauthorized:
        return "Unauthorized — please login (401)"
    case .notFound:
        return "Resource not found (404)"
    case .serverError:
        return "Server error (500)"
    }
}


// FIX 3: Properly extract associated values
enum FetchResult {
    case success(data: [String])
    case failure(error: String)
    case loading(progress: Double)
}

func handleResult(_ result: FetchResult) {
    switch result {
    case .success(let data):
        // Now we have access to the data!
        print("Success! Got \(data.count) items:")
        data.forEach { print("  - \($0)") }
        
    case .failure(let error):
        // Now we have access to the error message!
        print("Failed with error: \(error)")
        
    case .loading(let progress):
        let percentage = Int(progress * 100)
        print("Loading... \(percentage)%")
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify all fixes work correctly
// ---------------------------------------------------------------------------

print("=== Payment Processing ===")
print(processPayment(.creditCard(last4: "4242")))
print(processPayment(.applePay))
print(processPayment(.cash))

print("\n=== HTTP Status Handling ===")
print(handleResponse(statusCode: 200))
print(handleResponse(statusCode: 404))
print(handleResponse(statusCode: 302))  // Unknown — safely handled!
print(handleResponse(statusCode: 999))  // Unknown — safely handled!

print("\n=== Result Handling ===")
handleResult(.success(data: ["SwiftUI", "UIKit", "Combine"]))
handleResult(.failure(error: "Network timeout"))
handleResult(.loading(progress: 0.65))


// ---------------------------------------------------------------------------
// BONUS: Powerful Enum Techniques for Interviews
// ---------------------------------------------------------------------------

// Enums can have computed properties and methods!
enum Planet: Int, CaseIterable {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
    
    var name: String {
        // Using String(describing:) to get the case name
        return String(describing: self).capitalized
    }
    
    var isHabitable: Bool {
        return self == .earth
    }
    
    var distanceFromSun: String {
        switch self {
        case .mercury: return "57.9 million km"
        case .venus:   return "108.2 million km"
        case .earth:   return "149.6 million km"
        case .mars:    return "227.9 million km"
        case .jupiter: return "778.6 million km"
        case .saturn:  return "1,433.5 million km"
        case .uranus:  return "2,872.5 million km"
        case .neptune: return "4,495.1 million km"
        }
    }
}

print("\n=== Enum with Methods & CaseIterable ===")
// CaseIterable gives us .allCases for free!
for planet in Planet.allCases {
    let habitable = planet.isHabitable ? " (Habitable!)" : ""
    print("\(planet.name): \(planet.distanceFromSun)\(habitable)")
}


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "How would you model a network response that can be either loading,
//     success with data, or failure with an error, using Swift's type system?"
//
// A: Use an enum with associated values — this is the idiomatic Swift way:
//
//    enum NetworkState<T> {
//        case idle
//        case loading
//        case success(T)
//        case failure(Error)
//    }
//
//    // Usage in a view model:
//    class UserViewModel {
//        var state: NetworkState<[User]> = .idle
//
//        func loadUsers() {
//            state = .loading
//            api.fetchUsers { [weak self] result in
//                switch result {
//                case .success(let users):
//                    self?.state = .success(users)
//                case .failure(let error):
//                    self?.state = .failure(error)
//                }
//            }
//        }
//    }
//
//    This approach:
//    - Makes impossible states impossible (can't have data AND error)
//    - Forces you to handle all states in the UI
//    - Is type-safe (generic T gives you the right data type)
//    - Is the pattern used by Swift's own Result type
// ---------------------------------------------------------------------------
