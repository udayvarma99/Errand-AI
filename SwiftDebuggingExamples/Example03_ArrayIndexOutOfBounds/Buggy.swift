// Example 3: Array Index Out of Bounds
// This code has various array access bugs that cause crashes

import Foundation

struct Task {
    var title: String
    var isCompleted: Bool
}

class TaskManager {
    var tasks: [Task] = []
    
    // BUG 1: Accessing array without checking if empty
    func getFirstTask() -> Task {
        return tasks[0]  // 💥 Crash if array is empty!
    }
    
    // BUG 2: Accessing specific index without validation
    func getTask(at index: Int) -> Task {
        return tasks[index]  // 💥 Crash if index out of range!
    }
    
    // BUG 3: Removing while iterating
    func removeCompletedTasks() {
        for i in 0..<tasks.count {
            if tasks[i].isCompleted {
                tasks.remove(at: i)  // 💥 Crash! Array size changes during iteration
            }
        }
    }
    
    // BUG 4: Unsafe dropFirst usage
    func processAllButFirst() {
        let remaining = Array(tasks.dropFirst())
        for task in remaining {
            print(task.title)  // 💥 Crash if tasks is empty!
        }
    }
    
    // BUG 5: Index from user input not validated
    func deleteTask(userInputIndex: String) {
        let index = Int(userInputIndex)!  // 💥 Crash if not a number!
        tasks.remove(at: index)  // 💥 Crash if index invalid!
    }
    
    // BUG 6: Assuming array has specific number of elements
    func getTopThreeTasks() -> [Task] {
        return [tasks[0], tasks[1], tasks[2]]  // 💥 Crash if less than 3 tasks!
    }
    
    // BUG 7: Using enumerated() incorrectly
    func updateTaskTitles() {
        for (index, _) in tasks.enumerated() {
            tasks[index].title = "Updated"  // Can crash if array modified elsewhere
        }
    }
    
    // BUG 8: Concurrent modification
    func processConcurrently() {
        DispatchQueue.concurrentPerform(iterations: tasks.count) { index in
            print(tasks[index].title)  // 💥 Crash if array modified during execution!
        }
    }
    
    // BUG 9: Dictionary array access
    func getTasksFromDict(_ data: [String: Any]) -> [Task] {
        let taskArray = data["tasks"] as! [Task]
        return [taskArray[0], taskArray[1]]  // 💥 Multiple potential crashes!
    }
    
    // BUG 10: Using range without validation
    func getTaskRange(start: Int, end: Int) -> [Task] {
        return Array(tasks[start...end])  // 💥 Crash if range invalid!
    }
}

// Example usage that will crash:
let manager = TaskManager()

// Crash 1: Empty array access
let first = manager.getFirstTask()  // 💥 Array is empty!

// Crash 2: Invalid index
manager.tasks = [Task(title: "Task 1", isCompleted: false)]
let task = manager.getTask(at: 5)  // 💥 Index 5 doesn't exist!

// Crash 3: Modification during iteration
manager.tasks = [
    Task(title: "Task 1", isCompleted: true),
    Task(title: "Task 2", isCompleted: false),
    Task(title: "Task 3", isCompleted: true)
]
manager.removeCompletedTasks()  // 💥 Array modified during iteration!

// Crash 4: dropFirst on empty array
manager.tasks = []
manager.processAllButFirst()  // 💥 Array is empty!

// Crash 5: Invalid user input
manager.deleteTask(userInputIndex: "abc")  // 💥 Not a number!
manager.deleteTask(userInputIndex: "10")  // 💥 Index doesn't exist!

// Crash 6: Assuming array size
manager.tasks = [Task(title: "Only one", isCompleted: false)]
let top3 = manager.getTopThreeTasks()  // 💥 Only 1 task, trying to access 3!

// Crash 7: Range access
let range = manager.getTaskRange(start: 0, end: 10)  // 💥 End is beyond array size!

print("If you see this, somehow nothing crashed!")
