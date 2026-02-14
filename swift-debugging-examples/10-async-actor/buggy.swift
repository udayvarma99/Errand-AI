// BUGGY: Mixing sync and async incorrectly - Swift Concurrency
import Foundation

func fetchUser() async -> String {
    return "Alice"
}

// 💥 Error: 'async' function in a function that does not support concurrency
func loadData() {
    let user = await fetchUser()  // Can't use await in sync context!
    print(user)
}

// 💥 Data race: Nonisolated access to mutable state
class DataStore {
    var items: [String] = []
    
    func addItem(_ item: String) {
        items.append(item)  // Not actor-isolated - data race risk!
    }
}
