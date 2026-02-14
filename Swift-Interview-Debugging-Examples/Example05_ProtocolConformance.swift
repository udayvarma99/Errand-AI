// =============================================================================
// EXAMPLE 5: Protocol Conformance Issue
// =============================================================================
// Difficulty: Intermediate
// Topic:      Protocols, Extensions, Default Implementations
//
// SCENARIO:
// You are building a shape-drawing system using protocols. Each shape must
// provide its area and a description. The code compiles but gives wrong
// results because of a subtle issue with protocol extensions and dynamic
// dispatch.
// =============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// BUGGY CODE — Try to find the bug before scrolling down!
// ─────────────────────────────────────────────────────────────────────────────

protocol ShapeBuggy {
    var area: Double { get }
    // NOTE: description() is NOT declared in the protocol itself
}

extension ShapeBuggy {
    // This provides a "default" description, but it's defined ONLY in the
    // extension — not as a protocol requirement.
    func description() -> String {
        return "A shape with area \(area)"
    }
}

struct CircleBuggy: ShapeBuggy {
    var radius: Double

    var area: Double {
        return Double.pi * radius * radius
    }

    // BUG: This override won't be called when the type is ShapeBuggy!
    func description() -> String {
        return "Circle with radius \(radius) and area \(String(format: "%.2f", area))"
    }
}

func printShapeInfoBuggy(shape: ShapeBuggy) {
    // Because description() is not a protocol REQUIREMENT, Swift uses
    // STATIC dispatch here — it calls the extension's default version,
    // NOT the CircleBuggy version.
    print(shape.description())
}

func demoBuggy() {
    let circle = CircleBuggy(radius: 5.0)

    print("Direct call (works):")
    print(circle.description())  // "Circle with radius 5.0..."

    print("\nThrough protocol (BUG):")
    printShapeInfoBuggy(shape: circle)  // "A shape with area 78.53..." (WRONG!)
    // Expected: "Circle with radius 5.0..."
    print("")
}

demoBuggy()


// ─────────────────────────────────────────────────────────────────────────────
// WHAT WENT WRONG?
// ─────────────────────────────────────────────────────────────────────────────
//
// Swift protocols have two kinds of method dispatch:
//
// 1. DYNAMIC DISPATCH (protocol requirement):
//    If a method is declared in the protocol definition (not just the
//    extension), Swift looks up the actual type at runtime and calls
//    the correct implementation. This is like virtual methods in C++.
//
// 2. STATIC DISPATCH (extension-only method):
//    If a method is ONLY defined in a protocol extension (not in the
//    protocol itself), Swift uses the compile-time type to decide
//    which version to call. If the variable is typed as the protocol,
//    it always calls the extension's version.
//
// The bug: description() was only in the extension, so when called
// through a ShapeBuggy variable, Swift ignores CircleBuggy's version.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// FIXED CODE — Declare the method in the protocol itself
// ─────────────────────────────────────────────────────────────────────────────

protocol ShapeFixed {
    var area: Double { get }
    func description() -> String   // NOW it's a protocol REQUIREMENT
}

extension ShapeFixed {
    // Default implementation — still provided for types that don't customize
    func description() -> String {
        return "A shape with area \(area)"
    }
}

struct CircleFixed: ShapeFixed {
    var radius: Double

    var area: Double {
        return Double.pi * radius * radius
    }

    // This now OVERRIDES the default because description() is a protocol requirement.
    func description() -> String {
        return "Circle with radius \(radius) and area \(String(format: "%.2f", area))"
    }
}

struct RectangleFixed: ShapeFixed {
    var width: Double
    var height: Double

    var area: Double {
        return width * height
    }

    func description() -> String {
        return "Rectangle \(width)x\(height) with area \(String(format: "%.2f", area))"
    }
}

struct TriangleFixed: ShapeFixed {
    var base: Double
    var height: Double

    var area: Double {
        return 0.5 * base * height
    }
    // No custom description() — will use the default from the extension
}

func printShapeInfoFixed(shape: ShapeFixed) {
    // Now Swift uses DYNAMIC dispatch — it checks the actual type at runtime
    // and calls the correct implementation.
    print(shape.description())
}

func demoFixed() {
    let shapes: [ShapeFixed] = [
        CircleFixed(radius: 5.0),
        RectangleFixed(width: 4.0, height: 6.0),
        TriangleFixed(base: 3.0, height: 8.0)
    ]

    print("--- Fixed: Dynamic Dispatch ---")
    for shape in shapes {
        printShapeInfoFixed(shape: shape)
    }
    // Output:
    // Circle with radius 5.0 and area 78.54
    // Rectangle 4.0x6.0 with area 24.00
    // A shape with area 12.0  (uses default — Triangle didn't customize)
}

demoFixed()


// ─────────────────────────────────────────────────────────────────────────────
// KEY TAKEAWAYS FOR YOUR INTERVIEW
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. If you want POLYMORPHIC behavior (the correct method for the actual
//    type), the method MUST be declared in the protocol definition.
//
// 2. Methods defined ONLY in protocol extensions use STATIC dispatch:
//    Swift decides which to call at compile time based on the declared type.
//
// 3. Protocol extension methods are great for providing DEFAULT behavior
//    that types CAN override — but only if the method is also in the
//    protocol definition.
//
// 4. This is one of the TRICKIEST Swift interview questions. Many
//    experienced developers get caught by it.
//
// 5. RULE: If a method should behave differently for different conforming
//    types, ALWAYS declare it in the protocol itself.
//
// 6. Quick test: "If I assign this to a variable typed as the protocol,
//    will the correct implementation be called?" If you need "yes," put
//    the method in the protocol definition.
// ─────────────────────────────────────────────────────────────────────────────
