// =============================================================================
// EXAMPLE 5: Closure Capture & Retain Cycles
// =============================================================================
//
// DIFFICULTY: Intermediate
// TOPIC: Closures, Capture Lists, [weak self], [unowned self]
// APPLE INTERVIEW TIP: This is arguably the #1 most-asked Swift question at
//   Apple interviews. If you only study one topic, make it this one. Closures
//   capturing 'self' is the most common source of memory leaks in iOS apps.
//
// WHAT YOU WILL LEARN:
//   - How closures capture variables (including 'self')
//   - Why this creates retain cycles
//   - How to use [weak self] and [unowned self] capture lists
//   - The proper pattern for handling [weak self] in closures
// =============================================================================


// ---------------------------------------------------------------------------
// BUGGY CODE — Try to find the bug before scrolling down!
// ---------------------------------------------------------------------------

/*

class ProfileViewController {
    var name: String
    var onProfileLoaded: (() -> Void)?
    
    init(name: String) {
        self.name = name
        print("ProfileVC for \(name) initialized")
    }
    
    func loadProfile() {
        // BUG: This closure captures 'self' strongly
        // Creating a retain cycle: self -> onProfileLoaded -> self
        onProfileLoaded = {
            print("Profile loaded for \(self.name)")
            self.updateUI()
        }
        
        // Simulate async callback
        onProfileLoaded?()
    }
    
    func updateUI() {
        print("Updating UI for \(name)")
    }
    
    deinit {
        print("ProfileVC for \(name) deinitialized")
    }
}

var vc: ProfileViewController? = ProfileViewController(name: "Tim Cook")
vc?.loadProfile()
vc = nil  // deinit is NEVER called! Memory leak! 💥

*/


// ---------------------------------------------------------------------------
// WHY IS THIS A BUG?
// ---------------------------------------------------------------------------
//
// When a closure references 'self' (or any of self's properties/methods),
// the closure creates a STRONG reference to self. Here's the cycle:
//
//   ProfileViewController (self)
//       │
//       ├── strong ref ──> onProfileLoaded (closure)
//       │                       │
//       │                       └── strong ref ──> self (captures 'self')
//       │                                            │
//       └──────────────────────────────────────────────
//
// self → closure → self  =  RETAIN CYCLE
//
// Even after you set 'vc = nil', the cycle keeps both alive:
//   - self can't be freed because the closure holds it
//   - The closure can't be freed because self holds it
//
// This is THE most common memory leak in iOS development.
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// FIXED CODE — Use [weak self] capture list
// ---------------------------------------------------------------------------

class ProfileViewController {
    var name: String
    var onProfileLoaded: (() -> Void)?
    
    init(name: String) {
        self.name = name
        print("ProfileVC for \(name) initialized")
    }
    
    func loadProfile() {
        // FIX: Use [weak self] in the capture list
        // This makes the closure's reference to self WEAK (doesn't increase refcount)
        onProfileLoaded = { [weak self] in
            // 'self' is now an optional (ProfileViewController?)
            // because weak references become nil when the object is deallocated
            
            // PATTERN 1: guard let (Most common and recommended)
            guard let self = self else {
                print("ProfileVC was deallocated before callback")
                return
            }
            // After guard let, 'self' is a strong, non-optional reference
            // that's safe to use for the rest of the closure
            print("Profile loaded for \(self.name)")
            self.updateUI()
        }
        
        onProfileLoaded?()
    }
    
    func updateUI() {
        print("Updating UI for \(name)")
    }
    
    deinit {
        print("ProfileVC for \(name) deinitialized")
    }
}


// ---------------------------------------------------------------------------
// TEST — Verify the retain cycle is broken
// ---------------------------------------------------------------------------

print("=== Test 1: Normal usage ===")
var vc: ProfileViewController? = ProfileViewController(name: "Tim Cook")
vc?.loadProfile()
vc = nil  // Now deinit IS called!
// Output:
// ProfileVC for Tim Cook initialized
// Profile loaded for Tim Cook
// Updating UI for Tim Cook
// ProfileVC for Tim Cook deinitialized  ← Properly cleaned up!

print("\n=== Test 2: Deallocated before callback ===")
var vc2: ProfileViewController? = ProfileViewController(name: "Craig Federighi")
// Don't call loadProfile — just set to nil
vc2 = nil  // deinit called immediately
// Output:
// ProfileVC for Craig Federighi initialized
// ProfileVC for Craig Federighi deinitialized


// ---------------------------------------------------------------------------
// COMMON REAL-WORLD PATTERNS WITH [weak self]
// ---------------------------------------------------------------------------

class DataManager {
    var data: [String] = []
    
    func fetchData(completion: @escaping ([String]) -> Void) {
        // Simulate network delay
        // In real code: URLSession.shared.dataTask(...)
        completion(["Item 1", "Item 2", "Item 3"])
    }
    
    deinit { print("DataManager deinitialized") }
}

class ListViewController {
    let manager = DataManager()
    var items: [String] = []
    
    // PATTERN: Network request with [weak self]
    func refreshData() {
        manager.fetchData { [weak self] newItems in
            guard let self = self else { return }
            self.items = newItems
            self.reloadTable()
        }
    }
    
    func reloadTable() {
        print("Table reloaded with \(items.count) items")
    }
    
    deinit { print("ListVC deinitialized") }
}

print("\n=== Real-world pattern test ===")
var listVC: ListViewController? = ListViewController()
listVC?.refreshData()
listVC = nil
// Both deinit messages print — no leaks!


// ---------------------------------------------------------------------------
// WHEN TO USE [weak self] vs [unowned self]
// ---------------------------------------------------------------------------
//
// [weak self]:
//   - self becomes Optional inside the closure
//   - Safe even if self is deallocated before the closure runs
//   - Use when the closure might outlive self
//   - USE THIS BY DEFAULT — it's always safe
//   - Common in: network callbacks, timers, animations, async operations
//
// [unowned self]:
//   - self is NON-optional inside the closure (more convenient)
//   - CRASHES if self is deallocated before the closure runs
//   - Use ONLY when you are 100% certain self will always be alive
//   - Common in: lazy properties, closures that self always outlives
//
//   // Safe use of [unowned self]:
//   lazy var fullName: String = { [unowned self] in
//       return "\(self.firstName) \(self.lastName)"
//   }()
//   // The lazy var can only be accessed while self exists,
//   // so unowned is safe here.
//
// RULE OF THUMB: When in doubt, use [weak self]. The minor inconvenience
// of unwrapping is worth the crash prevention.


// ---------------------------------------------------------------------------
// APPLE INTERVIEW QUESTION YOU MIGHT GET:
// ---------------------------------------------------------------------------
//
// Q: "Look at this code. Is there a memory leak? If so, how would you fix it?"
//
//   class ViewController: UIViewController {
//       var timer: Timer?
//
//       override func viewDidLoad() {
//           super.viewDidLoad()
//           timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//               self.updateClock()
//           }
//       }
//
//       func updateClock() { /* update UI */ }
//   }
//
// A: YES, there's a memory leak. The Timer closure captures 'self' strongly.
//    Additionally, Timer itself is retained by the RunLoop.
//    The cycle: RunLoop -> Timer -> closure -> self -> timer -> Timer
//
//    Fix:
//    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//        self?.updateClock()
//    }
//
//    And invalidate the timer in deinit or viewWillDisappear:
//    deinit {
//        timer?.invalidate()
//    }
// ---------------------------------------------------------------------------
