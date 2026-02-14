# Example 6: Protocol Conformance

## The Bug
Forgetting to implement a protocol method or using wrong types causes compiler errors. Swift won't let you compile until ALL protocol requirements are satisfied.

## The Fix
1. Implement every required property and method
2. Match types exactly (Int vs String matters!)
3. Use `associatedtype` if you need flexible types

## Interview Tip
"What's the difference between protocol and class inheritance?" - Protocols define contracts (what), classes provide implementation (how). Swift uses protocol-oriented programming heavily.
