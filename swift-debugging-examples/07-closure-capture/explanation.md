# Example 7: Closure Capture Semantics

## The Bug
In a loop, closures capture variables **by reference**. When the closure runs later, `i` has already changed to the loop's final value. All closures see the same final value!

## The Fix
Use capture list `[i]` to capture the value at closure creation time. Each closure gets its own copy of `i` at that moment.

## Interview Tip
"What does [weak self] do in a closure?" - Part of capture list syntax. Also know [unowned], [variable] for value capture. Very common interview question!
