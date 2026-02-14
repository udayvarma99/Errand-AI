// ============================================================================
// EXAMPLE 9: Enum & Switch Statement Pitfalls
// Difficulty: Beginner
// Topic: Enum associated values, exhaustive switch, raw values, common mistakes
// ============================================================================

// ============================================================================
// WHAT ARE ENUMS IN SWIFT?
// ============================================================================
// An enum (enumeration) defines a group of related values. Unlike enums in
// many other languages, Swift enums are VERY powerful — they can have:
//   - Associated values (data attached to each case)
//   - Raw values (pre-assigned values like Int or String)
//   - Methods and computed properties
//   - Protocol conformance
//
//   enum Direction {
//       case north, south, east, west
//   }
//   let heading: Direction = .north
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Non-exhaustive switch statement
enum Weather {
    case sunny
    case cloudy
    case rainy
    case snowy
}

func getAdvice(for weather: Weather) -> String {
    switch weather {
    case .sunny:
        return "Wear sunglasses!"
    case .cloudy:
        return "Might want a jacket."
    case .rainy:
        return "Take an umbrella!"
    // Missing .snowy case! 💥 Compile error: Switch must be exhaustive
    }
}


// Bug 2: Using `default` and missing a new case later
enum PaymentMethod {
    case creditCard
    case debitCard
    case cash
    // Developer later adds: case applePay
}

func processPayment(method: PaymentMethod) {
    switch method {
    case .creditCard:
        print("Processing credit card...")
    case .debitCard:
        print("Processing debit card...")
    default:
        print("Processing other payment...")
        // BUG: When .applePay is added, it silently falls into default
        // instead of getting its own handling. No compiler warning!
    }
}


// Bug 3: Comparing enum with associated values incorrectly
enum NetworkError {
    case timeout(seconds: Int)
    case serverError(code: Int)
    case noConnection
}

let error: NetworkError = .timeout(seconds: 30)

// This doesn't work! Can't use == on enums with associated values
// unless you conform to Equatable
if error == .timeout(seconds: 30) {  // 💥 Compile error!
    print("It was a timeout")
}


// Bug 4: Forgetting to handle associated values in switch
enum Result {
    case success(data: String)
    case failure(error: String)
}

let result: Result = .success(data: "User profile loaded")

switch result {
case .success:  // BUG: Not extracting the data!
    print("Success!")
    // But WHERE is the data? We ignored it.
case .failure:
    print("Failed!")
    // But WHAT was the error? We ignored it.
}


// Bug 5: Raw value enum with duplicate values
enum StatusCode: Int {
    case ok = 200
    case created = 201
    case badRequest = 400
    // case notFound = 400  // 💥 Compile error: duplicate raw value!
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: Swift requires switch statements on enums to be exhaustive — you
//         must handle EVERY case. This is a safety feature!
//
// Bug 2: Using `default` is dangerous because when you add new enum cases,
//         the compiler can't warn you that you haven't handled them.
//
// Bug 3: Enums with associated values don't automatically conform to
//         Equatable. You need to add conformance explicitly.
//
// Bug 4: If your enum has associated values and you don't extract them in
//         the switch, you lose access to important data.
//
// Bug 5: Each raw value in an enum must be unique. Duplicate values cause
//         a compile error.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

// Fix 1: Handle ALL enum cases in switch
enum Weather {
    case sunny
    case cloudy
    case rainy
    case snowy
}

func getAdvice(for weather: Weather) -> String {
    switch weather {
    case .sunny:
        return "Wear sunglasses!"
    case .cloudy:
        return "Might want a jacket."
    case .rainy:
        return "Take an umbrella!"
    case .snowy:
        return "Bundle up! It's snowing!"
    }
    // All cases handled — no `default` needed!
    // If we add a new case later, the compiler will warn us.
}

print(getAdvice(for: .snowy))  // "Bundle up! It's snowing!"


// Fix 2: Use @unknown default for future-proofing (when default is needed)
enum PaymentMethod {
    case creditCard
    case debitCard
    case cash
    case applePay  // Newly added!
}

func processPayment(method: PaymentMethod) {
    switch method {
    case .creditCard:
        print("Processing credit card...")
    case .debitCard:
        print("Processing debit card...")
    case .cash:
        print("Processing cash...")
    case .applePay:
        print("Processing Apple Pay...")
    // If you MUST use default (e.g., for framework enums), use @unknown:
    // @unknown default:
    //     print("New payment method — needs handling!")
    //     // @unknown generates a WARNING when new cases are added
    }
}

processPayment(method: .applePay)  // "Processing Apple Pay..."


// Fix 3: Make enum with associated values conform to Equatable
enum NetworkError: Equatable {  // Add Equatable conformance!
    case timeout(seconds: Int)
    case serverError(code: Int)
    case noConnection
}

let error: NetworkError = .timeout(seconds: 30)

// Now == works!
if error == .timeout(seconds: 30) {
    print("It was a 30-second timeout!")  // This prints!
}

if error == .timeout(seconds: 10) {
    print("It was a 10-second timeout!")
} else {
    print("Not a 10-second timeout")  // This prints
}

// You can also use switch with pattern matching:
switch error {
case .timeout(let seconds) where seconds > 20:
    print("Long timeout: \(seconds) seconds")
case .timeout(let seconds):
    print("Short timeout: \(seconds) seconds")
case .serverError(let code):
    print("Server error with code: \(code)")
case .noConnection:
    print("No internet connection")
}


// Fix 4: Always extract associated values when you need them
enum Result {
    case success(data: String)
    case failure(error: String)
}

let result: Result = .success(data: "User profile loaded")

switch result {
case .success(let data):       // Extract the data!
    print("Success! Data: \(data)")
case .failure(let error):      // Extract the error!
    print("Failed! Error: \(error)")
}

// You can also use `if case` for single-case matching:
if case .success(let data) = result {
    print("Got data: \(data)")
}


// Fix 5: Use unique raw values, and use initializer safely
enum StatusCode: Int {
    case ok = 200
    case created = 201
    case badRequest = 400
    case notFound = 404       // Unique value!
    case serverError = 500
}

// Create from raw value safely (returns Optional)
if let status = StatusCode(rawValue: 200) {
    print("Status: \(status)")  // "Status: ok"
} else {
    print("Unknown status code")
}

// Unknown raw value returns nil (not a crash!)
let unknown = StatusCode(rawValue: 999)
print("Unknown: \(String(describing: unknown))")  // "Unknown: nil"


// ============================================================================
// BONUS: Advanced enum patterns used in Apple interviews
// ============================================================================

// Recursive enums (for tree-like data structures)
indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case .number(let value):
        return value
    case .addition(let left, let right):
        return evaluate(left) + evaluate(right)
    case .multiplication(let left, let right):
        return evaluate(left) * evaluate(right)
    }
}

// (5 + 3) * 2 = 16
let expr = ArithmeticExpression.multiplication(
    .addition(.number(5), .number(3)),
    .number(2)
)
print("Result: \(evaluate(expr))")  // 16


// Enum with methods and computed properties
enum Coin: Double {
    case penny = 0.01
    case nickel = 0.05
    case dime = 0.10
    case quarter = 0.25

    var name: String {
        switch self {
        case .penny: return "Penny"
        case .nickel: return "Nickel"
        case .dime: return "Dime"
        case .quarter: return "Quarter"
        }
    }

    func count(number: Int) -> Double {
        return rawValue * Double(number)
    }
}

let coin = Coin.quarter
print("\(coin.name) x 4 = $\(coin.count(number: 4))")  // "Quarter x 4 = $1.0"


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "What makes Swift enums different from other languages?"
//    Answer: Swift enums can have associated values, raw values, methods,
//    computed properties, and conform to protocols. They're much more powerful
//    than C/Java enums.
//
// 2. "Why should you avoid `default` in switch statements on enums?"
//    Answer: If you add a new case, `default` silently handles it without
//    a compiler warning. Without `default`, the compiler forces you to
//    handle every case explicitly. Use `@unknown default` as a compromise.
//
// 3. "What is pattern matching in Swift?"
//    Answer: Pattern matching lets you check and extract values in switch
//    statements, if-case, guard-case, and for-case. It's one of Swift's
//    most powerful features.
//
// 4. "What is an indirect enum?"
//    Answer: An enum that can reference itself in its associated values.
//    Used for recursive data structures like trees and linked lists.
// ============================================================================
