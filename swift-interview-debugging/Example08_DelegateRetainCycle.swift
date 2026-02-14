// =============================================================================
// EXAMPLE 8: Delegate Retain Cycle (Weak Reference)
// =============================================================================
// INTERVIEW TIP: Delegates must be weak to avoid retain cycles!
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Strong delegate = Retain cycle
// -----------------------------------------------------------------------------
// Parent holds Child, Child holds Parent via delegate → both never deallocate

protocol DataSourceDelegate: AnyObject {
    func didReceive(data: String)
}

class DataSource_BUG {
    var delegate: DataSourceDelegate?  // ❌ Strong by default
}

class ViewController_BUG: DataSourceDelegate {
    let dataSource = DataSource_BUG()
    
    init() {
        dataSource.delegate = self  // self → dataSource → delegate → self (CYCLE!)
    }
    
    func didReceive(data: String) {
        print(data)
    }
}
// ViewController and DataSource hold each other = leak

// -----------------------------------------------------------------------------
// ✅ FIX: Delegate must be weak
// -----------------------------------------------------------------------------

// 1. Protocol must inherit from AnyObject (delegate = reference type)
protocol DataSourceDelegate_FIX: AnyObject {
    func didReceive(data: String)
}

class DataSource_FIX {
    weak var delegate: DataSourceDelegate_FIX?  // ✅ Weak breaks cycle
}

class ViewController_FIX: DataSourceDelegate_FIX {
    let dataSource = DataSource_FIX()
    
    init() {
        dataSource.delegate = self
        // dataSource holds WEAK ref to self = no cycle
    }
    
    func didReceive(data: String) {
        print(data)
    }
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Closure in delegate that captures self
// -----------------------------------------------------------------------------

class Worker_BUG {
    var onFinish: (() -> Void)?
    
    func start() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.onFinish?()  // ❌ self captured strongly
        }
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX: [weak self] in async closure
// -----------------------------------------------------------------------------

class Worker_FIX {
    var onFinish: (() -> Void)?
    
    func start() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.onFinish?()
        }
    }
}

// 📌 KEY LESSON: delegate = weak. Protocol: AnyObject. Closures: [weak self].
//    The delegating object should never strongly own its delegate.
