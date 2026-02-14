// Example 2: Memory Leaks - FIXED VERSION
// Proper memory management prevents retain cycles

import Foundation

// FIX 1: Break cycle with weak reference
class Person {
    let name: String
    var apartment: Apartment?
    
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    
    deinit {
        print("\(name) is being deinitialized")  // ✅ Now called!
    }
}

class Apartment {
    let unit: String
    weak var tenant: Person?  // ✅ Use weak to break cycle
    
    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("Apartment \(unit) is being deinitialized")  // ✅ Now called!
    }
}

// FIX 2: Use weak self in closure
class NetworkManager {
    var url: String
    var completionHandler: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized")
    }
    
    func fetchData() {
        // ✅ Use [weak self] capture list
        completionHandler = { [weak self] in
            guard let self = self else { return }
            print("Data fetched from \(self.url)")
            self.processData()
        }
    }
    
    // Alternative: Use unowned when self will definitely exist
    func fetchDataUnowned() {
        completionHandler = { [unowned self] in
            print("Data fetched from \(self.url)")
            self.processData()
        }
    }
    
    func processData() {
        print("Processing data...")
    }
    
    deinit {
        print("NetworkManager deinitialized")  // ✅ Now called!
    }
}

// FIX 3: Weak self in lazy closure
class ImageLoader {
    var imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    
    // ✅ Use weak self in lazy closure
    lazy var loadImage: () -> Void = { [weak self] in
        guard let self = self else { return }
        print("Loading image: \(self.imageName)")
    }
    
    deinit {
        print("ImageLoader deinitialized")  // ✅ Now called!
    }
}

// FIX 4: Weak delegate
protocol DataSourceDelegate: AnyObject {  // ✅ Must be class-only protocol
    func dataDidUpdate()
}

class DataSource {
    weak var delegate: DataSourceDelegate?  // ✅ Weak reference
    
    func updateData() {
        delegate?.dataDidUpdate()
    }
    
    deinit {
        print("DataSource deinitialized")  // ✅ Now called!
    }
}

class ViewController: DataSourceDelegate {
    var dataSource: DataSource?
    
    init() {
        print("ViewController initialized")
        dataSource = DataSource()
        dataSource?.delegate = self
    }
    
    func dataDidUpdate() {
        print("Data updated")
    }
    
    deinit {
        print("ViewController deinitialized")  // ✅ Now called!
    }
}

// FIX 5: Weak self in GCD
class TaskManager {
    var taskName: String
    
    init(taskName: String) {
        self.taskName = taskName
    }
    
    func scheduleTask() {
        // ✅ Use [weak self] in async closure
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else {
                print("TaskManager was deallocated before task executed")
                return
            }
            print("Executing task: \(self.taskName)")
            self.completeTask()
        }
    }
    
    deinit {
        print("TaskManager deinitialized")  // ✅ Now called immediately!
    }
}

// BONUS: Advanced patterns for memory management

// Pattern 1: Using unowned when relationship is required
class Customer {
    let name: String
    var card: CreditCard?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer  // ✅ Credit card can't exist without customer
    
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    
    deinit {
        print("Card #\(number) is being deinitialized")
    }
}

// Pattern 2: Closure capture list with multiple values
class DataProcessor {
    var data: [String] = []
    var processingQueue = DispatchQueue(label: "processing")
    
    func processAsync() {
        let dataSnapshot = data  // Capture value, not reference
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            // Use dataSnapshot instead of self.data
            print("Processing \(dataSnapshot.count) items")
            self.complete()
        }
    }
    
    func complete() {
        print("Processing complete")
    }
    
    deinit {
        print("DataProcessor deinitialized")
    }
}

// Example usage - no leaks!
func demonstrateFixed() {
    print("=== Test 1: Person-Apartment ===")
    var john: Person? = Person(name: "John")
    var unit4A: Apartment? = Apartment(unit: "4A")
    
    john?.apartment = unit4A
    unit4A?.tenant = john
    
    john = nil
    unit4A = nil
    // ✅ Both deallocated properly!
    
    print("\n=== Test 2: Closure ===")
    var manager: NetworkManager? = NetworkManager(url: "https://api.example.com")
    manager?.fetchData()
    manager = nil
    // ✅ NetworkManager deallocated!
    
    print("\n=== Test 3: Lazy Closure ===")
    var loader: ImageLoader? = ImageLoader(imageName: "photo.jpg")
    loader?.loadImage()
    loader = nil
    // ✅ ImageLoader deallocated!
    
    print("\n=== Test 4: Delegate ===")
    var viewController: ViewController? = ViewController()
    viewController = nil
    // ✅ Both deallocated!
    
    print("\n=== Test 5: GCD ===")
    var taskManager: TaskManager? = TaskManager(taskName: "Download")
    taskManager?.scheduleTask()
    taskManager = nil
    // ✅ TaskManager deallocated immediately!
    
    print("\n=== Test 6: Customer-CreditCard ===")
    var customer: Customer? = Customer(name: "Alice")
    customer?.card = CreditCard(number: 1234_5678_9012_3456, customer: customer!)
    customer = nil
    // ✅ Both deallocated!
}

// Test the fixes
demonstrateFixed()
print("\nFunction completed - all objects properly deallocated!")

Thread.sleep(forTimeInterval: 3)
print("Task closure executed, no memory leaks!")
