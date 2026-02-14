// Example 8: Async/Await - UI on Background Thread
// BUG: Updating UI from background thread = crashes or glitches
// "The app crashes when I load data" - MainActor/thread safety

import Foundation
// In a real app, you'd use UIKit/SwiftUI

class ViewModel {
    var title: String = ""  // Would be @Published or bind to UI
    
    func loadData() async {
        let data = await fetchFromNetwork()  // Runs on background
        title = data  // 💥 BUG: Updating UI-bound property off main thread!
    }
    
    func fetchFromNetwork() async -> String {
        try? await Task.sleep(nanoseconds: 100_000_000)
        return "Loaded"
    }
}
