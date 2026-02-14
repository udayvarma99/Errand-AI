// FIXED: Proper async/await and Actor usage
import Foundation

func fetchUser() async -> String {
    return "Alice"
}

// Option 1: Make calling function async
func loadData() async {
    let user = await fetchUser()  // ✅ OK - we're in async context
    print(user)
}

// Option 2: Use Task to bridge sync to async
func loadDataFromSync() {
    Task {
        let user = await fetchUser()
        print(user)
    }
}

// Fix data races with Actor
actor DataStore {
    var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)  // ✅ Actor-isolated - thread safe!
    }
    
    func getItems() -> [String] {
        return items
    }
}

// Usage
func useDataStore() async {
    let store = DataStore()
    await store.addItem("First")
    let items = await store.getItems()
}
