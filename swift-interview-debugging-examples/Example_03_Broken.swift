// Example 3: Retain Cycle (Memory Leak)
// BUG: Closure strongly captures self, self holds closure = cycle
// Apple interviews: "Why isn't this view controller deallocated?"

import Foundation

class DataProcessor {
    var data: [Int] = [1, 2, 3]
    
    var processClosure: (() -> Void)?  // Strong reference to closure
    
    func setupProcessing() {
        processClosure = {
            self.data = self.data.map { $0 * 2 }  // 💥 Strong capture of self
        }
    }
    
    deinit {
        print("DataProcessor deallocated")
    }
}

var processor: DataProcessor? = DataProcessor()
processor?.setupProcessing()
processor = nil  // Never prints "deallocated" - MEMORY LEAK!
