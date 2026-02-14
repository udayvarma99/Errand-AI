// EXAMPLE 5: Closure Capture (Medium)
// BUG: Capturing self strongly in async closure causes retain cycle
// Expected: Call API and update UI

class ViewController {
    var label: String = ""
    
    func loadData() {
        fetchData { result in
            self.label = result  // 💥 Strong capture of self
        }
    }
    
    func fetchData(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            completion("Data loaded")
        }
    }
}
// If ViewController holds reference to closure, neither can be deallocated
