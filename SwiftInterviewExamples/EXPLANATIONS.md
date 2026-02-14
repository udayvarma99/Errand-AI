# Detailed Explanations for Each Example

## Example 1: Optional Unwrapping
**Bug**: `Int(input!)!` — Two force unwraps. First crashes if `input` is nil. Second crashes if `Int()` fails (e.g., "abc").
**Fix**: Use `guard let` to safely unwrap both the optional string and the parsed Int. Return `nil` for invalid input.
**Interview tip**: When you see `!`, ask: "Could this ever be nil?"

---

## Example 2: Array Index Bounds
**Bug**: `array[1]` assumes at least 2 elements. Accessing index 1 on `[]` or `[1]` crashes.
**Fix**: Check `array.count > 1` before access, or use `array.indices.contains(1)`.
**Interview tip**: Always validate indices. Consider `array.first`, `array.last`, or safe subscript.

---

## Example 3: Implicitly Unwrapped Optional
**Bug**: `String!` (IUO) can be set to nil later. Any use of it forces unwrap—crash if nil.
**Fix**: Use `String?` and handle nil with `guard let` or nil-coalescing.
**Interview tip**: IUOs are for interoperability (e.g., UIKit). Prefer `String?` in your own code.

---

## Example 4: Mutating in Loop
**Bug**: Removing while iterating shifts indices. The loop can skip elements or crash.
**Fix**: Iterate in reverse (`indices.reversed()`), or use `filter` for a new array.
**Interview tip**: Prefer immutable operations. `filter`, `map`, `reduce` over manual loops.

---

## Example 5: Closure Capture
**Bug**: Closure captures `self` strongly. If `self` holds the closure (e.g., via a property), retain cycle.
**Fix**: Use `[weak self]` and `self?` in the closure.
**Interview tip**: For `@escaping` closures that use `self`, always consider `[weak self]`.

---

## Example 6: Retain Cycle (Delegate)
**Bug**: Parent → Child (strong), Child → Parent (strong). Neither can be deallocated.
**Fix**: Make the "back" reference `weak`. Delegate references are almost always `weak`.
**Interview tip**: Draw the reference graph. If A→B and B→A both strong, you have a cycle.

---

## Example 7: Equatable for Classes
**Bug**: Classes compare by reference. Two instances with same data are not `==` unless you implement it.
**Fix**: Conform to `Equatable` and implement `static func ==`.
**Interview tip**: `===` checks identity. `==` checks equality (needs Equatable).

---

## Example 8: Dictionary Optional
**Bug**: `dict[key]` returns `Value?`. Force unwrapping crashes if key doesn't exist.
**Fix**: Use `??` for default: `dict[key] ?? 0`. Or `if let value = dict[key]`.
**Interview tip**: Dictionary subscript is optional—never force unwrap without checking.

---

## Example 9: Race Condition
**Bug**: `count += 1` is read-modify-write. Two threads can interleave and lose updates.
**Fix**: Serialize access with `DispatchQueue.sync` or use `actor` (Swift concurrency).
**Interview tip**: Shared mutable state + concurrency = need synchronization.

---

## Example 10: Protocol with AssociatedType
**Bug**: Protocols with `associatedtype` are existential types. Can't use as `let x: Container`.
**Fix**: Use as generic constraint `func foo<T: Container>(_ c: T)`, or type erasure.
**Interview tip**: AssociatedType makes protocol "generic." Use `some Container` or type erasure.
