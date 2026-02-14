// BUGGY: Incomplete protocol conformance - Compiler error
protocol Drawable {
    var color: String { get }
    func draw()
}

struct Circle: Drawable {
    var color: String = "red"
    // 💥 Error: Type 'Circle' does not conform to protocol 'Drawable'
    // Missing required method: func draw()
}
