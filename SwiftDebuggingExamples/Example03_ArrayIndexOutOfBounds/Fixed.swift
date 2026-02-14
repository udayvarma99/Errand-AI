// Example 3: Array Index Out of Bounds - FIXED VERSION
// Safe array access prevents crashes

import Foundation

struct Task {
    var title: String
    var isCompleted: Bool
}

class TaskManager {
    var tasks: [Task] = []
    
    // FIX 1: Use first property (returns optional)
    func getFirstTask() -> Task? {
        return tasks.first  // ✅ Returns nil if empty
    }
    
    // Alternative: Provide default or throw
    func getFirstTaskWithDefault() -> Task {
        return tasks.first ?? Task(title: "No tasks", isCompleted: false)
    }
    
    // FIX 2: Validate index before accessing
    func getTask(at index: Int) -> Task? {
        guard tasks.indices.contains(index) else {
            return nil
        }
        return tasks[index]
    }
    
    // Alternative: Safe subscript extension
    func getTaskSafe(at index: Int) -> Task? {
        return tasks[safe: index]  // See extension below
    }
    
    // FIX 3: Filter instead of removing during iteration
    func removeCompletedTasks() {
        tasks = tasks.filter { !$0.isCompleted }  // ✅ Creates new array
    }
    
    // Alternative: Iterate in reverse
    func removeCompletedTasksReverse() {
        for i in (0..<tasks.count).reversed() {
            if tasks[i].isCompleted {
                tasks.remove(at: i)  // ✅ Safe because going backwards
            }
        }
    }
    
    // FIX 4: Check if array is empty first
    func processAllButFirst() {
        guard !tasks.isEmpty else {
            print("No tasks to process")
            return
        }
        
        let remaining = Array(tasks.dropFirst())
        for task in remaining {
            print(task.title)
        }
    }
    
    // FIX 5: Validate user input
    func deleteTask(userInputIndex: String) -> Bool {
        guard let index = Int(userInputIndex),
              tasks.indices.contains(index) else {
            print("Invalid index")
            return false
        }
        tasks.remove(at: index)
        return true
    }
    
    // Alternative: Return Result type
    func deleteTaskWithResult(userInputIndex: String) -> Result<Void, TaskError> {
        guard let index = Int(userInputIndex) else {
            return .failure(.invalidInput)
        }
        
        guard tasks.indices.contains(index) else {
            return .failure(.indexOutOfRange)
        }
        
        tasks.remove(at: index)
        return .success(())
    }
    
    // FIX 6: Use prefix to get limited number
    func getTopThreeTasks() -> [Task] {
        return Array(tasks.prefix(3))  // ✅ Returns up to 3, never crashes
    }
    
    // Alternative: Check count first
    func getTopThreeTasksExact() -> [Task]? {
        guard tasks.count >= 3 else {
            return nil
        }
        return Array(tasks[0..<3])
    }
    
    // FIX 7: Use indices or make copy
    func updateTaskTitles() {
        for index in tasks.indices {
            tasks[index].title = "Updated"  // ✅ Uses valid indices
        }
    }
    
    // Alternative: Enumerate with guard
    func updateTaskTitlesSafe() {
        for (index, _) in tasks.enumerated() {
            guard tasks.indices.contains(index) else { continue }
            tasks[index].title = "Updated"
        }
    }
    
    // FIX 8: Use thread-safe copy for concurrent access
    func processConcurrently() {
        let tasksCopy = tasks  // Create copy for thread safety
        
        DispatchQueue.concurrentPerform(iterations: tasksCopy.count) { index in
            print(tasksCopy[index].title)  // ✅ Safe to access copy
        }
    }
    
    // FIX 9: Safe dictionary and array access
    func getTasksFromDict(_ data: [String: Any]) -> [Task]? {
        guard let taskArray = data["tasks"] as? [Task],
              taskArray.count >= 2 else {
            return nil
        }
        return Array(taskArray.prefix(2))
    }
    
    // FIX 10: Validate range
    func getTaskRange(start: Int, end: Int) -> [Task]? {
        guard start >= 0,
              end < tasks.count,
              start <= end else {
            return nil
        }
        return Array(tasks[start...end])
    }
    
    // Alternative: Clamping range
    func getTaskRangeClamped(start: Int, end: Int) -> [Task] {
        let validStart = max(0, min(start, tasks.count - 1))
        let validEnd = max(validStart, min(end, tasks.count - 1))
        
        guard !tasks.isEmpty else { return [] }
        return Array(tasks[validStart...validEnd])
    }
}

// Custom error enum
enum TaskError: Error {
    case invalidInput
    case indexOutOfRange
    case emptyArray
}

// Extension for safe array subscripting
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Additional safe operations
extension Array {
    func element(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    mutating func safeRemove(at index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return remove(at: index)
    }
    
    mutating func safeInsert(_ element: Element, at index: Int) -> Bool {
        guard index >= 0, index <= count else { return false }
        insert(element, at: index)
        return true
    }
}

// Safe usage examples:
let manager = TaskManager()

// Safe 1: Empty array access
if let first = manager.getFirstTask() {
    print("First task: \(first.title)")
} else {
    print("No tasks available")
}

// Safe 2: Index validation
if let task = manager.getTask(at: 5) {
    print("Task: \(task.title)")
} else {
    print("Invalid index")
}

// Safe 3: Safe removal
manager.tasks = [
    Task(title: "Task 1", isCompleted: true),
    Task(title: "Task 2", isCompleted: false),
    Task(title: "Task 3", isCompleted: true)
]
manager.removeCompletedTasks()  // ✅ No crash
print("Remaining tasks: \(manager.tasks.count)")

// Safe 4: Check before dropFirst
manager.tasks = []
manager.processAllButFirst()  // ✅ Handles empty array gracefully

// Safe 5: Validate input
let success = manager.deleteTask(userInputIndex: "abc")
print("Delete success: \(success)")

// Safe 6: Prefix for top N
manager.tasks = [Task(title: "Only one", isCompleted: false)]
let top3 = manager.getTopThreeTasks()  // ✅ Returns 1 task
print("Top tasks: \(top3.count)")

// Safe 7: Using safe subscript
if let task = manager.tasks[safe: 10] {
    print("Task: \(task.title)")
} else {
    print("Index 10 doesn't exist")
}

// Safe 8: Range with validation
if let range = manager.getTaskRange(start: 0, end: 10) {
    print("Range: \(range.count)")
} else {
    print("Invalid range")
}

// Additional safe patterns
let tasks = [
    Task(title: "Task 1", isCompleted: false),
    Task(title: "Task 2", isCompleted: true),
    Task(title: "Task 3", isCompleted: false)
]

// Safe: Use first(where:)
if let completed = tasks.first(where: { $0.isCompleted }) {
    print("Found completed: \(completed.title)")
}

// Safe: Use last
if let lastTask = tasks.last {
    print("Last task: \(lastTask.title)")
}

// Safe: Use isEmpty before accessing
if !tasks.isEmpty {
    print("Has tasks: \(tasks[0].title)")
}

// Safe: Use count check
if tasks.count > 2 {
    print("Third task: \(tasks[2].title)")
}

print("✅ All operations completed safely!")
