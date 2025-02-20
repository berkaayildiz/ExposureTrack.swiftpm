import Foundation

/// Task is a struct that represents an ERP task.
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var trigger: String
    var goal: String
    var instructions: [String]
    var duration: Int
    var anxietyLevel: Int8 // Value between 1 and 5
    var status: TaskStatus
    var completions: [Date]
    
    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory,
        trigger: String,
        goal: String,
        instructions: [String],
        duration: Int,
        anxietyLevel: Int8,
        status: TaskStatus,
        completions: [Date] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.trigger = trigger
        self.goal = goal
        self.instructions = instructions
        self.duration = duration
        self.anxietyLevel = anxietyLevel
        self.status = status
        self.completions = completions
    }

    func updated(
        title: String? = nil,
        category: TaskCategory? = nil,
        trigger: String? = nil,
        goal: String? = nil,
        instructions: [String]? = nil,
        duration: Int? = nil,
        anxietyLevel: Int8? = nil,
        status: TaskStatus? = nil,
        completions: [Date]? = nil
    ) -> Task {
        Task(
            id: self.id,
            title: title ?? self.title,
            category: category ?? self.category,
            trigger: trigger ?? self.trigger,
            goal: goal ?? self.goal,
            instructions: instructions ?? self.instructions,
            duration: duration ?? self.duration,
            anxietyLevel: anxietyLevel ?? self.anxietyLevel,
            status: status ?? self.status,
            completions: completions ?? self.completions
        )
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case contamination = "Contamination"
    case checking = "Checking"
    case symmetry = "Symmetry"
    case ruminations = "Ruminations"
    case hoarding = "Hoarding"
}

enum TaskStatus: String, Codable {
    case available = "Available"
    case ongoing = "Ongoing"
    case archived = "Archived"
}

enum TaskSortOrder: String, CaseIterable, Codable {
    case title = "Title"
    case category = "Category"
    case anxietyLevel = "Anxiety Level"
}
