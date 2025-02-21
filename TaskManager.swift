import Foundation
import SwiftUI

/// TaskManager is a class that manages the tasks.
/// It is responsible for creating, updating, deleting and archiving tasks.
/// It also provides a method to filter and sort tasks.
class TaskManager: ObservableObject {
    /// The list of tasks.
    /// It is published so that the TaskListView can observe it.
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks() // Save whenever tasks are modified
        }
    }
    
    private let savePathString = FileManager.documentsDirectory.appendingPathComponent("tasks.json").path()
    
    init() {
        loadTasks() // Load tasks when initializing
    }
    
    /// Saves tasks to disk
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: URL(filePath: savePathString))
        } catch {
            print("Error saving tasks: \(error.localizedDescription)")
        }
    }
    
    /// Loads tasks from disk
    private func loadTasks() {
        do {
            let data = try Data(contentsOf: URL(filePath: savePathString))
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            // If loading fails, initialize with demo tasks
            tasks = [
                Task(
                    title: "Skip Sanitizing on Bus",
                    category: .contamination,
                    trigger: "Fear of germs from public surfaces.",
                    goal: "Avoid washing hands for a period of time.",
                    instructions: [
                        "Take a bus and hold onto a handrail.",
                        "Sit with hands on lap without sanitizing.",
                        "Wait 30 minutes before washing hands."
                    ],
                    duration: 30,
                    anxietyLevel: 5,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 1, hour: 9, minute: 30),
                        .dateAt(daysAgo: 3, hour: 14, minute: 15),
                        .dateAt(daysAgo: 7, hour: 16, minute: 45)
                    ]
                ),
                Task(
                    title: "Leave Without Checking Locks",
                    category: .checking,
                    trigger: "Fear of leaving doors unlocked.",
                    goal: "Lock once and leave without checking.",
                    instructions: [
                        "Lock the door once and leave immediately.",
                        "Avoid looking back or double-checking.",
                        "Distract yourself for 30 minutes."
                    ],
                    duration: 30,
                    anxietyLevel: 4,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 2, hour: 11),
                        .dateAt(daysAgo: 4, hour: 15, minute: 30),
                        .dateAt(daysAgo: 6, hour: 18)
                    ]
                ),
                Task(
                    title: "Leave Items Unaligned",
                    category: .symmetry,
                    trigger: "Discomfort when things aren't 'just right'.",
                    goal: "Resist fixing misaligned objects.",
                    instructions: [
                        "Place objects slightly off-center.",
                        "Resist the urge to straighten them.",
                        "Sit with the discomfort for 30 minutes."
                    ],
                    duration: 30,
                    anxietyLevel: 3,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 1, hour: 20),
                        .dateAt(daysAgo: 3, hour: 19, minute: 45),
                        .dateAt(daysAgo: 7, hour: 21, minute: 15)
                    ]
                ),
                Task(
                    title: "Throw Away One Item",
                    category: .hoarding,
                    trigger: "Fear of discarding something useful.",
                    goal: "Discard one item without retrieving it.",
                    instructions: [
                        "Pick one unused or broken item.",
                        "Throw it away in a trash can.",
                        "Sit and resist retrieving it for 10 minutes."
                    ],
                    duration: 10,
                    anxietyLevel: 2,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 20, hour: 10, minute: 30),
                        .dateAt(daysAgo: 40, hour: 11, minute: 15),
                        .dateAt(daysAgo: 60, hour: 9, minute: 45)
                    ]
                ),
                Task(
                    title: "Wear Mismatched Socks at Home",
                    category: .symmetry,
                    trigger: "Fear of imbalance or bad luck.",
                    goal: "Wear mismatched socks and resist fixing.",
                    instructions: [
                        "Pick different socks and put them on.",
                        "Do regular activities at home.",
                        "Resist checking or changing socks for 1 hour."
                    ],
                    duration: 60,
                    anxietyLevel: 5,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 3, hour: 8, minute: 30),
                        .dateAt(daysAgo: 10, hour: 7, minute: 45),
                        .dateAt(daysAgo: 17, hour: 8, minute: 15)
                    ]
                ),
                Task(
                    title: "Delay Analyzing Conversations",
                    category: .ruminations,
                    trigger: "Urge to replay a past conversation for mistakes.",
                    goal: "Postpone overthinking for a period of time.",
                    instructions: [
                        "Set a 10-minute timer when the urge starts.",
                        "Do a distraction (e.g. read a book).",
                        "If the thought returns, say: 'Not now, later.'",
                    ],
                    duration: 10,
                    anxietyLevel: 2,
                    status: .available,
                    completions: [
                        .dateAt(daysAgo: 2, hour: 22, minute: 30),
                        .dateAt(daysAgo: 5, hour: 23, minute: 15)
                    ]
                ),
                Task(
                    title: "Touch a Public Door Handle",
                    category: .contamination,
                    trigger: "Fear of germs on shared surfaces.",
                    goal: "Avoid washing hands for a period of time.",
                    instructions: [
                        "Grasp a public door handle.",
                        "Resist using sanitizer or washing hands.",
                        "Engage in another activity for 20 minutes."
                    ],
                    duration: 20,
                    anxietyLevel: 4,
                    status: .archived,
                    completions: [
                        .dateAt(daysAgo: 14, hour: 13, minute: 30),
                        .dateAt(daysAgo: 16, hour: 14, minute: 45),
                        .dateAt(daysAgo: 18, hour: 15, minute: 15)
                    ]
                ),
                Task(
                    title: "Leave It Unfinished",
                    category: .checking,
                    trigger: "Fear of not completing something perfectly.",
                    goal: "Stop an activity before completing it and walk away.",
                    instructions: [
                        "Choose a task (e.g., cleaning your room).",
                        "Stop when you're 90% finished.",
                        "Resist the urge to go back and 'fix' it.",
                        "Engage in another activity for 15 minutes."
                    ],
                    duration: 15,
                    anxietyLevel: 5,
                    status: .archived,
                    completions: [
                        .dateAt(daysAgo: 15, hour: 16, minute: 30),
                        .dateAt(daysAgo: 17, hour: 17, minute: 45),
                        .dateAt(daysAgo: 19, hour: 16, minute: 15)
                    ]
                ),
            ]
        }
    }
    
    /// Adds a task to the list of tasks.
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    /// Updates a task in the list of tasks.
    func updateTask(_ updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
        }
    }
    
    /// Marks a task as completed.
    func markTaskCompleted(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.completions.insert(Date(), at: 0)
            updatedTask.status = .available
            tasks[index] = updatedTask
        }
    }
    
    /// Deletes a task from the list of tasks.
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    /// Archives a task.
    func archiveTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.status = .archived
            tasks[index] = updatedTask
        }
    }
    
    /// Unarchives a task.
    func unarchiveTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.status = .available
            tasks[index] = updatedTask
        }
    }
}

extension TaskManager {
    /// Returns tasks filtered by a given status, then sorted by the given sortOrder.
    @available(iOS 17, *)
    func tasks(with status: TaskStatus, sortedBy sortOrder: TaskSortOrder) -> [Task] {
        let filtered = tasks.filter { $0.status == status }
        
        switch sortOrder {
        case .title:
            return filtered.sorted { $0.title < $1.title }
        case .category:
            return filtered.sorted { $0.category.rawValue < $1.category.rawValue }
        case .anxietyLevel:
            return filtered.sorted { $0.anxietyLevel < $1.anxietyLevel }
        }
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension Date {
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
    
    static func dateAt(daysAgo: Int, hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // First, move back the specified number of days
        guard let daysBackDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return today }
        
        // Then, set the specific hour and minute
        let components = calendar.dateComponents([.year, .month, .day], from: daysBackDate)
        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = components.day
        newComponents.hour = hour
        newComponents.minute = minute
        
        return calendar.date(from: newComponents) ?? today
    }
}
