import SwiftUI

/// TaskFormView is a view that allows the user to create or edit a task.
/// If the task is nil, it is a view for creating a new task.
/// If the task is not nil, it is a view for editing an existing task.
struct TaskFormView: View {
    let task: Task?    
    @State private var title: String
    @State private var category: TaskCategory
    @State private var trigger: String
    @State private var goal: String
    @State private var instructions: [String]
    @State private var minutes: Int
    @State private var anxietyLevel: Int8
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    init(task: Task? = nil) {
        self.task = task
        
        // Initialize state with either existing task values or defaults
        self._title = State(initialValue: task?.title ?? "")
        self._category = State(initialValue: task?.category ?? .contamination)
        self._trigger = State(initialValue: task?.trigger ?? "")
        self._goal = State(initialValue: task?.goal ?? "")
        self._instructions = State(initialValue: task?.instructions ?? [""])
        self._minutes = State(initialValue: task?.duration ?? 5)
        self._anxietyLevel = State(initialValue: task?.anxietyLevel ?? 3)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("BASIC INFORMATION") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("TASK DETAILS") {
                    TextField("Trigger/Concern", text: $trigger)
                    TextField("Goal", text: $goal)
                }
                
                Section("INSTRUCTIONS") {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        TextField("Step \(index + 1)", text: $instructions[index])
                    }
                    .onDelete { indexSet in
                        instructions.remove(atOffsets: indexSet)
                    }
                    Button("Add Step") {
                        instructions.append("")
                    }
                }
                
                Section("TIME") {
                    Stepper(value: $minutes, in: 1...60) {
                        HStack {
                            Text("\(minutes)")
                            Text("minutes")
                        }
                    }
                }
                
                Section("ANXIETY LEVEL") {
                    HStack {
                        ForEach(1...5, id: \.self) { level in
                            Button("\(level)") {
                                withAnimation(.spring(duration: 0.3)) {
                                    anxietyLevel = Int8(level)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(anxietyLevel == Int8(level) ? Color.accentColor : Color.clear)
                            )
                            .foregroundColor(anxietyLevel == Int8(level) ? .white : .primary)
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listRowSpacing(0) // Remove spacing inherited from TaskListView
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(task == nil ? "Save" : "Update") {
                        withAnimation(.easeOut) {
                            task == nil ? saveTask() : updateTask(task!)
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    /// Returns true if the form is valid, false otherwise.
    private var isFormValid: Bool {
        !title.isEmpty &&
        !trigger.isEmpty &&
        !goal.isEmpty &&
        instructions.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) &&
        minutes > 0
    }
    
    /// Saves a new task. Called when the user taps the "Save" button.
    private func saveTask() {
        let task = Task(
            title: title,
            category: category,
            trigger: trigger,
            goal: goal,
            instructions: instructions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                   .filter { !$0.isEmpty },
            duration: minutes,
            anxietyLevel: anxietyLevel,
            status: .available
        )
        
        taskManager.addTask(task)
    }
    
    /// Updates an existing task. Called when the user taps the "Update" button.
    private func updateTask(_ existingTask: Task) {
        let updatedTask = existingTask.updated(
            title: title,
            category: category,
            trigger: trigger,
            goal: goal,
            instructions: instructions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                   .filter { !$0.isEmpty },
            duration: minutes,
            anxietyLevel: anxietyLevel
        )
        
        taskManager.updateTask(updatedTask)
    }
} 
