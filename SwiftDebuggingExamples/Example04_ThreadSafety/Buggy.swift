// Example 4: Thread Safety and Race Conditions
// This code has various threading bugs that cause crashes or data corruption

import Foundation

// BUG 1: Shared mutable state without synchronization
class BankAccount {
    var balance: Double = 1000.0
    
    func withdraw(amount: Double) {
        // 🐛 Race condition: Multiple threads can access balance simultaneously
        if balance >= amount {
            // Context switch can happen here!
            Thread.sleep(forTimeInterval: 0.001)  // Simulates processing time
            balance -= amount
            print("Withdrew \(amount), balance: \(balance)")
        }
    }
}

// BUG 2: Non-thread-safe array operations
class DataStore {
    var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)  // 💥 Crash if multiple threads call this!
    }
    
    func getAllItems() -> [String] {
        return items  // 🐛 Can return inconsistent state
    }
}

// BUG 3: UI updates on background thread
class ImageDownloader {
    var imageView: UIImageView?
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                // 💥 UIKit crash: UI updates must be on main thread!
                self.imageView?.image = image
            }
        }.resume()
    }
}

// Placeholder UIKit classes for demonstration
class UIImageView {
    var image: UIImage?
}

class UIImage {
    init?(data: Data) { }
}

// BUG 4: Shared dictionary without synchronization
class Cache {
    var storage: [String: Any] = [:]
    
    func set(_ value: Any, for key: String) {
        storage[key] = value  // 💥 Crash with concurrent access
    }
    
    func get(_ key: String) -> Any? {
        return storage[key]  // 🐛 Can crash or return wrong data
    }
}

// BUG 5: Race condition in lazy initialization
class ExpensiveResource {
    static var shared: ExpensiveResource?
    
    static func getInstance() -> ExpensiveResource {
        if shared == nil {
            // 🐛 Multiple threads can create multiple instances!
            Thread.sleep(forTimeInterval: 0.01)
            shared = ExpensiveResource()
        }
        return shared!
    }
    
    init() {
        print("ExpensiveResource created")
    }
}

// BUG 6: Modifying collection during enumeration from different thread
class TaskQueue {
    var tasks: [() -> Void] = []
    
    func addTask(_ task: @escaping () -> Void) {
        tasks.append(task)
    }
    
    func executeTasks() {
        // 🐛 Tasks array might be modified by another thread during iteration
        for task in tasks {
            task()
        }
    }
}

// BUG 7: Race condition in counter
class Counter {
    var count = 0
    
    func increment() {
        // 🐛 Read-modify-write is not atomic!
        count += 1
    }
    
    func getCount() -> Int {
        return count  // 🐛 Can return inconsistent value
    }
}

// Demonstrate the bugs:
func demonstrateThreadingBugs() {
    print("=== Bug 1: Bank Account Race Condition ===")
    let account = BankAccount()
    
    // Multiple threads withdrawing simultaneously
    DispatchQueue.concurrentPerform(iterations: 10) { _ in
        account.withdraw(amount: 200)
    }
    print("Final balance: \(account.balance)")  // 🐛 Should be -1000, might be different!
    
    print("\n=== Bug 2: Array Race Condition ===")
    let store = DataStore()
    
    // Multiple threads adding items
    DispatchQueue.concurrentPerform(iterations: 100) { i in
        store.addItem("Item \(i)")  // 💥 Can crash!
    }
    print("Items count: \(store.items.count)")  // 🐛 Might be less than 100!
    
    print("\n=== Bug 4: Dictionary Race Condition ===")
    let cache = Cache()
    
    // Multiple threads accessing cache
    DispatchQueue.concurrentPerform(iterations: 100) { i in
        cache.set("Value \(i)", for: "key\(i)")
        _ = cache.get("key\(i)")
    }
    print("Cache size: \(cache.storage.count)")  // 🐛 Might crash or show wrong count!
    
    print("\n=== Bug 5: Lazy Initialization Race ===")
    ExpensiveResource.shared = nil
    
    // Multiple threads getting instance
    DispatchQueue.concurrentPerform(iterations: 5) { _ in
        _ = ExpensiveResource.getInstance()
    }
    // 🐛 "ExpensiveResource created" printed multiple times!
    
    print("\n=== Bug 7: Counter Race Condition ===")
    let counter = Counter()
    
    // Multiple threads incrementing
    DispatchQueue.concurrentPerform(iterations: 1000) { _ in
        counter.increment()
    }
    print("Count: \(counter.getCount())")  // 🐛 Should be 1000, likely less!
    
    Thread.sleep(forTimeInterval: 2)
    print("\nAll threading bugs demonstrated!")
}

demonstrateThreadingBugs()
