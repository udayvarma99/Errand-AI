// Example 8 FIXED: MainActor for UI updates
// UI updates MUST happen on main thread - use @MainActor or MainActor.run

import Foundation

@MainActor  // ✅ All properties and methods on main actor
class ViewModel {
    var title: String = ""
    
    func loadData() async {
        let data = await fetchFromNetwork()  // Can run on background
        title = data  // ✅ Safe - we're in @MainActor class
    }
    
    nonisolated func fetchFromNetwork() async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Loaded"
    }
}

// Alternative: Use MainActor.run { } inside the async function
// await MainActor.run { self.title = data }
