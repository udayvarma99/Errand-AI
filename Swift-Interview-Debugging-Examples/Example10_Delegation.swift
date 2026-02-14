// ============================================================================
// EXAMPLE 10: Delegation Pattern Mistakes
// Difficulty: Intermediate
// Topic: The Delegate pattern, weak references, protocol requirements
// ============================================================================

// ============================================================================
// WHAT IS THE DELEGATE PATTERN?
// ============================================================================
// Delegation is one of the most important design patterns in iOS development.
// It allows one object to delegate (hand off) some of its work to another
// object. Apple uses it EVERYWHERE:
//
//   - UITableViewDelegate / UITableViewDataSource
//   - UITextFieldDelegate
//   - URLSessionDelegate
//   - CLLocationManagerDelegate
//
// How it works:
//   1. Object A defines a protocol (the "delegate contract")
//   2. Object A has a `delegate` property
//   3. Object B conforms to the protocol and sets itself as the delegate
//   4. Object A calls delegate methods when events happen
// ============================================================================


// ============================================================================
// BUGGY CODE — Try to spot the bugs before reading the explanation!
// ============================================================================

/*

// Bug 1: Delegate is strong — causes retain cycle!
protocol DownloadDelegate {
    func downloadDidFinish(data: String)
    func downloadDidFail(error: String)
}

class Downloader {
    var delegate: DownloadDelegate?  // BUG: Strong reference!

    func startDownload() {
        // Simulate async download
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.delegate?.downloadDidFinish(data: "File contents")
        }
    }

    deinit { print("Downloader deallocated") }
}

class ViewController: DownloadDelegate {
    var downloader: Downloader?  // Strong reference to Downloader

    func setup() {
        downloader = Downloader()
        downloader?.delegate = self  // Downloader -> self (strong)
        // self -> downloader (strong) and downloader -> self (strong)
        // RETAIN CYCLE! Neither gets deallocated! 💥
    }

    func downloadDidFinish(data: String) {
        print("Got data: \(data)")
    }

    func downloadDidFail(error: String) {
        print("Error: \(error)")
    }

    deinit { print("ViewController deallocated") }
}


// Bug 2: Forgetting to set the delegate
class TextField {
    weak var delegate: TextFieldDelegate?

    func userTyped(text: String) {
        delegate?.textDidChange(text: text)  // delegate is nil! Nothing happens!
    }
}

protocol TextFieldDelegate: AnyObject {
    func textDidChange(text: String)
}

class FormController: TextFieldDelegate {
    let textField = TextField()

    init() {
        // BUG: Forgot to set textField.delegate = self!
    }

    func textDidChange(text: String) {
        print("User typed: \(text)")  // Never called because delegate is nil
    }
}


// Bug 3: Delegate method not called because object is deallocated
class NetworkManager {
    weak var delegate: NetworkDelegate?

    func fetchData() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.delegate?.dataDidLoad(data: "Server response")
            // BUG: By the time this fires, the delegate may have been
            // deallocated (since it's weak), so nothing happens!
        }
    }
}

protocol NetworkDelegate: AnyObject {
    func dataDidLoad(data: String)
}


// Bug 4: Using struct as delegate (can't be weak)
protocol GameDelegate {
    func gameDidEnd(score: Int)
}

struct ScoreTracker: GameDelegate {  // BUG: struct can't be weak!
    func gameDidEnd(score: Int) {
        print("Final score: \(score)")
    }
}

class Game {
    weak var delegate: GameDelegate?  // 💥 Compile error!
    // `weak` can only be applied to class and class-bound protocol types
}

*/


// ============================================================================
// WHY IS IT BUGGY?
// ============================================================================
//
// Bug 1: If the delegate is a strong reference and the delegate also holds
//         a strong reference back (common pattern), you get a retain cycle.
//         Neither object can be freed from memory.
//
// Bug 2: The most common delegation bug! If you forget to set the delegate
//         property, delegate calls silently do nothing (because it's nil).
//
// Bug 3: With a weak delegate, the delegate object can be freed before the
//         async callback fires. The callback then finds delegate == nil.
//
// Bug 4: `weak` only works with reference types (classes). Structs are value
//         types and can't be weakly referenced. The protocol must be marked
//         as class-bound with `: AnyObject`.
// ============================================================================


// ============================================================================
// FIXED CODE — Here's how to do it safely
// ============================================================================

import Foundation

// Fix 1: Make delegate WEAK and protocol class-bound (AnyObject)
protocol DownloadDelegate: AnyObject {  // AnyObject = only classes can conform
    func downloadDidFinish(data: String)
    func downloadDidFail(error: String)
}

class Downloader {
    weak var delegate: DownloadDelegate?  // WEAK — breaks retain cycle!

    func startDownload() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.downloadDidFinish(data: "File contents")
        }
    }

    deinit { print("Downloader deallocated") }
}

class ViewController: DownloadDelegate {
    var downloader: Downloader?

    func setup() {
        downloader = Downloader()
        downloader?.delegate = self  // Now weak — no retain cycle!
        downloader?.startDownload()
    }

    func downloadDidFinish(data: String) {
        print("Got data: \(data)")
    }

    func downloadDidFail(error: String) {
        print("Error: \(error)")
    }

    deinit { print("ViewController deallocated") }
}

// Test it:
var vc: ViewController? = ViewController()
vc?.setup()
Thread.sleep(forTimeInterval: 1)  // Wait for download
vc = nil  // Both ViewController AND Downloader are properly deallocated!


// Fix 2: ALWAYS remember to set the delegate
protocol TextFieldDelegate: AnyObject {
    func textDidChange(text: String)
}

class TextField {
    weak var delegate: TextFieldDelegate?

    func userTyped(text: String) {
        if let delegate = delegate {
            delegate.textDidChange(text: text)
        } else {
            print("WARNING: No delegate set for TextField!")
            // In production, this might be a silent no-op,
            // but logging it helps during development
        }
    }
}

class FormController: TextFieldDelegate {
    let textField = TextField()

    init() {
        textField.delegate = self  // Don't forget this line!
    }

    func textDidChange(text: String) {
        print("User typed: \(text)")
    }
}

let form = FormController()
form.textField.userTyped(text: "Hello!")  // Now prints: "User typed: Hello!"


// Fix 3: Use completion handlers for one-time callbacks instead of delegates
// (Delegates are better for ongoing relationships; closures for one-shots)

class NetworkManager {
    // Option A: Keep delegate for ongoing updates
    weak var delegate: NetworkDelegate?

    // Option B: Use a completion closure for one-time results (BETTER for async)
    func fetchData(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let data = "Server response"
            DispatchQueue.main.async {
                completion(data)  // Always called, regardless of delegate lifecycle
            }
        }
    }
}

protocol NetworkDelegate: AnyObject {
    func dataDidLoad(data: String)
}

// Using the completion handler approach:
let manager = NetworkManager()
manager.fetchData { data in
    print("Received: \(data)")
}
Thread.sleep(forTimeInterval: 1)


// Fix 4: Use AnyObject constraint so only classes can be delegates
protocol GameDelegate: AnyObject {  // AnyObject = classes only!
    func gameDidEnd(score: Int)
}

// Use a CLASS instead of struct for the delegate
class ScoreTracker: GameDelegate {
    func gameDidEnd(score: Int) {
        print("Final score: \(score)")
    }
}

class Game {
    weak var delegate: GameDelegate?  // Now works! AnyObject ensures class type
    var score: Int = 0

    func play() {
        score = Int.random(in: 50...100)
        print("Game over!")
        delegate?.gameDidEnd(score: score)
    }
}

let tracker = ScoreTracker()
let game = Game()
game.delegate = tracker
game.play()  // Prints: "Game over!" then "Final score: 73" (or similar)


// ============================================================================
// BONUS: Modern alternatives to the Delegate pattern
// ============================================================================

// 1. Closures / Completion Handlers (for one-time callbacks)
class ModernDownloader {
    func download(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(.success("Downloaded data from \(url)"))
        }
    }
}

let dl = ModernDownloader()
dl.download(url: "https://api.example.com") { result in
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print("Error: \(error)")
    }
}

// 2. Combine framework (reactive streams)
// import Combine
// let publisher = URLSession.shared.dataTaskPublisher(for: url)
//     .map { $0.data }
//     .decode(type: User.self, decoder: JSONDecoder())
//     .sink(receiveCompletion: { ... }, receiveValue: { user in ... })

// 3. async/await (modern Swift concurrency)
// func fetchUser() async throws -> User {
//     let (data, _) = try await URLSession.shared.data(from: url)
//     return try JSONDecoder().decode(User.self, from: data)
// }


// ============================================================================
// INTERVIEW TIPS
// ============================================================================
//
// 1. "Explain the Delegate pattern."
//    Answer: One object defines a protocol (contract), has a weak delegate
//    property, and calls delegate methods when events occur. Another object
//    conforms to the protocol and sets itself as the delegate to respond
//    to those events. Example: UITableViewDelegate.
//
// 2. "Why should delegates be weak?"
//    Answer: To prevent retain cycles. The delegating object (e.g., a table
//    view) holds the delegate weakly. The delegate (e.g., view controller)
//    holds the delegating object strongly. If both were strong, neither
//    could be freed.
//
// 3. "Why does the delegate protocol inherit from AnyObject?"
//    Answer: `weak` only works with reference types. AnyObject constrains
//    the protocol to classes only, allowing the delegate property to be weak.
//
// 4. "When would you use delegation vs closures vs Combine?"
//    Answer:
//    - Delegation: Ongoing relationships with multiple callbacks
//      (e.g., UITableViewDelegate with many methods)
//    - Closures: One-time callbacks (e.g., network request completion)
//    - Combine/async-await: Streams of values over time, complex async chains
//
// 5. "What's the most common delegation bug?"
//    Answer: Forgetting to set the delegate! The delegate is nil by default,
//    so delegate method calls silently do nothing.
// ============================================================================
