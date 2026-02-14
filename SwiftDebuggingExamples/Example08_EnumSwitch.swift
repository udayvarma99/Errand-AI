// =============================================================================
// EXAMPLE 8: Enum and Switch Exhaustiveness Bug
// Topic: Missing switch cases, incorrect associated value extraction
// Difficulty: Beginner
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

enum NetworkError {
    case timeout
    case notFound
    case unauthorized
    case serverError(code: Int)
}

// BUG 1: Non-exhaustive switch — missing cases
func handleError(_ error: NetworkError) {
    switch error {
    case .timeout:
        print("Request timed out. Please try again.")
    case .notFound:
        print("Resource not found.")
    // ERROR: Switch must be exhaustive
    // Missing: .unauthorized and .serverError
    }
}


// BUG 2: Not extracting associated values correctly
func describeError(_ error: NetworkError) -> String {
    switch error {
    case .serverError:  // BUG: Not extracting the 'code' associated value
        return "Server error occurred"  // Lost the error code!
    default:
        return "Some error"
    }
}

// BUG 3: Using a default case that hides future additions
enum PaymentMethod {
    case creditCard
    case debitCard
    case cash
}

func processPayment(_ method: PaymentMethod) {
    switch method {
    case .creditCard:
        print("Processing credit card")
    default:  // BUG: If someone adds .applePay later, this silently catches it
        print("Processing other payment")
    }
}

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: Swift requires switch statements on enums to be EXHAUSTIVE —
//         every possible case must be handled. Missing cases cause a compile error.
//
// Bug 2: When an enum case has associated values, not extracting them means
//         you lose important data.
//
// Bug 3: Using 'default' can hide bugs when new enum cases are added later.
//         The compiler won't warn you that you forgot to handle the new case.
//

// =============================================================================
// FIXED CODE
// =============================================================================

// --- Fix 1: Handle ALL enum cases ---

enum NetworkError {
    case timeout
    case notFound
    case unauthorized
    case serverError(code: Int)
}

func handleError(_ error: NetworkError) {
    switch error {
    case .timeout:
        print("Request timed out. Please try again.")
    case .notFound:
        print("Resource not found (404).")
    case .unauthorized:                          // FIX: Handle this case
        print("You are not authorized. Please log in.")
    case .serverError(let code):                 // FIX: Handle with associated value
        print("Server error with code: \(code)")
    }
}

// --- Fix 2: Extract and use associated values ---

func describeError(_ error: NetworkError) -> String {
    switch error {
    case .timeout:
        return "Request timed out"
    case .notFound:
        return "Resource not found"
    case .unauthorized:
        return "Unauthorized access"
    case .serverError(let code):  // FIX: Extract the code!
        return "Server error (HTTP \(code))"
    }
}

// --- Fix 3: Avoid 'default' — list all cases explicitly ---

enum PaymentMethod {
    case creditCard
    case debitCard
    case cash
    case applePay    // New case added later
}

func processPayment(_ method: PaymentMethod) {
    switch method {
    case .creditCard:
        print("Processing credit card")
    case .debitCard:
        print("Processing debit card")
    case .cash:
        print("Processing cash payment")
    case .applePay:
        print("Processing Apple Pay")
    // No 'default' — if a new case is added, the compiler will WARN us!
    }
}

// --- Test all fixes ---
print("=== Fix 1: Exhaustive switch ===")
handleError(.timeout)
handleError(.notFound)
handleError(.unauthorized)
handleError(.serverError(code: 503))

print("\n=== Fix 2: Extract associated values ===")
print(describeError(.timeout))
print(describeError(.serverError(code: 500)))

print("\n=== Fix 3: Explicit cases (no default) ===")
processPayment(.creditCard)
processPayment(.applePay)

// =============================================================================
// BONUS: Advanced pattern matching with enums
// =============================================================================

enum Result {
    case success(data: String)
    case failure(error: NetworkError)
}

func handleResult(_ result: Result) {
    switch result {
    // Match specific associated values
    case .success(let data) where data.isEmpty:
        print("Success but no data received")

    case .success(let data):
        print("Success with data: \(data)")

    // Nested pattern matching — match specific error types
    case .failure(.serverError(let code)) where code >= 500:
        print("Critical server error: \(code)")

    case .failure(.unauthorized):
        print("Please log in and try again")

    case .failure(let error):
        print("Failed: \(describeError(error))")
    }
}

print("\n=== Bonus: Advanced pattern matching ===")
handleResult(.success(data: "Hello, World!"))
handleResult(.success(data: ""))
handleResult(.failure(error: .serverError(code: 503)))
handleResult(.failure(error: .unauthorized))
handleResult(.failure(error: .timeout))

// =============================================================================
// BONUS: Raw value enums
// =============================================================================

enum HTTPStatus: Int {
    case ok = 200
    case created = 201
    case notFound = 404
    case serverError = 500
}

// Create from raw value — returns optional!
if let status = HTTPStatus(rawValue: 404) {
    print("\nHTTP Status: \(status) (\(status.rawValue))")  // notFound (404)
}

if let unknown = HTTPStatus(rawValue: 999) {
    print("Found: \(unknown)")
} else {
    print("Unknown HTTP status code")  // This prints
}

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// Switch statements on enums must be exhaustive.
// Always extract associated values when they carry important data.
// Avoid 'default' with your own enums — it hides future bugs.
//
// In interviews, Apple engineers look for:
//   1. Exhaustive switch handling (no missed cases)
//   2. Proper use of associated values
//   3. Pattern matching with 'where' clauses
//   4. Understanding raw values vs associated values
//   5. Knowing when 'default' is appropriate (e.g., with @unknown default
//      for framework enums that might add cases in future OS versions)
//
// Common interview question:
//   "What is the difference between associated values and raw values?"
//   Answer:
//     - Raw values: Same type for all cases, set at compile time
//       (e.g., enum Coin: Int { case penny = 1, nickel = 5 })
//     - Associated values: Different types per case, set at creation time
//       (e.g., enum Result { case success(String), failure(Error) })
// =============================================================================
