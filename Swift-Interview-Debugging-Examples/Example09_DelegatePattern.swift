// =============================================================================
// EXAMPLE 9: Delegate Pattern Bug (Weak Reference)
// =============================================================================
// Difficulty: Intermediate
// Topic:      Delegation, Protocols, Weak References, Retain Cycles
//
// SCENARIO:
// You are building a download manager that notifies a view controller when
// a download completes, using the delegate pattern. But there are TWO bugs:
// 1. The delegate is 'strong', creating a retain cycle (memory leak).
// 2. The delegate is never actually assigned.
// =============================================================================

import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

protocol DownloadDelegateBuggy {
    func downloadDidComplete(data: String)
    func downloadDidFail(error: String)
}

class DownloadManagerBuggy {
    // BUG 1: 'var delegate' is a STRONG reference.
    // The ViewController owns the DownloadManager, and DownloadManager
    // strongly owns the delegate (which IS the ViewController).
    // This creates a retain cycle!
    var delegate: DownloadDelegateBuggy?

    func startDownload() {
        print("Download started...")
        // Simulate async download
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // Notify delegate on main thread
            DispatchQueue.main.async {
                self.delegate?.downloadDidComplete(data: "File contents here")
            }
        }
    }

    deinit {
        print("DownloadManagerBuggy deallocated")
    }
}

class DownloadViewControllerBuggy: DownloadDelegateBuggy {
    let downloadManager = DownloadManagerBuggy()
    var receivedData: String?

    func startDownload() {
        // BUG 2: Forgot to set downloadManager.delegate = self!
        // The delegate is nil, so downloadDidComplete will never be called.
        downloadManager.startDownload()
    }

    func downloadDidComplete(data: String) {
        receivedData = data
        print("ViewController received data: \(data)")
    }

    func downloadDidFail(error: String) {
        print("ViewController error: \(error)")
    }

    deinit {
        print("DownloadViewControllerBuggy deallocated")
    }
}

func demoBuggy() {
    var vc: DownloadViewControllerBuggy? = DownloadViewControllerBuggy()
    vc?.startDownload()

    // Wait a moment for the "download" to complete
    Thread.sleep(forTimeInterval: 1.0)

    // BUG 2: receivedData is nil — delegate was never set!
    print("Received data: \(vc?.receivedData ?? "nil")")

    vc = nil
    // BUG 1: If delegate WAS set, neither object would be deallocated
    // due to the retain cycle (strong delegate reference).
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// BUG 1: Retain Cycle through Strong Delegate
//   ViewController ──strong──▶ DownloadManager ──strong──▶ delegate (ViewController)
//   This creates a cycle. Neither object can be deallocated.
//   FIX: Make the delegate 'weak'. In Swift, 'weak' can only apply to
//   class types, so the protocol must be marked with ': AnyObject'.
//
// BUG 2: Forgot to Set the Delegate
//   The delegate property is nil by default. If you never assign it,
//   the optional chaining (delegate?.downloadDidComplete) silently does nothing.
//   This is a very common mistake — easy to forget, hard to debug.
//   FIX: Set downloadManager.delegate = self in the view controller.
//
// The delegate pattern is used EVERYWHERE in iOS:
//   - UITableViewDelegate / UITableViewDataSource
//   - UITextFieldDelegate
//   - URLSessionDelegate
//   - CLLocationManagerDelegate
// Getting it right is essential for Apple interviews.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE
// ─────────────────────────────────────────────────────────────────────────────

// FIX 1: Add ': AnyObject' so the protocol can only be adopted by classes.
// This allows us to use 'weak' for the delegate property.
protocol DownloadDelegateFixed: AnyObject {
    func downloadDidComplete(data: String)
    func downloadDidFail(error: String)
}

class DownloadManagerFixed {
    // FIX 1: Make delegate 'weak' to break the retain cycle.
    // 'weak' requires the protocol to be class-only (AnyObject).
    weak var delegate: DownloadDelegateFixed?

    func startDownload() {
        print("Download started...")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.downloadDidComplete(data: "File contents here")
            }
        }
    }

    deinit {
        print("DownloadManagerFixed deallocated")
    }
}

class DownloadViewControllerFixed: DownloadDelegateFixed {
    let downloadManager = DownloadManagerFixed()
    var receivedData: String?

    init() {
        // FIX 2: Set the delegate! This is the most common mistake.
        // Can also be done in viewDidLoad() in a real UIViewController.
    }

    func setup() {
        // FIX 2: Assign self as the delegate.
        // (We do this in a separate method because 'self' is not fully
        // initialized inside init() for classes.)
        downloadManager.delegate = self
    }

    func startDownload() {
        setup()  // Ensure delegate is set before starting
        downloadManager.startDownload()
    }

    func downloadDidComplete(data: String) {
        receivedData = data
        print("ViewController received data: \(data)")
    }

    func downloadDidFail(error: String) {
        print("ViewController error: \(error)")
    }

    deinit {
        print("DownloadViewControllerFixed deallocated")
    }
}

func demoFixed() {
    var vc: DownloadViewControllerFixed? = DownloadViewControllerFixed()
    vc?.startDownload()

    // Wait for "download" to complete
    Thread.sleep(forTimeInterval: 1.0)

    // Now receivedData has the value!
    print("Received data: \(vc?.receivedData ?? "nil")")

    vc = nil
    // With weak delegate, both objects are properly deallocated!
    Thread.sleep(forTimeInterval: 0.5)  // Give time for deinit to run
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. ALWAYS make delegate properties 'weak' to avoid retain cycles.
//    Pattern: weak var delegate: MyDelegate?
//
// 2. For 'weak', the protocol must be class-only:
//    protocol MyDelegate: AnyObject { ... }
//
// 3. ALWAYS remember to SET the delegate! This is the #1 delegate bug.
//    In UIKit: set in viewDidLoad() or when creating the child object.
//
// 4. The delegate pattern has 5 steps:
//    a) Define a protocol with required methods
//    b) Add a weak delegate property to the delegating object
//    c) Call delegate methods when events occur
//    d) Conform to the protocol in the receiving class
//    e) Set yourself as the delegate (the most forgotten step!)
//
// 5. If your delegate method isn't being called, check:
//    a) Did you set the delegate? (most common)
//    b) Is the delegate still alive? (not deallocated due to weak reference)
//    c) Are you calling the delegate method from the right thread?
//
// 6. Modern alternative: closures/callbacks instead of delegates.
//    Delegates are better when there are many events to handle.
//    Closures are simpler for single-event notifications.
// ─────────────────────────────────────────────────────────────────────────────
