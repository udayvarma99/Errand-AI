// Example 7: Closure Capture Lists and Self Reference
// Advanced closure capture issues beyond basic retain cycles

import Foundation

// BUG 1: Capturing wrong value in loop
class TaskScheduler {
    func scheduleTasks() {
        for i in 0...5 {
            // 🐛 Captures reference to 'i', not the value
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                print("Task \(i)")  // All print same value!
            }
        }
    }
}

// BUG 2: Strong reference to self in escaping closure
class DownloadManager {
    var downloads: [String] = []
    var completionHandler: ((String) -> Void)?
    
    func startDownload(url: String) {
        completionHandler = { result in
            self.downloads.append(result)  // 🐛 Strong capture of self
            print(self.downloads.count)
        }
    }
}

// BUG 3: Nested closures with complex capture
class DataProcessor {
    var data: [String] = []
    
    func process() {
        fetchData { [weak self] result in
            // ✅ Weak capture at first level
            self?.parseData(result) { items in
                // 🐛 Self is strong captured in nested closure!
                self?.data = items
                self?.save()
            }
        }
    }
    
    func fetchData(completion: @escaping (String) -> Void) { }
    func parseData(_ data: String, completion: @escaping ([String]) -> Void) { }
    func save() { }
}

// BUG 4: Capturing mutating reference
class Counter {
    var count = 0
    
    func increment() {
        var localCount = count
        
        DispatchQueue.global().async {
            localCount += 1  // 🐛 Modifies copy, not original
            print("Count: \(localCount)")
        }
        
        print("Original still: \(count)")  // Still 0!
    }
}

// BUG 5: Lazy property with closure capturing self
class ImageCache {
    var imageName: String = "default"
    
    lazy var loadImage: () -> Void = {
        // 🐛 Captures self strongly
        print("Loading: \(self.imageName)")
        self.processImage()
    }
    
    func processImage() { }
}

// BUG 6: Map/filter capturing self unnecessarily
class DataFilter {
    var threshold: Int = 10
    
    func filterData(_ numbers: [Int]) -> [Int] {
        // 🐛 Captures self when only threshold is needed
        return numbers.filter { value in
            return value > self.threshold
        }
    }
    
    func transformData(_ numbers: [Int]) -> [Int] {
        // 🐛 Strong capture in map
        return numbers.map { value in
            return value * self.threshold
        }
    }
}

// BUG 7: Capturing class reference in struct
struct EventHandler {
    var delegate: AnyObject?  // Should be weak
    
    func handleEvent() {
        DispatchQueue.main.async {
            // 🐛 Captures struct, which captures delegate strongly
            let _ = self.delegate
        }
    }
}

// BUG 8: Ignoring weak self becoming nil mid-execution
class NetworkManager {
    var cache: [String: Data] = [:]
    
    func fetchData(url: String) {
        URLSession.shared.dataTask(with: URL(string: url)!) { [weak self] data, _, _ in
            guard let data = data else { return }
            
            // 🐛 self might be nil after this point!
            Thread.sleep(forTimeInterval: 2)
            
            self?.cache[url] = data  // Might be nil now
            self?.processData(data)  // Might be nil now
        }
    }
    
    func processData(_ data: Data) { }
}

// BUG 9: Capture list with wrong semantics
class SettingsManager {
    var settings = ["theme": "dark"]
    
    func updateLater() {
        // 🐛 Captures reference to dictionary, not a copy
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [settings] in
            print(settings)  // Might show updated settings!
        }
        
        // Settings changed in meantime
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settings = ["theme": "light"]
        }
    }
}

// BUG 10: GCD closure capturing self in retain cycle
class TimerController {
    var timer: DispatchSourceTimer?
    var count = 0
    
    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 1.0)
        
        // 🐛 Strong capture creates cycle
        timer?.setEventHandler {
            self.count += 1
            print("Count: \(self.count)")
        }
        
        timer?.resume()
    }
    
    // Missing deinit to cancel timer
}

// Demonstrate some bugs:
print("=== Bug 1: Loop Capture ===")
let scheduler = TaskScheduler()
scheduler.scheduleTasks()

Thread.sleep(forTimeInterval: 7)
print("Tasks completed (all probably showed same number)")

print("\n=== Bug 5: Lazy Closure ===")
var cache: ImageCache? = ImageCache()
cache?.loadImage()
cache = nil  // Won't deallocate due to closure cycle

Thread.sleep(forTimeInterval: 1)
print("Cache should be deallocated but isn't")
