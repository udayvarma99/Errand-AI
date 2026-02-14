// FIXED: Fully implement all protocol requirements
protocol Drawable {
    var color: String { get }
    func draw()
}

struct Circle: Drawable {
    var color: String = "red"
    
    func draw() {  // ✅ Implement all required methods
        print("Drawing a \(color) circle")
    }
}

// Fix the type mismatch
protocol Identifiable {
    var id: Int { get }
}

struct User: Identifiable {
    var id: Int  // ✅ Match protocol requirement exactly
}

// Or use associated type for flexibility
protocol IdentifiableByID {
    associatedtype ID
    var id: ID { get }
}

struct FlexibleUser: IdentifiableByID {
    var id: String  // OK - ID is String here
}
