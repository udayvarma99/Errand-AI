// EXAMPLE 10: Protocol Conformance (FIXED)
// Use generics or type erasure when protocol has associatedtype

protocol Container {
    associatedtype Item
    var count: Int { get }
    func add(_ item: Item)
}

class IntBox: Container {
    typealias Item = Int  // Explicit associated type
    var items: [Int] = []
    var count: Int { items.count }
    func add(_ item: Int) { items.append(item) }
}

// To store different containers: use type erasure
struct AnyContainer<T>: Container {
    private let _count: () -> Int
    private let _add: (T) -> Void
    
    init<C: Container>(_ container: C) where C.Item == T {
        _count = { container.count }
        _add = { container.add($0) }
    }
    var count: Int { _count() }
    func add(_ item: T) { _add(item) }
}
// let containers: [AnyContainer<Int>] = [AnyContainer(IntBox())]
