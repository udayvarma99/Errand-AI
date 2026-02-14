// EXAMPLE 5: Closure Capture (FIXED)
// Use [weak self] to break retain cycle

class ViewController {
    var label: String = ""
    
    func loadData() {
        fetchData { [weak self] result in
            self?.label = result  // Safe: self is optional when weak
        }
    }
    
    func fetchData(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            completion("Data loaded")
        }
    }
}
// When ViewController is deallocated, closure doesn't prevent it
