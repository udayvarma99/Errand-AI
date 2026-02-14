// EXAMPLE 6: Retain Cycle with Delegate (Medium)
// BUG: Strong reference cycle between parent and child
// Expected: Child notifies parent without memory leak

class Parent {
    var child: Child?
    
    init() {
        child = Child(parent: self)  // Parent → Child
    }
}

class Child {
    var parent: Parent?  // Child → Parent (strong!)
    
    init(parent: Parent) {
        self.parent = parent  // 💥 Retain cycle: Parent↔Child
    }
}
// Neither Parent nor Child can ever be deallocated
