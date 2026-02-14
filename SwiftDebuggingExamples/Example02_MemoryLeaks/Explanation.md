# Example 2: Memory Leaks with Retain Cycles

## 🐛 The Problem

Memory leaks occur when objects hold strong references to each other, preventing ARC (Automatic Reference Counting) from deallocating them. This causes memory usage to grow over time, eventually leading to app crashes or poor performance.

**You won't see a crash** - the app just uses more and more memory!

## 🔍 What is a Retain Cycle?

A retain cycle happens when:
- Object A has a strong reference to Object B
- Object B has a strong reference to Object A
- Neither can be deallocated because the retain count never reaches zero

```
Person (strong) → Apartment
   ↑                  ↓
   └────── (strong) ──┘
   
Neither can be deallocated! 💥
```

## 📊 Types of Retain Cycles

### 1. Two-Object Cycle
```swift
// WRONG
class Person {
    var apartment: Apartment?  // Strong reference
}
class Apartment {
    var tenant: Person?  // Strong reference → CYCLE!
}

// RIGHT
class Apartment {
    weak var tenant: Person?  // Weak reference → No cycle
}
```

### 2. Closure Cycle
```swift
// WRONG
class Manager {
    var handler: (() -> Void)?
    
    func setup() {
        handler = {
            self.doWork()  // Captures self strongly → CYCLE!
        }
    }
}

// RIGHT
func setup() {
    handler = { [weak self] in
        self?.doWork()  // Weak capture → No cycle
    }
}
```

### 3. Delegate Cycle
```swift
// WRONG
protocol Delegate {
    func didUpdate()
}
class DataSource {
    var delegate: Delegate?  // Strong reference → CYCLE!
}

// RIGHT
protocol Delegate: AnyObject {  // Class-only protocol
    func didUpdate()
}
class DataSource {
    weak var delegate: Delegate?  // Weak reference → No cycle
}
```

## ✅ The Solutions

### Solution 1: `weak` References

Use `weak` when the reference might become `nil`:

```swift
weak var delegate: SomeDelegate?
weak var parent: ParentView?
```

**Characteristics:**
- Optional (always)
- Can become `nil` automatically
- Use for delegates, parent references, observers

### Solution 2: `unowned` References

Use `unowned` when the reference will always exist:

```swift
unowned let customer: Customer  // Credit card can't exist without customer
```

**Characteristics:**
- Not optional
- Never becomes `nil`
- Crashes if accessed after deallocation
- Use when relationship is required

### Solution 3: Capture Lists in Closures

```swift
// Weak self - handles deallocation gracefully
someMethod { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}

// Unowned self - assumes self exists
someMethod { [unowned self] in
    self.doSomething()
}

// Capture specific properties
someMethod { [weak self, url = self.url] in
    print(url)  // Captures value, not reference
}
```

## 📋 Decision Tree: weak vs unowned

```
Does the referenced object outlive the referencing object?
├─ YES → Use unowned
│   Example: CreditCard.customer
│   (Card can't exist without customer)
│
└─ NO or UNCERTAIN → Use weak
    Example: Apartment.tenant
    (Apartment can exist without tenant)
```

## 🎯 Common Scenarios

### Scenario 1: Parent-Child Relationships
```swift
class ParentViewController {
    var child: ChildViewController?
}

class ChildViewController {
    weak var parent: ParentViewController?  // ✅ Child doesn't own parent
}
```

### Scenario 2: Delegates
```swift
protocol ViewDelegate: AnyObject {
    func didTapButton()
}

class CustomView {
    weak var delegate: ViewDelegate?  // ✅ View doesn't own delegate
}
```

### Scenario 3: Notification Observers
```swift
class Observer {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification),
            name: .dataUpdated,
            object: nil
        )
    }
    
    deinit {
        // ✅ Always remove observers!
        NotificationCenter.default.removeObserver(self)
    }
}
```

### Scenario 4: GCD and Async Operations
```swift
// WRONG
DispatchQueue.main.async {
    self.updateUI()  // Strong capture
}

// RIGHT
DispatchQueue.main.async { [weak self] in
    self?.updateUI()
}
```

### Scenario 5: Timers
```swift
// WRONG
class TimerManager {
    var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()  // Strong capture → LEAK!
        }
    }
}

// RIGHT
class TimerManager {
    var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    deinit {
        timer?.invalidate()  // ✅ Clean up timer
    }
}
```

## 🚨 Common Mistakes

### Mistake 1: Weak var in struct
```swift
struct MyStruct {
    weak var delegate: SomeDelegate?  // ❌ ERROR: weak only works with classes
}
```

### Mistake 2: Forgetting AnyObject
```swift
protocol MyDelegate {  // ❌ Can't use weak
    func didUpdate()
}

protocol MyDelegate: AnyObject {  // ✅ Now can use weak
    func didUpdate()
}
```

### Mistake 3: Using unowned incorrectly
```swift
class Manager {
    var handler: (() -> Void)?
    
    func setup() {
        handler = { [unowned self] in
            self.work()  // 💥 Crashes if Manager is deallocated
        }
    }
}
```

## 💪 Practice Exercise

Find and fix the retain cycle:

```swift
class DownloadManager {
    var onComplete: ((Data) -> Void)?
    var data: Data?
    
    func download() {
        URLSession.shared.dataTask(with: URL(string: "https://example.com")!) { data, _, _ in
            self.data = data
            self.onComplete?(data!)
        }.resume()
    }
}

class ViewController {
    var downloadManager = DownloadManager()
    
    func viewDidLoad() {
        downloadManager.onComplete = { data in
            self.updateUI(with: data)
        }
        downloadManager.download()
    }
    
    func updateUI(with data: Data) {
        print("Updating UI")
    }
}
```

**Answer:**

```swift
class DownloadManager {
    var onComplete: ((Data) -> Void)?
    var data: Data?
    
    func download() {
        URLSession.shared.dataTask(with: URL(string: "https://example.com")!) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            self.data = data
            self.onComplete?(data)
        }.resume()
    }
}

class ViewController {
    var downloadManager = DownloadManager()
    
    func viewDidLoad() {
        downloadManager.onComplete = { [weak self] data in
            self?.updateUI(with: data)
        }
        downloadManager.download()
    }
    
    func updateUI(with data: Data) {
        print("Updating UI")
    }
}
```

## 📚 Key Takeaways

1. **Use `weak` for optional relationships** (delegates, observers, parents)
2. **Use `unowned` for required relationships** (when reference must exist)
3. **Always use `[weak self]` in closures** unless you're certain
4. **Delegates should always be weak** and protocols should inherit `AnyObject`
5. **Clean up in `deinit`** (remove observers, invalidate timers)
6. **Test deallocation** by adding `deinit` with print statements
