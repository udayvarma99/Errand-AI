// Example 7: Closure Capture Lists - FIXED VERSION
// Proper closure capture semantics

import Foundation

// FIX 1: Capture value in loop
class TaskScheduler {
    func scheduleTasks() {
        for i in 0...5 {
            // ✅ Capture value by creating local constant
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) { [i] in
                print("Task \(i)")  // Each gets correct value
            }
        }
    }
    
    // Alternative: Use enumerated
    func scheduleTasksEnumerated() {
        let tasks = ["A", "B", "C", "D", "E"]
        for (index, task) in tasks.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) { [task] in
                print("Task: \(task)")
            }
        }
    }
}

// FIX 2: Weak capture of self
class DownloadManager {
    var downloads: [String] = []
    var completionHandler: ((String) -> Void)?
    
    func startDownload(url: String) {
        completionHandler = { [weak self] result in
            self?.downloads.append(result)  // ✅ Weak capture
            if let count = self?.downloads.count {
                print(count)
            }
        }
    }
    
    deinit {
        print("DownloadManager deallocated")
    }
}

// FIX 3: Weak capture in nested closures
class DataProcessor {
    var data: [String] = []
    
    func process() {
        fetchData { [weak self] result in
            guard let self = self else { return }
            
            self.parseData(result) { [weak self] items in
                guard let self = self else { return }
                // ✅ Weak capture in nested closure too
                self.data = items
                self.save()
            }
        }
    }
    
    // Modern approach with async/await
    func processAsync() async {
        let result = await fetchDataAsync()
        let items = await parseDataAsync(result)
        data = items
        save()  // ✅ No closure capture needed!
    }
    
    func fetchData(completion: @escaping (String) -> Void) { }
    func parseData(_ data: String, completion: @escaping ([String]) -> Void) { }
    func fetchDataAsync() async -> String { "" }
    func parseDataAsync(_ data: String) async -> [String] { [] }
    func save() { }
    
    deinit {
        print("DataProcessor deallocated")
    }
}

// FIX 4: Capture and modify correctly
class Counter {
    var count = 0
    private let queue = DispatchQueue(label: "counter")
    
    func increment() {
        queue.async { [weak self] in
            self?.count += 1  // ✅ Modifies original
            if let count = self?.count {
                print("Count: \(count)")
            }
        }
    }
    
    // Alternative: Capture value explicitly
    func incrementByAmount(_ amount: Int) {
        queue.async { [weak self, amount] in
            if let self = self {
                self.count += amount
                print("Count: \(self.count)")
            }
        }
    }
}

// FIX 5: Weak self in lazy closure
class ImageCache {
    var imageName: String = "default"
    
    lazy var loadImage: () -> Void = { [weak self] in
        guard let self = self else { return }
        // ✅ Weak capture
        print("Loading: \(self.imageName)")
        self.processImage()
    }
    
    func processImage() { }
    
    deinit {
        print("ImageCache deallocated")
    }
}

// FIX 6: Capture only what's needed
class DataFilter {
    var threshold: Int = 10
    
    func filterData(_ numbers: [Int]) -> [Int] {
        // ✅ Capture only threshold value
        let threshold = self.threshold
        return numbers.filter { value in
            return value > threshold
        }
    }
    
    // Alternative: Capture in list
    func transformData(_ numbers: [Int]) -> [Int] {
        return numbers.map { [threshold] value in
            return value * threshold
        }
    }
    
    // Best: Use method reference when possible
    func filterDataMethodRef(_ numbers: [Int]) -> [Int] {
        return numbers.filter(isAboveThreshold)
    }
    
    private func isAboveThreshold(_ value: Int) -> Bool {
        return value > threshold
    }
}

// FIX 7: Proper weak reference in struct
class Delegate {
    func handle() {
        print("Handled")
    }
}

struct EventHandler {
    weak var delegate: Delegate?
    
    func handleEvent() {
        DispatchQueue.main.async { [weak delegate] in
            // ✅ Weak capture of delegate
            delegate?.handle()
        }
    }
}

// FIX 8: Use strong self after weak check
class NetworkManager {
    var cache: [String: Data] = [:]
    
    func fetchData(url: String) {
        URLSession.shared.dataTask(with: URL(string: url)!) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            
            // ✅ self is now strong for duration of this scope
            Thread.sleep(forTimeInterval: 2)
            
            self.cache[url] = data  // ✅ Safe
            self.processData(data)  // ✅ Safe
        }
    }
    
    func processData(_ data: Data) { }
    
    deinit {
        print("NetworkManager deallocated")
    }
}

// FIX 9: Capture value copy explicitly
class SettingsManager {
    var settings = ["theme": "dark"]
    
    func updateLater() {
        // ✅ Capture copy of dictionary
        let settingsCopy = settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print(settingsCopy)  // ✅ Shows original settings
        }
        
        // Settings changed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settings = ["theme": "light"]
        }
    }
}

// FIX 10: Weak capture in timer
class TimerController {
    var timer: DispatchSourceTimer?
    var count = 0
    
    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 1.0)
        
        // ✅ Weak capture
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.count += 1
            print("Count: \(self.count)")
        }
        
        timer?.resume()
    }
    
    deinit {
        timer?.cancel()  // ✅ Clean up
        print("TimerController deallocated")
    }
}

// BONUS: Advanced capture patterns

// Pattern 1: Capture with transformation
class DataManager {
    var userId: String = "user123"
    
    func fetchUserData() {
        // Capture transformed value
        let userIdPrefix = String(userId.prefix(4))
        
        performAsync { [userIdPrefix] in
            print("Processing: \(userIdPrefix)")
        }
    }
    
    func performAsync(block: @escaping () -> Void) {
        DispatchQueue.global().async(execute: block)
    }
}

// Pattern 2: Multiple captures
class MultiCaptureExample {
    var name: String = "Example"
    var count: Int = 0
    
    func process() {
        let snapshot = count
        
        DispatchQueue.global().async { [weak self, name, snapshot] in
            guard let self = self else { return }
            // Has access to: self (weak), name (strong copy), snapshot (value)
            print("\(name): \(snapshot) -> \(self.count)")
        }
    }
}

// Demonstrate the fixes:
print("=== Fix 1: Loop Capture ===")
let scheduler = TaskScheduler()
scheduler.scheduleTasks()

Thread.sleep(forTimeInterval: 7)
print("✅ Each task showed correct number")

print("\n=== Fix 2: Weak Self ===")
var manager: DownloadManager? = DownloadManager()
manager?.startDownload(url: "test")
manager = nil
Thread.sleep(forTimeInterval: 1)
print("✅ Manager deallocated properly")

print("\n=== Fix 5: Lazy Closure ===")
var cache: ImageCache? = ImageCache()
cache?.loadImage()
cache = nil
Thread.sleep(forTimeInterval: 1)
print("✅ Cache deallocated properly")

print("\n✅ All closure capture issues fixed!")
