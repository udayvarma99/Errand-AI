// EXAMPLE 10: Protocol Conformance (Hard)
// BUG: Protocol with associated type - common compile error
// Expected: Generic container that conforms to protocol

protocol Container {
    associatedtype Item
    var count: Int { get }
    func add(_ item: Item)
}

class IntBox: Container {
    var items: [Int] = []
    var count: Int { items.count }
    func add(_ item: Int) { items.append(item) }
}
// ❌ Compiler: "Protocol 'Container' can only be used as a generic constraint"
// You can't do: let c: Container = IntBox()
