/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 8: ASYNC/AWAIT DEADLOCK
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Advanced
 Topic: Modern Concurrency (Swift 5.5+)
 Common In: 50% of Swift interviews (Growing in importance)
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - BLOCKING ASYNC CODE
// ═══════════════════════════════════════════════════════════════

actor DatabaseBuggy {
    private var data: [String: String] = [:]
    
    func save(key: String, value: String) async {
        data[key] = value
    }
    
    func load(key: String) -> String? {
        return data[key]
    }
    
    // 🐛 BUG: Calling async from sync method
    func saveAndLoad(key: String, value: String) -> String? {
        // ⚠️ ERROR: Can't call async save() from non-async method
        // await save(key: key, value: value)  // Won't compile!
        return load(key: key)
    }
}


// ❌ BUGGY CODE - INCORRECT TASK CREATION
// ═══════════════════════════════════════════════════════════════

class DataManagerBuggy {
    func fetchData() async -> String {
        // 🐛 BUG: Creating unnecessary task
        return await Task {
            // Already in async context, don't need Task!
            return "Data"
        }.value
    }
    
    func processMultipleItems() async {
        let items = ["A", "B", "C"]
        
        // 🐛 BUG: Sequential processing when could be parallel
        for item in items {
            await processItem(item)  // One at a time!
        }
    }
    
    private func processItem(_ item: String) async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("Processed \(item)")
    }
}


// ❌ BUGGY CODE - MAIN ACTOR ISSUES
// ═══════════════════════════════════════════════════════════════

@MainActor
class ViewModelBuggy {
    var items: [String] = []
    
    func loadItems() async {
        // 🐛 BUG: Heavy work on main actor = UI freeze
        for i in 1...1000000 {
            items.append("Item \(i)")  // Blocking main thread!
        }
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. MIXING SYNC/ASYNC:
    - Can't call async from sync without Task
    - Creates callback hell if done wrong
    - Need to understand execution context
 
 2. SEQUENTIAL INSTEAD OF PARALLEL:
    - Using await in loop = sequential
    - Should use Task.group or async let
    - Missing parallelization opportunities
 
 3. MAIN ACTOR BLOCKING:
    - Heavy work on @MainActor freezes UI
    - Need to explicitly move to background
    - Common cause of UI hangs
 
 4. TASK MISUSE:
    - Creating Task when already async
    - Not canceling tasks
    - Not handling Task priorities
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Proper Async/Await
// ═══════════════════════════════════════════════════════════════

actor DatabaseFixed {
    private var data: [String: String] = [:]
    
    func save(key: String, value: String) async {
        data[key] = value
    }
    
    func load(key: String) -> String? {
        return data[key]
    }
    
    // ✅ Mark method as async if it needs to await
    func saveAndLoad(key: String, value: String) async -> String? {
        await save(key: key, value: value)
        return load(key: key)
    }
    
    // ✅ Batch operations
    func saveMultiple(_ items: [String: String]) async {
        for (key, value) in items {
            data[key] = value
        }
    }
}


// ✅ FIXED CODE - SOLUTION 2: Parallel Execution
// ═══════════════════════════════════════════════════════════════

class DataManagerFixed {
    func fetchData() async -> String {
        // ✅ Direct async code, no Task needed
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Data"
    }
    
    // ✅ Parallel with async let
    func fetchMultipleSources() async -> (String, String, String) {
        async let source1 = fetchFromSource1()
        async let source2 = fetchFromSource2()
        async let source3 = fetchFromSource3()
        
        // ✅ All three run in parallel
        return await (source1, source2, source3)
    }
    
    // ✅ Parallel with TaskGroup
    func processMultipleItems() async -> [String] {
        let items = ["A", "B", "C", "D", "E"]
        
        return await withTaskGroup(of: String.self) { group in
            for item in items {
                group.addTask {
                    return await self.processItem(item)
                }
            }
            
            var results: [String] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    private func processItem(_ item: String) async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Processed \(item)"
    }
    
    private func fetchFromSource1() async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Source 1"
    }
    
    private func fetchFromSource2() async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Source 2"
    }
    
    private func fetchFromSource3() async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Source 3"
    }
}


// ✅ FIXED CODE - SOLUTION 3: Main Actor Management
// ═══════════════════════════════════════════════════════════════

@MainActor
class ViewModelFixed {
    var items: [String] = []
    
    func loadItems() async {
        // ✅ Move heavy work off main actor
        let newItems = await Task.detached {
            var result: [String] = []
            for i in 1...1000 {
                result.append("Item \(i)")
            }
            return result
        }.value
        
        // ✅ Back on main actor for UI update
        items = newItems
    }
    
    // ✅ Explicitly mark background work
    nonisolated func performBackgroundWork() async -> [String] {
        // Not on main actor
        var result: [String] = []
        for i in 1...1000 {
            result.append("Item \(i)")
        }
        return result
    }
    
    func loadItemsAlternative() async {
        let newItems = await performBackgroundWork()
        items = newItems  // Back on main actor
    }
}


// ✅ ADVANCED: Task Cancellation
// ═══════════════════════════════════════════════════════════════

class ImageLoader {
    func loadImage(from url: String) async throws -> String {
        // ✅ Check for cancellation
        try Task.checkCancellation()
        
        // Simulate network request
        for i in 1...10 {
            try await Task.sleep(nanoseconds: 100_000_000)
            
            // ✅ Check cancellation periodically
            if Task.isCancelled {
                print("Task cancelled at step \(i)")
                throw CancellationError()
            }
        }
        
        return "Image from \(url)"
    }
    
    func loadMultipleImages(urls: [String]) async -> [String] {
        await withTaskGroup(of: String?.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.loadImage(from: url)
                }
            }
            
            var images: [String] = []
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
}


// ✅ ADVANCED: Async Sequences
// ═══════════════════════════════════════════════════════════════

class DataStream {
    func fetchDataStream() async -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                for i in 1...10 {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    continuation.yield(i)
                }
                continuation.finish()
            }
        }
    }
    
    func processStream() async {
        let stream = await fetchDataStream()
        
        for await value in stream {
            print("Received: \(value)")
            
            // Can break early
            if value == 5 {
                break
            }
        }
    }
}


// ✅ REAL-WORLD EXAMPLE: Network Layer
// ═══════════════════════════════════════════════════════════════

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

actor NetworkManager {
    private var cache: [String: Data] = [:]
    
    func fetchData(from url: String) async throws -> Data {
        // Check cache first
        if let cached = cache[url] {
            return cached
        }
        
        // Simulate network request
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Check if cancelled
        try Task.checkCancellation()
        
        let data = "Data from \(url)".data(using: .utf8)!
        cache[url] = data
        
        return data
    }
    
    func fetchMultiple(urls: [String]) async throws -> [Data] {
        // ✅ Parallel fetching with error handling
        try await withThrowingTaskGroup(of: Data.self) { group in
            for url in urls {
                group.addTask {
                    try await self.fetchData(from: url)
                }
            }
            
            var results: [Data] = []
            for try await data in group {
                results.append(data)
            }
            return results
        }
    }
    
    func clearCache() {
        cache.removeAll()
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. ASYNC/AWAIT BASICS:
    - async functions must be called with await
    - await = suspension point (not blocking!)
    - Can only await in async context
 
 2. PARALLELIZATION:
    - async let: For fixed number of parallel tasks
    - TaskGroup: For dynamic number of tasks
    - Don't use await in loop unless intentionally sequential
 
 3. MAIN ACTOR:
    - @MainActor = runs on main thread
    - Use for UI updates
    - Move heavy work off main actor with Task.detached
    - nonisolated to opt out of actor
 
 4. TASK MANAGEMENT:
    - Task.detached: Unstructured, separate priority
    - Task { }: Inherits priority and context
    - Cancel with task.cancel()
    - Check cancellation with Task.checkCancellation()
 
 5. ACTORS:
    - Automatically serialize access
    - Async methods for cross-actor calls
    - Sync methods for same-actor calls
    - Prevent data races at compile time
 
 6. BEST PRACTICES:
    - Prefer structured concurrency
    - Handle cancellation
    - Don't block main actor
    - Use async sequences for streams
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "I see we're awaiting in a loop, which processes items sequentially. 
    I'd use a TaskGroup to parallelize this."
 
 2. "This heavy work is on @MainActor which will freeze the UI. I'd move it 
    to a background context with Task.detached or nonisolated."
 
 3. "For multiple independent async operations, async-let is cleaner than 
    creating separate tasks."
 
 4. "I'd add cancellation checking for long-running operations so they can 
    be interrupted when no longer needed."
 
 5. "Actors provide compile-time safety for data races, which is better than 
    runtime locks. async/await integrates naturally with actors."
 
 BONUS POINTS:
 ✅ Explain structured vs unstructured concurrency
 ✅ Discuss Task priorities (.high, .medium, .low, .background)
 ✅ Mention AsyncSequence for streaming data
 ✅ Know about @Sendable for thread-safe types
 ✅ Understand suspension points
 
 RED FLAGS:
 ❌ "I'll just use DispatchQueue everywhere"
 ❌ Not understanding async/await vs callbacks
 ❌ Blocking main actor with heavy work
 ❌ Creating unnecessary Task wrappers
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What's the difference between Task and Task.detached?"
 A: "Task inherits priority and actor context from the caller. Task.detached 
     creates a completely independent task with its own priority."
 
 Q: "When should you use async/await vs callbacks?"
 A: "Always prefer async/await for new code - it's more readable, handles 
     errors better, and integrates with Swift's concurrency model. Use 
     callbacks only for Objective-C compatibility."
 
 Q: "What's @Sendable?"
 A: "A type that's safe to pass across concurrency boundaries. Value types 
     and actors are implicitly Sendable. Classes need to be marked Sendable 
     and be thread-safe."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample8() async {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 8: ASYNC/AWAIT")
    print("═══════════════════════════════════════════════════════\n")
    
    print("✅ BASIC ASYNC/AWAIT:")
    let db = DatabaseFixed()
    await db.save(key: "name", value: "Alice")
    if let result = await db.saveAndLoad(key: "age", value: "30") {
        print("Saved and loaded: \(result)")
    }
    print()
    
    print("✅ PARALLEL EXECUTION (async let):")
    let manager = DataManagerFixed()
    let sources = await manager.fetchMultipleSources()
    print("Fetched: \(sources)")
    print()
    
    print("✅ PARALLEL EXECUTION (TaskGroup):")
    let results = await manager.processMultipleItems()
    print("Results: \(results)")
    print()
    
    print("✅ MAIN ACTOR:")
    let viewModel = ViewModelFixed()
    await viewModel.loadItems()
    print("Loaded \(viewModel.items.count) items")
    print()
    
    print("✅ TASK CANCELLATION:")
    let loader = ImageLoader()
    let task = Task {
        try? await loader.loadImage(from: "https://example.com/image.jpg")
    }
    
    // Cancel after short delay
    Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        task.cancel()
    }
    
    await task.value
    print()
    
    print("✅ NETWORK LAYER:")
    let network = NetworkManager()
    let urls = ["url1", "url2", "url3"]
    if let data = try? await network.fetchMultiple(urls: urls) {
        print("Fetched \(data.count) items")
    }
    print()
}

// Uncomment to run (must be called from async context):
// Task { await runExample8() }
