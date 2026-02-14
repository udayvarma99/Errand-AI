// Example 3 FIXED: Weak/Unowned Reference
// Break the cycle: closure captures self weakly

import Foundation

class DataProcessor {
    var data: [Int] = [1, 2, 3]
    
    var processClosure: (() -> Void)?
    
    func setupProcessing() {
        processClosure = { [weak self] in  // ✅ weak breaks the cycle
            guard let self = self else { return }
            self.data = self.data.map { $0 * 2 }
        }
    }
    
    deinit {
        print("DataProcessor deallocated")
    }
}

var processor: DataProcessor? = DataProcessor()
processor?.setupProcessing()
processor = nil  // Prints "DataProcessor deallocated" - no leak!
