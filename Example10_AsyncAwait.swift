/*
 ═══════════════════════════════════════════════════════════════════
 EXAMPLE 10: ASYNC/AWAIT CONCURRENCY
 ═══════════════════════════════════════════════════════════════════
 
 Difficulty: Advanced
 Topic: Modern Swift concurrency patterns
 Common Interview Question: "Explain Swift's async/await and structured concurrency"
 
 ═══════════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE
// ═══════════════════════════════════════════════════════════════════

// Scenario 1: Blocking the main thread with synchronous code

@available(macOS 10.15, iOS 13.0, *)
class DataLoaderBuggy {
    func loadData() -> String {
        // 🐛 BUG: Blocking sleep on main thread!
        Thread.sleep(forTimeInterval: 2)  // 💥 UI freezes!
        return "Data loaded"
    }
    
    func updateUI() {
        let data = loadData()  // Main thread blocked for 2 seconds
        print("UI updated with: \(data)")
    }
}


// Scenario 2: Callback hell (pyramid of doom)

class NetworkManagerBuggy {
    func fetchUserProfile(completion: @escaping (Result<String, Error>) -> Void) {
        fetchUserId { result in
            switch result {
            case .success(let userId):
                self.fetchUserData(userId: userId) { result in
                    switch result {
                    case .success(let userData):
                        self.fetchUserPreferences(userId: userId) { result in
                            switch result {
                            case .success(let prefs):
                                // 🐛 Nested callbacks are hard to read and maintain
                                completion(.success("User: \(userData), Prefs: \(prefs)"))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserId(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion(.success("user123"))
        }
    }
    
    func fetchUserData(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion(.success("Alice"))
        }
    }
    
    func fetchUserPreferences(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion(.success("Dark mode"))
        }
    }
}


// Scenario 3: Race condition with shared state

@available(macOS 10.15, iOS 13.0, *)
class CounterBuggy {
    var count = 0
    
    func incrementAsync() async {
        // 🐛 BUG: Data race!
        let current = count
        try? await Task.sleep(nanoseconds: 1_000_000)
        count = current + 1  // 💥 Lost updates with concurrent access
    }
}


// 🔍 PROBLEM DESCRIPTION
// ═══════════════════════════════════════════════════════════════════
/*
 Swift's modern concurrency (Swift 5.5+) introduces:
 
 1. async/await: Write asynchronous code like synchronous
 2. Actors: Data isolation for thread safety
 3. Structured concurrency: Task hierarchy and cancellation
 4. MainActor: Ensure code runs on main thread
 
 Common issues with old concurrency:
 - Callback hell (nested closures)
 - Thread explosion (too many threads)
 - Main thread blocking
 - Race conditions
 - Difficult error handling
 - No cancellation support
 
 async/await benefits:
 - Linear, readable code
 - Proper error handling with try/catch
 - Automatic context switching
 - Structured concurrency
 - Cancellation support
*/


// 🛠️ DEBUGGING STEPS
// ═══════════════════════════════════════════════════════════════════
/*
 1. Use async/await instead of callbacks
 2. Mark UI code with @MainActor
 3. Use actors for shared mutable state
 4. Enable strict concurrency checking
 5. Use Task for async work
 
 Xcode settings:
 - Build Settings → Swift Compiler
 - Enable "Strict Concurrency Checking"
 - Warnings will show potential data races
 
 Common errors:
 - "Call to async function not in async context"
   → Wrap in Task { } or mark function as async
 - "Expression is 'async' but is not marked with 'await'"
   → Add await keyword
*/


// ✅ FIXED CODE
// ═══════════════════════════════════════════════════════════════════

// SOLUTION 1: Convert to async/await

@available(macOS 10.15, iOS 13.0, *)
class DataLoaderFixed {
    // ✅ Async function
    func loadData() async -> String {
        try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds
        return "Data loaded"
    }
    
    // ✅ Runs on main thread
    @MainActor
    func updateUI() async {
        let data = await loadData()  // Suspends, doesn't block
        print("UI updated with: \(data)")
    }
}


// SOLUTION 2: Eliminate callback hell

@available(macOS 10.15, iOS 13.0, *)
class NetworkManagerFixed {
    // ✅ Clean, linear async code
    func fetchUserProfile() async throws -> String {
        let userId = try await fetchUserId()
        let userData = try await fetchUserData(userId: userId)
        let prefs = try await fetchUserPreferences(userId: userId)
        return "User: \(userData), Prefs: \(prefs)"
    }
    
    func fetchUserId() async throws -> String {
        try await Task.sleep(nanoseconds: 100_000_000)
        return "user123"
    }
    
    func fetchUserData(userId: String) async throws -> String {
        try await Task.sleep(nanoseconds: 100_000_000)
        return "Alice"
    }
    
    func fetchUserPreferences(userId: String) async throws -> String {
        try await Task.sleep(nanoseconds: 100_000_000)
        return "Dark mode"
    }
}


// SOLUTION 3: Use Actor for thread-safe state

@available(macOS 10.15, iOS 13.0, *)
actor Counter {
    // ✅ Actor automatically serializes access
    private var count = 0
    
    func increment() {
        count += 1
    }
    
    func getValue() -> Int {
        return count
    }
}


// SOLUTION 4: Parallel execution with async let

@available(macOS 10.15, iOS 13.0, *)
class ParallelLoader {
    func loadImage() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "🖼️ Image"
    }
    
    func loadData() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "📊 Data"
    }
    
    func loadMetadata() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "ℹ️ Metadata"
    }
    
    // ✅ Load all in parallel
    func loadAllParallel() async -> (String, String, String) {
        async let image = loadImage()
        async let data = loadData()
        async let metadata = loadMetadata()
        
        // All three execute concurrently
        return await (image, data, metadata)
    }
    
    // ❌ Sequential (slower)
    func loadAllSequential() async -> (String, String, String) {
        let image = await loadImage()      // Wait 1s
        let data = await loadData()        // Wait 1s
        let metadata = await loadMetadata() // Wait 1s
        return (image, data, metadata)     // Total: 3s
    }
}


// SOLUTION 5: Task groups for dynamic parallelism

@available(macOS 10.15, iOS 13.0, *)
class BatchProcessor {
    func processItems(_ items: [Int]) async -> [String] {
        await withTaskGroup(of: String.self) { group in
            // ✅ Process all items in parallel
            for item in items {
                group.addTask {
                    return await self.processItem(item)
                }
            }
            
            // Collect results
            var results: [String] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    func processItem(_ item: Int) async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Processed \(item)"
    }
}


// SOLUTION 6: MainActor for UI updates

@available(macOS 10.15, iOS 13.0, *)
@MainActor
class ViewModel {
    // ✅ All properties and methods run on main thread
    var title: String = ""
    var isLoading: Bool = false
    
    func loadContent() async {
        isLoading = true  // Main thread
        
        // Background work
        let content = await NetworkManagerFixed().fetchUserId()
        
        // Back to main thread automatically
        title = content
        isLoading = false
    }
}


// SOLUTION 7: Task cancellation

@available(macOS 10.15, iOS 13.0, *)
class CancellableOperation {
    func performLongOperation() async throws -> String {
        for i in 1...10 {
            // ✅ Check for cancellation
            try Task.checkCancellation()
            
            // Or manually check
            if Task.isCancelled {
                return "Cancelled"
            }
            
            try await Task.sleep(nanoseconds: 100_000_000)
            print("Step \(i)")
        }
        return "Completed"
    }
}


// SOLUTION 8: Combining async/await with Combine

@available(macOS 10.15, iOS 13.0, *)
class AsyncSequenceExample {
    // ✅ Create async sequence
    func numbers() -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                for i in 1...5 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    continuation.yield(i)
                }
                continuation.finish()
            }
        }
    }
    
    func consumeNumbers() async {
        // ✅ Iterate over async sequence
        for await number in numbers() {
            print("Received: \(number)")
        }
    }
}


// 🧪 TEST CASES
// ═══════════════════════════════════════════════════════════════════

@available(macOS 10.15, iOS 13.0, *)
func runExample10() async {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 10: ASYNC/AWAIT CONCURRENCY")
    print("═══════════════════════════════════════════════════════\n")
    
    // Test Case 1: Basic async/await
    print("Test Case 1: Basic Async/Await")
    let loader = DataLoaderFixed()
    let data = await loader.loadData()
    print(data)
    print("✅ Non-blocking async operation\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 2: Sequential async calls
    print("Test Case 2: Sequential Async Calls")
    let network = NetworkManagerFixed()
    do {
        let profile = try await network.fetchUserProfile()
        print(profile)
        print("✅ Clean async code without callbacks\n")
    } catch {
        print("Error: \(error)")
    }
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 3: Actor for thread safety
    print("Test Case 3: Actor Thread Safety")
    let counter = Counter()
    
    // Multiple concurrent increments
    await withTaskGroup(of: Void.self) { group in
        for _ in 1...100 {
            group.addTask {
                await counter.increment()
            }
        }
    }
    
    let count = await counter.getValue()
    print("Counter: \(count)")
    print("✅ No race conditions with actor\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 4: Parallel execution
    print("Test Case 4: Parallel vs Sequential")
    let parallel = ParallelLoader()
    
    let startParallel = Date()
    let resultsParallel = await parallel.loadAllParallel()
    let timeParallel = Date().timeIntervalSince(startParallel)
    print("Parallel: \(resultsParallel) in \(String(format: "%.2f", timeParallel))s")
    
    let startSeq = Date()
    let resultsSeq = await parallel.loadAllSequential()
    let timeSeq = Date().timeIntervalSince(startSeq)
    print("Sequential: \(resultsSeq) in \(String(format: "%.2f", timeSeq))s")
    print("✅ Parallel is ~3x faster\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 5: Task groups
    print("Test Case 5: Task Groups")
    let processor = BatchProcessor()
    let results = await processor.processItems([1, 2, 3, 4, 5])
    print("Results: \(results)")
    print("✅ Dynamic parallel processing\n")
    
    print(String(repeating: "-", count: 50) + "\n")
    
    // Test Case 6: Cancellation
    print("Test Case 6: Task Cancellation")
    let operation = CancellableOperation()
    let task = Task {
        return try await operation.performLongOperation()
    }
    
    // Cancel after 300ms
    try? await Task.sleep(nanoseconds: 300_000_000)
    task.cancel()
    
    let result = try? await task.value
    print("Result: \(result ?? "nil")")
    print("✅ Task cancellation works\n")
}


// 📚 KEY TAKEAWAYS
// ═══════════════════════════════════════════════════════════════════
/*
 1. async/await fundamentals:
    - async: Function can suspend execution
    - await: Suspension point, yields thread
    - try await: For throwing async functions
    - No callback closures needed
 
 2. Actors:
    - Protect mutable state from data races
    - Automatically serialize access
    - Access with 'await' from outside
    - Use for shared mutable state
 
 3. @MainActor:
    - Ensures code runs on main thread
    - For UI updates
    - Can mark properties, methods, or classes
    - Automatically switches to main thread
 
 4. Parallelism:
    - async let: Fixed number of parallel tasks
    - withTaskGroup: Dynamic number of tasks
    - Tasks run concurrently
    - await collects results
 
 5. Structured concurrency:
    - Tasks form a hierarchy
    - Parent task owns child tasks
    - Cancellation propagates down
    - Errors propagate up
 
 6. Task:
    - Task { }: Start new async context
    - Task.detached { }: Unstructured task
    - Task.sleep(): Suspendable delay
    - Task.checkCancellation(): Cooperative cancellation
 
 7. Best practices:
    - Prefer async/await over callbacks
    - Use actors for shared state
    - Mark UI code with @MainActor
    - Handle cancellation
    - Enable strict concurrency checking
*/


// 🎯 APPLE INTERVIEW QUESTIONS RELATED TO THIS
// ═══════════════════════════════════════════════════════════════════
/*
 Q1: "What's the difference between async and await?"
 A1: 'async' marks a function as asynchronous (can suspend). 'await'
     marks a suspension point where the function may yield the thread.
     async is a type annotation, await is used at call sites.
 
 Q2: "How do actors prevent data races?"
 A2: Actors serialize all access to their mutable state. Only one task
     can access an actor's state at a time. Access from outside requires
     'await', which is a suspension point for synchronization.
 
 Q3: "What's the difference between Task and Task.detached?"
 A3: Task inherits priority and context from current task (structured).
     Task.detached creates independent task with no parent relationship
     (unstructured). Prefer Task for structured concurrency.
 
 Q4: "When should you use @MainActor?"
 A4: For code that must run on the main thread, especially UI updates.
     Mark ViewModels, UI helper methods, or properties that update UI.
     SwiftUI views are implicitly @MainActor.
 
 Q5: "How does async/await differ from GCD?"
 A5: async/await provides structured concurrency with linear code flow,
     automatic context switching, and cancellation. GCD uses callbacks,
     manual thread management, and has no built-in cancellation.
 
 Q6: "What's async let used for?"
 A6: For executing a fixed number of async operations in parallel.
     Results are awaited together. Simpler than task groups for small
     sets of parallel operations.
 
 Q7: "How do you handle errors in async code?"
 A7: Use try await for throwing async functions. Errors propagate
     normally through try/catch blocks. Much cleaner than callbacks
     with Result types.
*/


// 💡 ADVANCED: Concurrency Patterns
// ═══════════════════════════════════════════════════════════════════

// Pattern 1: AsyncSequence for streaming
@available(macOS 10.15, iOS 13.0, *)
struct AsyncTimer {
    let interval: TimeInterval
    
    func start() -> AsyncStream<Date> {
        AsyncStream { continuation in
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                continuation.yield(Date())
            }
            
            continuation.onTermination = { _ in
                timer.invalidate()
            }
        }
    }
}


// Pattern 2: Timeout for async operations
@available(macOS 10.15, iOS 13.0, *)
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            return try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

struct TimeoutError: Error { }


// Pattern 3: Actor with nonisolated methods
@available(macOS 10.15, iOS 13.0, *)
actor DataCache {
    private var cache: [String: Data] = [:]
    
    func store(_ data: Data, for key: String) {
        cache[key] = data
    }
    
    func retrieve(for key: String) -> Data? {
        return cache[key]
    }
    
    // nonisolated: Can be called without await
    nonisolated func cacheKey(for url: URL) -> String {
        return url.absoluteString.hashValue.description
    }
}


// Pattern 4: Combining async/await with completion handlers
@available(macOS 10.15, iOS 13.0, *)
func legacyAPICall(completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion("Legacy result")
    }
}

@available(macOS 10.15, iOS 13.0, *)
func modernAsyncWrapper() async -> String {
    await withCheckedContinuation { continuation in
        legacyAPICall { result in
            continuation.resume(returning: result)
        }
    }
}


// Uncomment to run (requires async context):
// Task {
//     await runExample10()
// }
