# Example 8: Equatable & Hashable

## The Bug
Custom types don't support `==` or `contains()` by default. You must explicitly conform to `Equatable`. For `Set` or `Dictionary` keys, you need `Hashable` too.

## The Fix
Add `: Equatable` to your struct. Swift can **synthesize** the implementation if all stored properties are Equatable. For Hashable, same idea - add conformance.

## Interview Tip
"What's the relationship between Equatable and Hashable?" - Hashable extends Equatable. If a == b, they must have same hash. But same hash doesn't mean equal (hash collision).
