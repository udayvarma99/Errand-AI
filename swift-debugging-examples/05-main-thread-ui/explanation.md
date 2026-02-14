# Example 5: Main Thread UI Updates

## The Bug
UIKit/AppKit are **not thread-safe**. Updating UI from a background thread causes undefined behavior, UI glitches, or crashes. Very common when using `DispatchQueue.async` or URLSession.

## The Fix
- `DispatchQueue.main.async { ... }` - Switch to main thread
- `@MainActor` - Mark entire method/class as main-thread only (Swift concurrency)

## Interview Tip
"How do you update UI after a network call?" - Always dispatch to main. Know `DispatchQueue.main.async` vs `sync` (sync can deadlock!).
