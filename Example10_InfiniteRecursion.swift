/*
 ═══════════════════════════════════════════════════════════════
 EXAMPLE 10: INFINITE RECURSION AND STACK OVERFLOW
 ═══════════════════════════════════════════════════════════════
 
 Difficulty: Intermediate
 Topic: Recursion, Stack Management, and Algorithm Design
 Common In: 65% of Swift interviews
 
 ═══════════════════════════════════════════════════════════════
*/

import Foundation

// ❌ BUGGY CODE - MISSING BASE CASE
// ═══════════════════════════════════════════════════════════════

class CalculatorBuggy {
    // 🐛 BUG: No base case - infinite recursion!
    func factorial(_ n: Int) -> Int {
        return n * factorial(n - 1)  // ⚠️ STACK OVERFLOW!
        // Missing: if n <= 1 { return 1 }
    }
    
    // 🐛 BUG: Wrong base case
    func fibonacci(_ n: Int) -> Int {
        if n == 0 { return 0 }
        // Missing: if n == 1 { return 1 }
        return fibonacci(n - 1) + fibonacci(n - 2)  // n=1 → fib(0) + fib(-1) ❌
    }
    
    // 🐛 BUG: Base case never reached
    func countdown(_ n: Int) {
        print(n)
        countdown(n - 1)  // Goes negative forever
    }
}


// ❌ BUGGY CODE - INEFFICIENT RECURSION
// ═══════════════════════════════════════════════════════════════

class TreeBuggy {
    class Node {
        var value: Int
        var left: Node?
        var right: Node?
        
        init(value: Int) {
            self.value = value
        }
    }
    
    // 🐛 BUG: Doesn't check for cycles
    func sum(_ node: Node?) -> Int {
        guard let node = node else { return 0 }
        return node.value + sum(node.left) + sum(node.right)
        // If tree has cycle, infinite recursion!
    }
}

/*
 🔍 WHAT'S WRONG?
 ═══════════════════════════════════════════════════════════════
 
 1. MISSING BASE CASE:
    - Every recursion needs a stopping condition
    - Without it: infinite recursion → stack overflow
    - Runtime error: "EXC_BAD_ACCESS" or stack overflow
 
 2. WRONG BASE CASE:
    - Base case exists but doesn't cover all scenarios
    - Edge cases cause infinite recursion
    - Example: fibonacci(1) → fibonacci(-1)
 
 3. STACK OVERFLOW:
    - Each function call uses stack memory
    - Too many calls = out of memory
    - Swift has limited stack size
 
 4. INEFFICIENCY:
    - Exponential time complexity
    - fibonacci(50) = billions of calls
    - Should use iteration or memoization
 
 ═══════════════════════════════════════════════════════════════
*/


// ✅ FIXED CODE - SOLUTION 1: Proper Base Cases
// ═══════════════════════════════════════════════════════════════

class CalculatorFixed1 {
    func factorial(_ n: Int) -> Int {
        // ✅ Base case: stop recursion
        if n <= 1 { return 1 }
        
        // ✅ Guard against negative
        guard n >= 0 else { return 0 }
        
        return n * factorial(n - 1)
    }
    
    func fibonacci(_ n: Int) -> Int {
        // ✅ Two base cases needed for fibonacci
        if n <= 0 { return 0 }
        if n == 1 { return 1 }
        
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
    
    func countdown(_ n: Int) {
        // ✅ Base case prevents going negative
        if n < 0 { return }
        
        print(n)
        countdown(n - 1)
    }
    
    func sum(array: [Int]) -> Int {
        // ✅ Base case: empty array
        if array.isEmpty { return 0 }
        
        // Split array and recurse
        return array[0] + sum(array: Array(array.dropFirst()))
    }
}


// ✅ FIXED CODE - SOLUTION 2: Iteration Instead of Recursion
// ═══════════════════════════════════════════════════════════════

class CalculatorFixed2 {
    // ✅ Iterative factorial - no stack overflow risk
    func factorial(_ n: Int) -> Int {
        guard n >= 0 else { return 0 }
        
        var result = 1
        for i in 1...n {
            result *= i
        }
        return result
    }
    
    // ✅ Iterative fibonacci - O(n) time, O(1) space
    func fibonacci(_ n: Int) -> Int {
        if n <= 0 { return 0 }
        if n == 1 { return 1 }
        
        var prev = 0
        var current = 1
        
        for _ in 2...n {
            let next = prev + current
            prev = current
            current = next
        }
        
        return current
    }
    
    func countdown(_ n: Int) {
        // ✅ Simple loop
        for i in stride(from: n, through: 0, by: -1) {
            print(i)
        }
    }
}


// ✅ FIXED CODE - SOLUTION 3: Memoization
// ═══════════════════════════════════════════════════════════════

class CalculatorFixed3 {
    private var fibCache: [Int: Int] = [:]
    
    // ✅ Memoized fibonacci - O(n) time
    func fibonacci(_ n: Int) -> Int {
        // Check cache first
        if let cached = fibCache[n] {
            return cached
        }
        
        // Base cases
        if n <= 0 { return 0 }
        if n == 1 { return 1 }
        
        // Calculate and cache
        let result = fibonacci(n - 1) + fibonacci(n - 2)
        fibCache[n] = result
        
        return result
    }
    
    // ✅ Generic memoization
    func memoized<Input: Hashable, Output>(
        _ function: @escaping (Input) -> Output
    ) -> (Input) -> Output {
        var cache: [Input: Output] = [:]
        
        return { input in
            if let cached = cache[input] {
                return cached
            }
            
            let result = function(input)
            cache[input] = result
            return result
        }
    }
}


// ✅ ADVANCED: Tail Recursion Optimization
// ═══════════════════════════════════════════════════════════════

class CalculatorAdvanced {
    // ✅ Tail recursive factorial (compiler can optimize)
    func factorial(_ n: Int, accumulator: Int = 1) -> Int {
        if n <= 1 { return accumulator }
        return factorial(n - 1, accumulator: n * accumulator)
    }
    
    // ✅ Tail recursive fibonacci
    func fibonacci(_ n: Int, a: Int = 0, b: Int = 1) -> Int {
        if n == 0 { return a }
        if n == 1 { return b }
        return fibonacci(n - 1, a: b, b: a + b)
    }
    
    // ✅ Tail recursive sum
    func sum(_ array: [Int], accumulator: Int = 0) -> Int {
        if array.isEmpty { return accumulator }
        return sum(Array(array.dropFirst()), accumulator: accumulator + array[0])
    }
}


// ✅ ADVANCED: Tree Traversal with Cycle Detection
// ═══════════════════════════════════════════════════════════════

class TreeFixed {
    class Node {
        var value: Int
        var left: Node?
        var right: Node?
        
        init(value: Int) {
            self.value = value
        }
    }
    
    // ✅ Recursive with cycle detection
    func sum(_ node: Node?, visited: inout Set<ObjectIdentifier>) -> Int {
        guard let node = node else { return 0 }
        
        let id = ObjectIdentifier(node)
        
        // ✅ Check for cycles
        if visited.contains(id) {
            return 0  // Already visited
        }
        
        visited.insert(id)
        
        return node.value + 
               sum(node.left, visited: &visited) + 
               sum(node.right, visited: &visited)
    }
    
    // ✅ Iterative traversal (no recursion)
    func sumIterative(_ root: Node?) -> Int {
        guard let root = root else { return 0 }
        
        var stack: [Node] = [root]
        var sum = 0
        var visited = Set<ObjectIdentifier>()
        
        while !stack.isEmpty {
            let node = stack.removeLast()
            let id = ObjectIdentifier(node)
            
            if visited.contains(id) { continue }
            visited.insert(id)
            
            sum += node.value
            
            if let right = node.right { stack.append(right) }
            if let left = node.left { stack.append(left) }
        }
        
        return sum
    }
}


// ✅ REAL-WORLD EXAMPLE: File System Traversal
// ═══════════════════════════════════════════════════════════════

class FileSystemExplorer {
    struct FileNode {
        var name: String
        var isDirectory: Bool
        var children: [FileNode]?
        var size: Int  // bytes
    }
    
    // ✅ Calculate total size with depth limit
    func totalSize(_ node: FileNode, maxDepth: Int = 10, currentDepth: Int = 0) -> Int {
        // ✅ Prevent too-deep recursion
        if currentDepth > maxDepth {
            print("Warning: Max depth reached")
            return 0
        }
        
        // Base case: file (not directory)
        guard node.isDirectory, let children = node.children else {
            return node.size
        }
        
        // Recursive case: sum all children
        let childrenSize = children.reduce(0) { total, child in
            total + totalSize(child, maxDepth: maxDepth, currentDepth: currentDepth + 1)
        }
        
        return node.size + childrenSize
    }
    
    // ✅ Find all files matching name
    func findFiles(named target: String, in node: FileNode) -> [String] {
        var paths: [String] = []
        
        if node.name == target {
            paths.append(node.name)
        }
        
        if let children = node.children {
            for child in children {
                let childPaths = findFiles(named: target, in: child)
                paths.append(contentsOf: childPaths.map { "\(node.name)/\($0)" })
            }
        }
        
        return paths
    }
    
    // ✅ Iterative version (safer for deep directories)
    func totalSizeIterative(_ root: FileNode) -> Int {
        var stack: [(node: FileNode, depth: Int)] = [(root, 0)]
        var totalSize = 0
        let maxDepth = 1000
        
        while !stack.isEmpty {
            let (node, depth) = stack.removeLast()
            
            if depth > maxDepth {
                print("Warning: Max depth exceeded")
                continue
            }
            
            totalSize += node.size
            
            if let children = node.children {
                for child in children {
                    stack.append((child, depth + 1))
                }
            }
        }
        
        return totalSize
    }
}


// ✅ PERFORMANCE COMPARISON
// ═══════════════════════════════════════════════════════════════

class PerformanceTester {
    func compareApproaches() {
        print("Computing fibonacci(30)...")
        
        // Naive recursion: Very slow
        var start = Date()
        let calc1 = CalculatorFixed1()
        let result1 = calc1.fibonacci(30)
        print("Naive recursion: \(result1) in \(-start.timeIntervalSinceNow)s")
        
        // Iteration: Fast
        start = Date()
        let calc2 = CalculatorFixed2()
        let result2 = calc2.fibonacci(30)
        print("Iteration: \(result2) in \(-start.timeIntervalSinceNow)s")
        
        // Memoization: Fast (first call, then cached)
        start = Date()
        let calc3 = CalculatorFixed3()
        let result3 = calc3.fibonacci(30)
        print("Memoization: \(result3) in \(-start.timeIntervalSinceNow)s")
    }
}


/*
 📚 KEY TAKEAWAYS
 ═══════════════════════════════════════════════════════════════
 
 1. RECURSION ESSENTIALS:
    - Always have a base case
    - Make progress toward base case
    - Handle all edge cases
    - Consider depth limits
 
 2. WHEN TO USE RECURSION:
    - Tree/graph traversal
    - Divide and conquer algorithms
    - Backtracking problems
    - When structure is naturally recursive
 
 3. WHEN TO AVOID RECURSION:
    - Simple loops suffice
    - Deep recursion risk (large datasets)
    - Performance is critical
    - Stack overflow risk
 
 4. OPTIMIZATION TECHNIQUES:
    - Memoization (cache results)
    - Tail recursion (compiler optimization)
    - Convert to iteration
    - Limit recursion depth
 
 5. DEBUGGING RECURSION:
    - Print current state and depth
    - Use debugger to see call stack
    - Check base cases first
    - Test with small inputs
 
 ═══════════════════════════════════════════════════════════════
*/


/*
 🎤 INTERVIEW TIPS
 ═══════════════════════════════════════════════════════════════
 
 WHAT INTERVIEWERS WANT TO HEAR:
 
 1. "This recursive function is missing a base case, which will cause 
    infinite recursion and stack overflow."
 
 2. "I'd add a base case to stop when n <= 1, and also guard against 
    negative inputs."
 
 3. "For fibonacci, naive recursion is O(2^n) which is too slow. I'd use 
    iteration for O(n) time and O(1) space, or memoization for O(n) both."
 
 4. "In production, I'd consider iteration over recursion to avoid stack 
    overflow with large datasets."
 
 5. "I'd add a depth limit to prevent stack overflow if the input is 
    unexpectedly large or has cycles."
 
 BONUS POINTS:
 ✅ Discuss time/space complexity
 ✅ Mention tail call optimization
 ✅ Compare recursion vs iteration tradeoffs
 ✅ Know when to use each approach
 ✅ Explain memoization and dynamic programming
 
 TRADE-OFFS TO DISCUSS:
 - Recursion: Elegant but can overflow
 - Iteration: Verbose but safe
 - Memoization: Fast but uses memory
 - Tail recursion: Optimizable by compiler
 
 RED FLAGS:
 ❌ Not checking for base case
 ❌ Not considering stack overflow
 ❌ Using recursion for simple loops
 ❌ Not knowing complexity analysis
 
 COMMON FOLLOW-UP QUESTIONS:
 Q: "What's tail recursion?"
 A: "When the recursive call is the last operation in the function. Some 
     compilers can optimize this into a loop, avoiding stack growth."
 
 Q: "How would you debug a stack overflow?"
 A: "Check base cases, add depth counter, reduce input size for testing, 
     look at call stack in debugger, consider iteration."
 
 Q: "What's the difference between recursion and iteration?"
 A: "Recursion uses the call stack implicitly, iteration uses explicit 
     loops. Recursion is elegant for tree-like structures, iteration is 
     safer for deep/unknown depths."
 
 ═══════════════════════════════════════════════════════════════
*/


// 🧪 TEST THE CODE
// ═══════════════════════════════════════════════════════════════

func runExample10() {
    print("═══════════════════════════════════════════════════════")
    print("EXAMPLE 10: INFINITE RECURSION")
    print("═══════════════════════════════════════════════════════\n")
    
    print("✅ FIXED RECURSION (Proper base cases):")
    let calc1 = CalculatorFixed1()
    print("Factorial(5) = \(calc1.factorial(5))")
    print("Fibonacci(10) = \(calc1.fibonacci(10))")
    print("Countdown from 5:")
    calc1.countdown(5)
    print()
    
    print("✅ ITERATION (Safe and efficient):")
    let calc2 = CalculatorFixed2()
    print("Factorial(10) = \(calc2.factorial(10))")
    print("Fibonacci(20) = \(calc2.fibonacci(20))")
    print()
    
    print("✅ MEMOIZATION (Fast for repeated calls):")
    let calc3 = CalculatorFixed3()
    print("Fibonacci(30) = \(calc3.fibonacci(30))")
    print("Fibonacci(30) again = \(calc3.fibonacci(30)) (cached!)")
    print()
    
    print("✅ TAIL RECURSION:")
    let calcAdv = CalculatorAdvanced()
    print("Factorial(7) = \(calcAdv.factorial(7))")
    print("Fibonacci(15) = \(calcAdv.fibonacci(15))")
    print()
    
    print("✅ TREE TRAVERSAL:")
    let tree = TreeFixed()
    let root = TreeFixed.Node(value: 10)
    root.left = TreeFixed.Node(value: 5)
    root.right = TreeFixed.Node(value: 15)
    root.left?.left = TreeFixed.Node(value: 3)
    
    var visited = Set<ObjectIdentifier>()
    let sum = tree.sum(root, visited: &visited)
    print("Tree sum (recursive): \(sum)")
    print("Tree sum (iterative): \(tree.sumIterative(root))")
    print()
    
    print("✅ PERFORMANCE COMPARISON:")
    let perf = PerformanceTester()
    perf.compareApproaches()
    print()
}

// Uncomment to run:
// runExample10()
