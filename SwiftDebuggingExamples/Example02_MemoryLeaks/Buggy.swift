// Example 2: Memory Leaks with Retain Cycles
// This code creates strong reference cycles that prevent deallocation

import Foundation

// BUG 1: Classic retain cycle between two classes
class Person {
    let name: String
    var apartment: Apartment?
    
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    
    deinit {
        print("\(name) is being deinitialized")  // 💥 Never called due to leak!
    }
}

class Apartment {
    let unit: String
    var tenant: Person?  // 🐛 Strong reference creates cycle
    
    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is being initialized")
    }
    
    deinit {
        print("Apartment \(unit) is being deinitialized")  // 💥 Never called!
    }
}

// BUG 2: Retain cycle in closure
class NetworkManager {
    var url: String
    var completionHandler: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized")
    }
    
    func fetchData() {
        // 🐛 Closure captures self strongly, creating a cycle
        completionHandler = {
            print("Data fetched from \(self.url)")  // Strong reference to self
            self.processData()
        }
    }
    
    func processData() {
        print("Processing data...")
    }
    
    deinit {
        print("NetworkManager deinitialized")  // 💥 Never called!
    }
}

// BUG 3: Retain cycle in lazy closure
class ImageLoader {
    var imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
    }
    
    // 🐛 Lazy var with closure capturing self
    lazy var loadImage: () -> Void = {
        print("Loading image: \(self.imageName)")  // Creates retain cycle
    }
    
    deinit {
        print("ImageLoader deinitialized")  // 💥 Never called!
    }
}

// BUG 4: Retain cycle with delegate pattern
protocol DataSourceDelegate {
    func dataDidUpdate()
}

class DataSource {
    var delegate: DataSourceDelegate?  // 🐛 Should be weak
    
    func updateData() {
        delegate?.dataDidUpdate()
    }
    
    deinit {
        print("DataSource deinitialized")  // 💥 Never called!
    }
}

class ViewController: DataSourceDelegate {
    var dataSource: DataSource?
    
    init() {
        print("ViewController initialized")
        dataSource = DataSource()
        dataSource?.delegate = self  // Creates retain cycle
    }
    
    func dataDidUpdate() {
        print("Data updated")
    }
    
    deinit {
        print("ViewController deinitialized")  // 💥 Never called!
    }
}

// BUG 5: Retain cycle in GCD async
class TaskManager {
    var taskName: String
    
    init(taskName: String) {
        self.taskName = taskName
    }
    
    func scheduleTask() {
        // 🐛 Dispatch queue captures self strongly
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Executing task: \(self.taskName)")  // Strong reference
            self.completeTask()
        }
    }
    
    func completeTask() {
        print("Task completed")
    }
    
    deinit {
        print("TaskManager deinitialized")  // 💥 Might not be called immediately
    }
}

// Example usage that creates leaks:
func demonstrateLeaks() {
    // Leak 1: Person-Apartment cycle
    var john: Person? = Person(name: "John")
    var unit4A: Apartment? = Apartment(unit: "4A")
    
    john?.apartment = unit4A
    unit4A?.tenant = john
    
    john = nil
    unit4A = nil
    // 💥 Neither object is deallocated!
    
    // Leak 2: Closure cycle
    var manager: NetworkManager? = NetworkManager(url: "https://api.example.com")
    manager?.fetchData()
    manager = nil
    // 💥 NetworkManager is not deallocated!
    
    // Leak 3: Lazy closure cycle
    var loader: ImageLoader? = ImageLoader(imageName: "photo.jpg")
    loader?.loadImage()
    loader = nil
    // 💥 ImageLoader is not deallocated!
    
    // Leak 4: Delegate cycle
    var viewController: ViewController? = ViewController()
    viewController = nil
    // 💥 Neither ViewController nor DataSource is deallocated!
    
    // Leak 5: GCD cycle
    var taskManager: TaskManager? = TaskManager(taskName: "Download")
    taskManager?.scheduleTask()
    taskManager = nil
    // 💥 TaskManager persists until closure executes!
}

// Test the leaks
demonstrateLeaks()
print("Function completed - objects should be deallocated but aren't!")

// Wait to see if deinit is called
Thread.sleep(forTimeInterval: 3)
print("Still no deallocation!")
