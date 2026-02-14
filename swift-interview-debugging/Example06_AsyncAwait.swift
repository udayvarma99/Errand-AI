// =============================================================================
// EXAMPLE 6: Async/Await Ordering & Completion Handler Bugs
// =============================================================================
// INTERVIEW TIP: Async work completes in unpredictable order—handle it!
// =============================================================================

// -----------------------------------------------------------------------------
// 🐛 BUG: Assuming async work finishes in order
// -----------------------------------------------------------------------------

var results: [String] = []

func fetchData_BUG() {
    fetchFromAPI(id: 1) { result in
        results.append(result)
    }
    fetchFromAPI(id: 2) { result in
        results.append(result)
    }
    print(results)  // ❌ Empty! Callbacks haven't run yet
}

func fetchFromAPI(id: Int, completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
        completion("Result-\(id)")
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX 1: Use DispatchGroup to wait for all
// -----------------------------------------------------------------------------

func fetchData_FIX1() {
    let group = DispatchGroup()
    
    group.enter()
    fetchFromAPI(id: 1) { result in
        results.append(result)
        group.leave()
    }
    
    group.enter()
    fetchFromAPI(id: 2) { result in
        results.append(result)
        group.leave()
    }
    
    group.notify(queue: .main) {
        print(results)  // ✅ Has both results
    }
}

// -----------------------------------------------------------------------------
// ✅ FIX 2: Using async/await (Swift 5.5+)
// -----------------------------------------------------------------------------

func fetchFromAPIAsync(id: Int) async -> String {
    try? await Task.sleep(nanoseconds: 100_000_000)
    return "Result-\(id)"
}

func fetchData_FIX2() async {
    async let r1 = fetchFromAPIAsync(id: 1)
    async let r2 = fetchFromAPIAsync(id: 2)
    let results = await [r1, r2]  // ✅ Runs in parallel, awaits both
    print(results)
}

// -----------------------------------------------------------------------------
// 🐛 BUG: Not calling completion on error path
// -----------------------------------------------------------------------------

func loadUser_BUG(id: Int, completion: @escaping (String?) -> Void) {
    if id < 0 {
        return  // ❌ Never calls completion! Caller waits forever
    }
    completion("User-\(id)")
}

// -----------------------------------------------------------------------------
// ✅ FIX: Always call completion (success or failure)
// -----------------------------------------------------------------------------

func loadUser_FIX(id: Int, completion: @escaping (String?) -> Void) {
    if id < 0 {
        completion(nil)  // ✅ Caller gets result
        return
    }
    completion("User-\(id)")
}

// 📌 KEY LESSON: Async code runs LATER. Never assume order. Use groups,
//    async/await, or call completion on ALL code paths (including errors).
