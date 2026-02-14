// =============================================================================
// EXAMPLE 2: Retain Cycle in Closures (Memory Leak)
// =============================================================================
// INTERVIEW TIP: [weak self] is critical when self is captured in closures
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Closure captures self strongly → Retain cycle → Memory leak
// -----------------------------------------------------------------------------

class ViewController_BUG {
    var onComplete: (() -> Void)?
    
    func setupButton() {
        onComplete = {
            self.doSomething()  // ❌ Strong reference to self
            // self holds onComplete, onComplete holds self = CYCLE!
        }
    }
    
    func doSomething() {
        print("Done!")
    }
}
// ViewController never gets deallocated!

// -----------------------------------------------------------------------------
// ✅ FIX: Use [weak self] to break the cycle
// -----------------------------------------------------------------------------

class ViewController_FIX {
    var onComplete: (() -> Void)?
    
    func setupButton() {
        onComplete = { [weak self] in
            self?.doSomething()  // ✅ Weak = no cycle
        }
    }
    
    func doSomething() {
        print("Done!")
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX (Alternative): Use [unowned self] if self can never be nil
// -----------------------------------------------------------------------------
// WARNING: [unowned self] will CRASH if self is deallocated. Use only when
// you're certain the closure won't outlive self (e.g., UIView.animate).

// When using UIKit:
// UIView.animate(withDuration: 1.0) { [weak self] in
//     self?.view.alpha = 0.5  // Safe - weak breaks the cycle
// }

// 📌 KEY LESSON: When a closure captures self, use [weak self] and optional
//    chain: self?.method(). Prefer weak over unowned to avoid crashes.
