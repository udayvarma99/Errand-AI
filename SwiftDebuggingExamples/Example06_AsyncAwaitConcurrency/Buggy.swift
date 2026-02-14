// Example 6: Async/Await and Concurrency Issues
// This code has modern Swift concurrency bugs

import Foundation

// BUG 1: Calling async from sync context
class DataFetcher {
    func fetchData() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "Data"
    }
    
    func syncMethod() {
        // 💥 Error: Cannot call async function in sync context!
        // let data = fetchData()
        
        // 🐛 WRONG: Force blocking
        let data = Task {
            await fetchData()
        }
        // Can't get value synchronously!
    }
}

// BUG 2: Not marking functions async
class APIManager {
    func loadUser() -> User {  // 🐛 Should be async
        let url = URL(string: "https://api.example.com/user")!
        // 💥 Can't use await here because function isn't async!
        // let (data, _) = try await URLSession.shared.data(from: url)
        return User(name: "Placeholder")  // Wrong!
    }
}

struct User {
    let name: String
}

// BUG 3: Data race with non-Sendable types
class NonSendableClass {
    var value: Int = 0
}

func dataRaceBug() async {
    let shared = NonSendableClass()
    
    // 🐛 Data race: shared is accessed from multiple tasks
    await withTaskGroup(of: Void.self) { group in
        for i in 0..<10 {
            group.addTask {
                shared.value += 1  // 💥 Data race!
            }
        }
    }
}

// BUG 4: Mixing old and new concurrency
class OldStyleManager {
    func fetchOldWay(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            completion("Old data")
        }
    }
    
    func fetchNewWay() async -> String {
        // 🐛 Using old completion handler in async context
        return await withCheckedContinuation { continuation in
            fetchOldWay { data in
                continuation.resume(returning: data)
                continuation.resume(returning: data)  // 💥 Double resume crashes!
            }
        }
    }
}

// BUG 5: Unstructured task not properly managed
class TaskManager {
    var tasks: [Task<Void, Never>] = []
    
    func startWork() {
        // 🐛 Task created but never cancelled
        let task = Task {
            while !Task.isCancelled {
                print("Working...")
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        tasks.append(task)
        // Task keeps running even after TaskManager is deallocated!
    }
    
    // Missing deinit to cancel tasks
}

// BUG 6: Main actor isolation violation
@MainActor
class ViewModel {
    var data: [String] = []
    
    func updateData(_ newData: [String]) {
        data = newData  // Must be on main actor
    }
}

func backgroundUpdate() async {
    let viewModel = ViewModel()
    // 💥 Error: Call to main actor-isolated method from non-isolated context
    // viewModel.updateData(["New data"])
}

// BUG 7: Async let without await
func asyncLetBug() async {
    async let data1 = fetchData1()
    async let data2 = fetchData2()
    
    // 🐛 Forgot to await before function ends!
    print("Done")  // 💥 Error: async let must be awaited
}

func fetchData1() async -> String { "Data 1" }
func fetchData2() async -> String { "Data 2" }

// BUG 8: Task detached incorrectly
actor DataStore {
    var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)
    }
    
    func processItems() {
        // 🐛 Detached task doesn't inherit actor context
        Task.detached {
            // 💥 Data race: accessing actor-isolated property!
            self.items.append("New")  // Error!
        }
    }
}

// BUG 9: Missing throws in async function
func riskyOperation() async -> String {
    // 🐛 Should be async throws
    let url = URL(string: "https://api.example.com")!
    // 💥 Can't use try await without throws
    // let (data, _) = try await URLSession.shared.data(from: url)
    return "Placeholder"
}

// BUG 10: Cancellation not checked
func longRunningTask() async -> [Int] {
    var results: [Int] = []
    
    // 🐛 Doesn't check for cancellation
    for i in 0..<1000000 {
        // Expensive operation
        results.append(i * 2)
    }
    
    return results  // Might waste time after cancellation
}

// Demonstrate the bugs:
// Note: Many of these are compile-time errors that prevent building

print("Note: Many async/await bugs are caught at compile time!")
print("The bugs shown here illustrate common mistakes.")
