// Example 4: Thread Safety - FIXED VERSION
// Proper synchronization prevents race conditions

import Foundation

// FIX 1: Use serial queue for synchronization
class BankAccount {
    private var balance: Double = 1000.0
    private let queue = DispatchQueue(label: "com.bank.account")
    
    func withdraw(amount: Double) {
        queue.sync {  // ✅ Synchronizes access
            if balance >= amount {
                Thread.sleep(forTimeInterval: 0.001)
                balance -= amount
                print("Withdrew \(amount), balance: \(balance)")
            }
        }
    }
    
    func getBalance() -> Double {
        return queue.sync {  // ✅ Thread-safe read
            return balance
        }
    }
}

// Alternative: Use NSLock
class BankAccountWithLock {
    private var balance: Double = 1000.0
    private let lock = NSLock()
    
    func withdraw(amount: Double) {
        lock.lock()  // ✅ Acquire lock
        defer { lock.unlock() }  // ✅ Always release
        
        if balance >= amount {
            Thread.sleep(forTimeInterval: 0.001)
            balance -= amount
            print("Withdrew \(amount), balance: \(balance)")
        }
    }
}

// FIX 2: Thread-safe array using barrier
class DataStore {
    private var items: [String] = []
    private let queue = DispatchQueue(label: "com.datastore", attributes: .concurrent)
    
    func addItem(_ item: String) {
        queue.async(flags: .barrier) {  // ✅ Exclusive write access
            self.items.append(item)
        }
    }
    
    func getAllItems() -> [String] {
        return queue.sync {  // ✅ Concurrent reads
            return self.items
        }
    }
    
    func getCount() -> Int {
        return queue.sync {
            return self.items.count
        }
    }
}

// Alternative: Use actor (Swift 5.5+)
actor DataStoreActor {
    private var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)  // ✅ Actor ensures thread safety
    }
    
    func getAllItems() -> [String] {
        return items
    }
    
    func getCount() -> Int {
        return items.count
    }
}

// FIX 3: Update UI on main thread
class ImageDownloader {
    var imageView: UIImageView?
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                // ✅ Update UI on main thread
                DispatchQueue.main.async {
                    self.imageView?.image = image
                }
            }
        }.resume()
    }
    
    // Modern approach with async/await
    func downloadImageAsync(from url: URL) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        let image = UIImage(data: data)
        
        // ✅ Update UI on main actor
        await MainActor.run {
            self.imageView?.image = image
        }
    }
}

// Placeholder UIKit classes
class UIImageView {
    var image: UIImage?
}

class UIImage {
    init?(data: Data) { }
}

// FIX 4: Thread-safe cache
class Cache {
    private var storage: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.cache", attributes: .concurrent)
    
    func set(_ value: Any, for key: String) {
        queue.async(flags: .barrier) {  // ✅ Exclusive write
            self.storage[key] = value
        }
    }
    
    func get(_ key: String) -> Any? {
        return queue.sync {  // ✅ Concurrent read
            return self.storage[key]
        }
    }
}

// Alternative: Thread-safe cache with NSCache
class CacheWithNSCache {
    private let cache = NSCache<NSString, AnyObject>()
    
    func set(_ value: AnyObject, for key: String) {
        cache.setObject(value, forKey: key as NSString)  // ✅ NSCache is thread-safe
    }
    
    func get(_ key: String) -> AnyObject? {
        return cache.object(forKey: key as NSString)
    }
}

// FIX 5: Thread-safe singleton
class ExpensiveResource {
    static let shared = ExpensiveResource()  // ✅ Guaranteed thread-safe in Swift
    
    private init() {
        print("ExpensiveResource created")
    }
}

// Alternative: Lazy thread-safe initialization
class ExpensiveResourceLazy {
    private static var _shared: ExpensiveResourceLazy?
    private static let lock = NSLock()
    
    static var shared: ExpensiveResourceLazy {
        lock.lock()
        defer { lock.unlock() }
        
        if _shared == nil {
            _shared = ExpensiveResourceLazy()
        }
        return _shared!
    }
    
    private init() {
        print("ExpensiveResourceLazy created")
    }
}

// FIX 6: Thread-safe task queue
class TaskQueue {
    private var tasks: [() -> Void] = []
    private let queue = DispatchQueue(label: "com.taskqueue", attributes: .concurrent)
    
    func addTask(_ task: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            self.tasks.append(task)
        }
    }
    
    func executeTasks() {
        let tasksCopy = queue.sync {
            return self.tasks  // ✅ Get thread-safe copy
        }
        
        for task in tasksCopy {
            task()
        }
    }
}

// FIX 7: Atomic counter using OSAtomic
import os.lock

class Counter {
    private var _count: Int = 0
    private let lock = OSAllocatedUnfairLock()
    
    func increment() {
        lock.lock()
        _count += 1
        lock.unlock()
    }
    
    func getCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return _count
    }
}

// Alternative: Actor-based counter
actor CounterActor {
    private var count = 0
    
    func increment() {
        count += 1  // ✅ Thread-safe by actor
    }
    
    func getCount() -> Int {
        return count
    }
}

// BONUS: Modern Swift Concurrency patterns

// Safe global state with actor
actor GlobalState {
    static let shared = GlobalState()
    
    private var data: [String: Any] = [:]
    
    func setValue(_ value: Any, for key: String) {
        data[key] = value
    }
    
    func getValue(for key: String) -> Any? {
        return data[key]
    }
}

// Thread-safe operation queue
class OperationManager {
    private let operationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 1  // Serial execution
    }
    
    func addOperation(_ block: @escaping () -> Void) {
        operationQueue.addOperation(block)
    }
}

// Demonstrate the fixes:
func demonstrateThreadSafety() {
    print("=== Fix 1: Thread-Safe Bank Account ===")
    let account = BankAccount()
    
    DispatchQueue.concurrentPerform(iterations: 10) { _ in
        account.withdraw(amount: 200)
    }
    print("Final balance: \(account.getBalance())")  // ✅ Correct: -1000
    
    print("\n=== Fix 2: Thread-Safe Array ===")
    let store = DataStore()
    
    DispatchQueue.concurrentPerform(iterations: 100) { i in
        store.addItem("Item \(i)")
    }
    
    Thread.sleep(forTimeInterval: 1)  // Wait for async operations
    print("Items count: \(store.getCount())")  // ✅ Correct: 100
    
    print("\n=== Fix 4: Thread-Safe Cache ===")
    let cache = Cache()
    
    DispatchQueue.concurrentPerform(iterations: 100) { i in
        cache.set("Value \(i)", for: "key\(i)")
        _ = cache.get("key\(i)")
    }
    
    Thread.sleep(forTimeInterval: 1)
    print("Cache operations completed safely!")  // ✅ No crash
    
    print("\n=== Fix 5: Thread-Safe Singleton ===")
    DispatchQueue.concurrentPerform(iterations: 5) { _ in
        _ = ExpensiveResource.shared
    }
    // ✅ "ExpensiveResource created" printed only once!
    
    print("\n=== Fix 7: Thread-Safe Counter ===")
    let counter = Counter()
    
    DispatchQueue.concurrentPerform(iterations: 1000) { _ in
        counter.increment()
    }
    
    Thread.sleep(forTimeInterval: 1)
    print("Count: \(counter.getCount())")  // ✅ Correct: 1000
    
    print("\n✅ All threading issues fixed!")
}

// Async example with actor
func demonstrateActor() async {
    print("\n=== Using Actors ===")
    let actorStore = DataStoreActor()
    
    await withTaskGroup(of: Void.self) { group in
        for i in 0..<100 {
            group.addTask {
                await actorStore.addItem("Item \(i)")
            }
        }
    }
    
    let count = await actorStore.getCount()
    print("Actor store count: \(count)")  // ✅ Correct: 100
}

demonstrateThreadSafety()

// For async/await version:
Task {
    await demonstrateActor()
}

Thread.sleep(forTimeInterval: 3)
print("All demonstrations complete!")
