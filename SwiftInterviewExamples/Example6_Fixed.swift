// EXAMPLE 6: Retain Cycle with Delegate (FIXED)
// Use weak reference for the "back" pointer (child→parent)

class Parent {
    var child: Child?
    
    init() {
        child = Child(parent: self)
    }
}

class Child {
    weak var parent: Parent?  // weak breaks the cycle!
    
    init(parent: Parent) {
        self.parent = parent
    }
}
// When Parent is released, Child can be released too
