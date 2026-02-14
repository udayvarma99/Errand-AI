# Example 1: Optional Handling

## The Bug
Using `!` (force unwrap) on an optional that might be nil causes a **runtime crash**. This is one of the most common Swift interview questions.

## The Fix
- **guard let** - Early exit if nil (preferred for validation)
- **if let** - Unwrap and use in a scope
- **Nil coalescing (??)** - Provide default value

## Interview Tip
Apple interviewers often ask: "When would you use `!`?"  
Answer: Rarely! Only when you're 100% sure (e.g., @IBOutlet after view loads). Prefer safe unwrapping.
