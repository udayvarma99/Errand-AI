# Example 10: Async/Await & Actor Isolation

## The Bug
- `await` can only be used inside `async` functions or `Task { }`
- Mutable shared state without synchronization = **data races** (hard to debug!)

## The Fix
- Mark functions `async` when they need to await
- Use `Task { }` to call async from sync code
- Use `actor` for shared mutable state - Swift guarantees serial access

## Interview Tip
"What's the difference between actor and class?" - Actors protect their state from concurrent access. Only one task can access actor state at a time. Essential for Swift 6 concurrency!
