// =============================================================================
// EXAMPLE 9: Delegation Pattern Bug
// Topic: Forgetting to set delegate, retain cycles with delegates
// Difficulty: Intermediate
// =============================================================================

import Foundation

// =============================================================================
// BUGGY CODE - Try to find the bug before scrolling down!
// =============================================================================

/*

// BUG 1: Delegate is never set — delegate methods are never called

protocol DownloadDelegate {
    func downloadDidStart()
    func downloadDidFinish(data: String)
    func downloadDidFail(error: String)
}

class DownloadManager {
    var delegate: DownloadDelegate?  // BUG: also should be 'weak' — see Bug 2

    func startDownload(url: String) {
        delegate?.downloadDidStart()

        // Simulate download
        if url.isEmpty {
            delegate?.downloadDidFail(error: "URL is empty")
        } else {
            delegate?.downloadDidFinish(data: "Downloaded content from \(url)")
        }
    }
}

class ViewController {
    let downloadManager = DownloadManager()

    func viewDidLoad() {
        // BUG: Forgot to set downloadManager.delegate = self !
        downloadManager.startDownload(url: "https://apple.com")
        // Nothing happens — delegate methods are never called
    }
}


// BUG 2: Strong delegate causes retain cycle

class DownloadManager2 {
    var delegate: DownloadDelegate?  // BUG: Strong reference!
    // ViewController → DownloadManager2 (strong)
    // DownloadManager2 → ViewController/delegate (strong) → RETAIN CYCLE
}

class ViewController2: DownloadDelegate {
    let manager = DownloadManager2()

    func setup() {
        manager.delegate = self  // Creates retain cycle!
    }

    func downloadDidStart() { }
    func downloadDidFinish(data: String) { }
    func downloadDidFail(error: String) { }

    deinit { print("ViewController2 deinitialized") }  // NEVER called!
}

*/

// =============================================================================
// WHAT GOES WRONG?
// =============================================================================
//
// Bug 1: The most common delegation mistake — forgetting to set the delegate.
//         The delegate property remains nil, so delegate?.method() does nothing
//         (optional chaining silently returns nil).
//
// Bug 2: If the delegate is a strong reference, and the delegating object is
//         owned by the delegate (common pattern), you get a retain cycle:
//           ViewController --strong--> DownloadManager
//           DownloadManager --strong--> ViewController (via delegate)
//
// Both are extremely common iOS bugs.
//

// =============================================================================
// FIXED CODE
// =============================================================================

// --- Fix: Proper delegation pattern ---

// Step 1: Define the protocol (mark as AnyObject for 'weak' support)
protocol DownloadDelegate: AnyObject {
    func downloadDidStart()
    func downloadDidFinish(data: String)
    func downloadDidFail(error: String)
}

// Step 2: The delegating class uses a WEAK delegate
class DownloadManager {
    weak var delegate: DownloadDelegate?  // FIX: 'weak' prevents retain cycle

    func startDownload(url: String) {
        print("[DownloadManager] Starting download...")
        delegate?.downloadDidStart()

        // Simulate download
        if url.isEmpty {
            delegate?.downloadDidFail(error: "URL is empty")
        } else {
            // Simulate network delay
            delegate?.downloadDidFinish(data: "Data from \(url)")
        }
    }
}

// Step 3: The conforming class sets itself as the delegate
class ViewController: DownloadDelegate {
    let downloadManager = DownloadManager()

    func viewDidLoad() {
        // FIX: Don't forget to set the delegate!
        downloadManager.delegate = self
        downloadManager.startDownload(url: "https://apple.com")
    }

    // Implement ALL delegate methods
    func downloadDidStart() {
        print("[ViewController] Download started!")
    }

    func downloadDidFinish(data: String) {
        print("[ViewController] Download finished: \(data)")
    }

    func downloadDidFail(error: String) {
        print("[ViewController] Download failed: \(error)")
    }

    deinit {
        print("[ViewController] Deinitialized")  // Now this works!
    }
}

// --- Test ---
print("=== Proper Delegation Pattern ===")
var vc: ViewController? = ViewController()
vc?.viewDidLoad()

print("\n=== Releasing ViewController ===")
vc = nil  // "[ViewController] Deinitialized" — no retain cycle!

// =============================================================================
// BONUS: Delegation with optional methods (using protocol extensions)
// =============================================================================

protocol TableViewDelegate: AnyObject {
    // Required method
    func numberOfRows() -> Int

    // Optional methods (provide defaults in extension)
    func heightForRow(at index: Int) -> Double
    func didSelectRow(at index: Int)
}

extension TableViewDelegate {
    // Default implementations make these methods "optional"
    func heightForRow(at index: Int) -> Double {
        return 44.0  // Default row height
    }

    func didSelectRow(at index: Int) {
        // Default: do nothing
    }
}

class SimpleTableView {
    weak var delegate: TableViewDelegate?

    func render() {
        guard let delegate = delegate else {
            print("Warning: No delegate set for TableView!")
            return
        }

        let rows = delegate.numberOfRows()
        for i in 0..<rows {
            let height = delegate.heightForRow(at: i)
            print("  Row \(i): height = \(height)")
        }
    }

    func simulateTap(at index: Int) {
        delegate?.didSelectRow(at: index)
    }
}

class MyController: TableViewDelegate {
    let tableView = SimpleTableView()

    func setup() {
        tableView.delegate = self
        tableView.render()
    }

    // Required: must implement
    func numberOfRows() -> Int {
        return 3
    }

    // Optional: only override if needed
    func didSelectRow(at index: Int) {
        print("  Selected row \(index)")
    }

    // heightForRow — uses default implementation (44.0)
}

print("\n=== Bonus: Optional delegate methods ===")
let controller = MyController()
controller.setup()
controller.tableView.simulateTap(at: 1)

// =============================================================================
// COMMON DELEGATION CHECKLIST (for interviews)
// =============================================================================
//
//  1. [ ] Define protocol (preferably inheriting from AnyObject)
//  2. [ ] Declare delegate property as 'weak var'
//  3. [ ] Call delegate methods using optional chaining (delegate?.method())
//  4. [ ] Conforming class implements all required methods
//  5. [ ] Conforming class sets itself as delegate (object.delegate = self)
//

// =============================================================================
// KEY TAKEAWAY
// =============================================================================
//
// The delegation pattern requires:
//   1. A protocol defining the delegate methods
//   2. A weak delegate property (to avoid retain cycles)
//   3. The delegate being SET (most common forgotten step!)
//   4. The conforming type implementing all required methods
//
// In interviews, Apple engineers look for:
//   1. Knowing to make delegate properties 'weak'
//   2. Understanding WHY it must be weak (retain cycle prevention)
//   3. Protocol must inherit from AnyObject/class for 'weak' to work
//   4. Difference between delegation and closures/callbacks
//   5. How to make optional protocol methods (via extensions)
//
// Common interview question:
//   "Why do we declare delegates as weak in iOS?"
//   Answer: To prevent retain cycles. The delegating object (e.g., UITableView)
//   holds a weak reference to its delegate (e.g., UIViewController). If it were
//   strong, the VC could never be deallocated because the tableView holds it,
//   and the VC holds the tableView.
// =============================================================================
