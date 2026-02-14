# Example 3: Retain Cycles (Memory Leaks)

## The Bug
When a closure captures `self` strongly, and `self` holds the closure, you get a **retain cycle**. Neither can be deallocated. This causes memory leaks - critical in iOS apps!

## The Fix
Use `[weak self]` in closures that reference self. Then use `self?` (optional chaining) since self might be nil if the object was deallocated.

## Interview Tip
"When do you use weak vs unowned?" 
- **weak**: Object might be nil (e.g., view controller). Use `self?`
- **unowned**: Object will outlive closure (guaranteed). Crashes if wrong!
