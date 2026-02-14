// FIXED: Break the retain cycle with [weak self]
class ViewModel {
    var onComplete: (() -> Void)?
    
    func doWork() {
        onComplete = { [weak self] in  // ✅ Weak = no retain cycle
            self?.printDone()  // Optional chaining - self might be nil
        }
        onComplete?()
    }
    
    func printDone() {
        print("Done!")
    }
    
    deinit {
        print("ViewModel deallocated")  // ✅ Now prints when vm = nil
    }
}

var vm: ViewModel? = ViewModel()
vm?.doWork()
vm = nil  // "ViewModel deallocated" - proper cleanup!
