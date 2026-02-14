// BUGGY: Retain cycle - Memory leak! Very common in UIKit/Combine
class ViewModel {
    var onComplete: (() -> Void)?  // Closure holds strong ref to self
    
    func doWork() {
        // 💥 self captures closure, closure captures self = RETAIN CYCLE
        onComplete = {
            self.printDone()  // Strong reference to self!
        }
        onComplete?()
    }
    
    func printDone() {
        print("Done!")
    }
    
    deinit {
        print("ViewModel deallocated")  // Never prints - memory leak!
    }
}

var vm: ViewModel? = ViewModel()
vm?.doWork()
vm = nil  // ViewModel never gets deallocated!
