/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 2: RETAIN CYCLE MEMORY LEAK
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Memory Management with Closures
 Common In: 80% of Swift interviews (Critical for iOS development)
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - CREATES MEMORY LEAK
// ═══════════════════════════════════════════════════════════════

class NetworkManagerBuggy {
    var url: String
    var onComplete: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized for: \(url)")
    }
    
    func fetchData() {
        // 🐛 BUG: Strong reference cycle (retain cycle)
        // 'self' is captured strongly in the closure
        onComplete = {
            print("Data fetched from: \(self.url)")
            // ⚠️ self holds onComplete, onComplete holds self = LEAK!
        }
        
        // Simulate network call
        onComplete?()
    }
    
    deinit {
        print("NetworkManager deinitialized") // ⚠️ This will NEVER be called!
    }
}

class ViewControllerBuggy {
    var networkManager: NetworkManagerBuggy?
    var data: [String] = []
    
    func loadData() {
        networkManager = NetworkManagerBuggy(url: "https://api.example.com")
        
        // 🐛 BUG: Another retain cycle
        networkManager?.onComplete = {
            // ViewControllerBuggy holds networkManager
            // networkManager.onComplete holds self (ViewControllerBuggy)
            self.data.append("New data")
            print("Data count: \(self.data.count)")
        }
        
        networkManager?.fetchData()
    }
    
    deinit {
        print("ViewController deinitialized") // ⚠️ NEVER called!
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. STRONG REFERENCE CYCLE:
    - NetworkManager has a strong reference to onComplete closure
    - onComplete closure captures 'self' (NetworkManager) strongly
    - Result: NetworkManager → onComplete → NetworkManager (cycle!)
 
 2. MEMORY LEAK:
    - Objects are never deallocated
    - deinit is never called
    - Memory usage keeps growing
 
 3. WHY IT'S BAD:
    - In a real app, this causes memory leaks
    - Multiple ViewControllers = multiple leaked objects
    - App may crash due to memory pressure
    - Common cause of app rejection by Apple
 
 4. HOW TO DETECT:
    - Xcode Instruments (Leaks tool)
    - deinit not being called
    - Memory usage growing over time
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Weak Self
// ═══════════════════════════════════════════════════════════════

class NetworkManagerFixed1 {
    var url: String
    var onComplete: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized for: \(url)")
    }
    
    func fetchData() {
        // ✅ Use [weak self] to break the retain cycle
        onComplete = { [weak self] in
            // self is now Optional (self?)
            guard let self = self else { 
                print("NetworkManager was deallocated")
                return 
            }
            print("Data fetched from: \(self.url)")
        }
        
        onComplete?()
    }
    
    deinit {
        print("✅ NetworkManager deinitialized") // Now this WILL be called!
    }
}

class ViewControllerFixed1 {
    var networkManager: NetworkManagerFixed1?
    var data: [String] = []
    
    func loadData() {
        networkManager = NetworkManagerFixed1(url: "https://api.example.com")
        
        // ✅ Use [weak self] here too
        networkManager?.onComplete = { [weak self] in
            guard let self = self else { return }
            self.data.append("New data")
            print("Data count: \(self.data.count)")
        }
        
        networkManager?.fetchData()
    }
    
    deinit {
        print("✅ ViewController deinitialized") // Now called!
    }
}


// ✅ FIXED CODE - SOLUTION 2: Unowned Self (Use with caution!)
// ═══════════════════════════════════════════════════════════════

class NetworkManagerFixed2 {
    var url: String
    var onComplete: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized for: \(url)")
    }
    
    func fetchData() {
        // ✅ Use [unowned self] when you're CERTAIN self outlives the closure
        onComplete = { [unowned self] in
            // self is NOT optional with unowned
            print("Data fetched from: \(self.url)")
            // ⚠️ DANGER: If self is deallocated, this will CRASH!
        }
        
        onComplete?()
    }
    
    deinit {
        print("✅ NetworkManager deinitialized")
    }
}


// ✅ FIXED CODE - SOLUTION 3: Capture Specific Values
// ═══════════════════════════════════════════════════════════════

class NetworkManagerFixed3 {
    var url: String
    var onComplete: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("NetworkManager initialized for: \(url)")
    }
    
    func fetchData() {
        // ✅ Capture only what you need, not self
        let urlCopy = self.url
        onComplete = {
            print("Data fetched from: \(urlCopy)")
            // No reference to self = no retain cycle!
        }
        
        onComplete?()
    }
    
    deinit {
        print("✅ NetworkManager deinitialized")
    }
}


// ✅ ADVANCED: Using @escaping vs @non-escaping
// ═══════════════════════════════════════════════════════════════

class NetworkManagerAdvanced {
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    // @escaping means closure can outlive the function
    func fetchDataAsync(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // ✅ Closure escapes - may execute after function returns
            completion(self.url) // ⚠️ Still creates retain cycle!
        }
    }
    
    // Better version
    func fetchDataAsyncSafe(completion: @escaping (String) -> Void) {
        let urlCopy = self.url // Capture value, not self
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(urlCopy) // ✅ No retain cycle
        }
    }
    
    deinit {
        print("✅ NetworkManagerAdvanced deinitialized")
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. WEAK vs UNOWNED:
    - weak: Makes self optional, safe if object might be deallocated
    - unowned: Keeps self non-optional, crashes if object is deallocated
    - RULE: Use weak unless you're 100% certain object will outlive closure
 
 2. WHEN TO USE [weak self]:
    - Closures stored as properties
    - @escaping closures
    - Callbacks and completion handlers
    - Any time closure might outlive self
 
 3. WHEN NOT NEEDED:
    - Non-escaping closures (like map, filter, forEach)
    - Trailing closures that execute immediately
    - When not capturing self at all
 
 4. THE GUARD-LET PATTERN:
    guard let self = self else { return }
    - Unwraps weak self
    - Early return if deallocated
    - Makes self non-optional for rest of closure
 
 5. MODERN SWIFT (5.8+):
    - Can use 'self' directly after guard let self = self
    - No need for self.property (though still recommended for clarity)
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "This closure creates a strong reference cycle because the class holds 
    the closure, and the closure captures self strongly."
 
 2. "We need to use [weak self] in the capture list to break the retain cycle."
 
 3. "With weak self, I need to unwrap it since it becomes optional. I'll use 
    guard-let to safely unwrap and exit early if the object was deallocated."
 
 4. "I'd use weak instead of unowned because weak is safer - it won't crash 
    if the object is deallocated, it'll just be nil."
 
 5. "For completion handlers, I always use [weak self] unless there's a 
    specific reason not to."
 
 BONUS DISCUSSION POINTS:
 ✅ "I'd test this with Instruments to verify no leaks"
 ✅ "In production, I'd consider using a completion handler pattern instead"
 ✅ "We could also refactor to avoid storing the closure as a property"
 ✅ "Swift's ARC (Automatic Reference Counting) handles most memory management,
    but we need to be careful with closures"
 
 RED FLAGS:
 ❌ "Memory leaks aren't a big deal in Swift"
 ❌ "I'll just use unowned everywhere" (Dangerous!)
 ❌ Not knowing the difference between weak and unowned
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample2() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 2: RETAIN CYCLE MEMORY LEAK")
    print("═══════════════════════════════════════════════════════\n")
    
    print("❌ BUGGY VERSION (Watch - deinit won't be called):")
    do {
        let buggyVC = ViewControllerBuggy()
        buggyVC.loadData()
        // buggyVC goes out of scope here, but won't be deallocated!
    }
    print("^ Notice: No deinit messages!\n")
    
    print("✅ FIXED VERSION 1 ([weak self]):")
    do {
        let fixedVC = ViewControllerFixed1()
        fixedVC.loadData()
        // fixedVC goes out of scope and IS deallocated
    }
    print("^ Notice: Deinit messages appear!\n")
    
    print("✅ FIXED VERSION 3 (Capture value, not self):")
    do {
        let manager = NetworkManagerFixed3(url: "https://api.example.com")
        manager.fetchData()
    }
    print()
}

// Uncomment to run:
// runExample2()
