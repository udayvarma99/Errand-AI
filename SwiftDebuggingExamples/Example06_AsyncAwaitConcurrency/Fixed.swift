// Example 6: Async/Await and Concurrency - FIXED VERSION
// Proper async/await usage for safe concurrency

import Foundation

// FIX 1: Proper async/sync bridging
class DataFetcher {
    func fetchData() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "Data"
    }
    
    func syncMethod() {
        // ✅ Create task and handle async properly
        Task {
            let data = await fetchData()
            print("Data: \(data)")
        }
    }
    
    // Alternative: Make method async
    func asyncMethod() async {
        let data = await fetchData()
        print("Data: \(data)")
    }
}

// FIX 2: Mark function as async throws
class APIManager {
    func loadUser() async throws -> User {
        let url = URL(string: "https://api.example.com/user")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: data)
    }
}

struct User: Codable {
    let name: String
}

// FIX 3: Use actor for thread-safe state
actor SafeCounter {
    var value: Int = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

func noDataRace() async {
    let counter = SafeCounter()
    
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<10 {
            group.addTask {
                await counter.increment()  // ✅ Thread-safe
            }
        }
    }
    
    let finalValue = await counter.getValue()
    print("Final value: \(finalValue)")  // ✅ Always 10
}

// Alternative: Use Sendable types
struct SendableData: Sendable {
    let value: Int
}

func useSendable() async {
    let data = SendableData(value: 42)
    
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<10 {
            group.addTask {
                print(data.value)  // ✅ Safe, data is Sendable
            }
        }
    }
}

// FIX 4: Proper continuation usage
class OldStyleManager {
    func fetchOldWay(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            completion("Old data")
        }
    }
    
    func fetchNewWay() async -> String {
        return await withCheckedContinuation { continuation in
            fetchOldWay { data in
                continuation.resume(returning: data)  // ✅ Resume once only
            }
        }
    }
    
    // With error handling
    func fetchWithError() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            fetchOldWay { data in
                if data.isEmpty {
                    continuation.resume(throwing: FetchError.noData)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
}

enum FetchError: Error {
    case noData
}

// FIX 5: Properly manage task lifecycle
class TaskManager {
    private var tasks: [Task<Void, Never>] = []
    
    func startWork() {
        let task = Task {
            while !Task.isCancelled {
                print("Working...")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        tasks.append(task)
    }
    
    func stopWork() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    deinit {
        stopWork()  // ✅ Clean up tasks
    }
}

// FIX 6: Respect MainActor isolation
@MainActor
class ViewModel {
    var data: [String] = []
    
    func updateData(_ newData: [String]) {
        data = newData
    }
}

func backgroundUpdate() async {
    let viewModel = await ViewModel()
    
    // ✅ Call from MainActor context
    await MainActor.run {
        viewModel.updateData(["New data"])
    }
    
    // ✅ Alternative: Method is isolated to MainActor
    await viewModel.updateData(["New data"])
}

// FIX 7: Always await async let
func asyncLetFixed() async {
    async let data1 = fetchData1()
    async let data2 = fetchData2()
    
    let results = await [data1, data2]  // ✅ Await both
    print("Results: \(results)")
}

func fetchData1() async -> String {
    try? await Task.sleep(nanoseconds: 500_000_000)
    return "Data 1"
}

func fetchData2() async -> String {
    try? await Task.sleep(nanoseconds: 500_000_000)
    return "Data 2"
}

// FIX 8: Use Task not Task.detached in actors
actor DataStore {
    var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)
    }
    
    func processItems() {
        // ✅ Use Task to inherit actor context
        Task {
            await addItem("New")  // ✅ Properly isolated
        }
    }
    
    // Use detached only when truly independent
    func independentTask() {
        Task.detached {
            // ✅ Doesn't access actor state
            print("Independent work")
        }
    }
}

// FIX 9: Add throws when needed
func riskyOperation() async throws -> String {
    let url = URL(string: "https://api.example.com")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(data: data, encoding: .utf8) ?? ""
}

// FIX 10: Check for cancellation
func longRunningTask() async -> [Int] {
    var results: [Int] = []
    
    for i in 0..<1000000 {
        // ✅ Check cancellation periodically
        if Task.isCancelled {
            print("Task cancelled at \(i)")
            return results
        }
        
        results.append(i * 2)
        
        // ✅ Cooperative cancellation point
        if i % 10000 == 0 {
            await Task.yield()  // Let other tasks run
        }
    }
    
    return results
}

// Alternative: Using throwing cancellation
func longRunningTaskThrows() async throws -> [Int] {
    var results: [Int] = []
    
    for i in 0..<1000000 {
        try Task.checkCancellation()  // ✅ Throws if cancelled
        results.append(i * 2)
    }
    
    return results
}

// BONUS: Advanced patterns

// Pattern 1: Timeout for async operations
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError.timeout
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

enum TimeoutError: Error {
    case timeout
}

// Pattern 2: Retry with exponential backoff
func retry<T>(
    maxAttempts: Int = 3,
    delay: TimeInterval = 1.0,
    operation: () async throws -> T
) async throws -> T {
    var currentDelay = delay
    
    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            if attempt == maxAttempts {
                throw error
            }
            
            print("Attempt \(attempt) failed, retrying...")
            try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
            currentDelay *= 2  // Exponential backoff
        }
    }
    
    fatalError("Should never reach here")
}

// Demonstrate the fixes:
Task {
    print("=== Async/Await Fixed Examples ===\n")
    
    // Fix 3: Thread-safe counter
    await noDataRace()
    
    // Fix 7: Proper async let usage
    await asyncLetFixed()
    
    // Fix 10: Cancellable task
    let task = Task {
        return await longRunningTask()
    }
    
    // Cancel after short delay
    try? await Task.sleep(nanoseconds: 100_000_000)
    task.cancel()
    let result = await task.value
    print("Task result count: \(result.count)")
    
    print("\n✅ All async/await patterns working correctly!")
}

// Keep program running for async tasks
try? await Task.sleep(nanoseconds: 3_000_000_000)
