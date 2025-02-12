import SwiftUI

/// TaskListView is a view that displays a list of tasks in a card format.
/// If the isArchiveView is true, it displays a list of archived tasks.
/// Otherwise, it displays a list of available tasks.
@available(iOS 17, *)
struct TaskListView: View {
    @State private var sortOrder: TaskSortOrder = .title
    let isArchiveView: Bool
    
    @EnvironmentObject var taskManager: TaskManager
    
    var tasks: [Task] {
        withAnimation(.easeInOut(duration: 0.3)) {
            taskManager.tasks(with: isArchiveView ? .archived : .available, sortedBy: sortOrder)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if !isArchiveView {
                    // Title and Menu Row
                    HStack {
                        Text("Tasks")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        TaskListMenu(
                            sortOrder: $sortOrder,
                            showingNewTaskSheet: $showingNewTaskSheet,
                            showingInsightsSheet: $showingInsightsSheet
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                // Task List Content
                TaskListContent(tasks: tasks)
            }
            .navigationTitle(isArchiveView ? "Archived Tasks" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isArchiveView {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach([TaskSortOrder.title, .category, .anxietyLevel], id: \.self) { option in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        sortOrder = option
                                    }
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOrder == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
            }
        }
    }
}

/// TaskCard is a view that displays a task in a card format.
struct TaskCard: View {
    let task: Task
    @State private var showingTaskDetail = false
    @State private var showingEditSheet = false
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title
            Text(task.title)
                .font(.system(size: 17, weight: .bold))
                .lineLimit(1)
            
            // Subtitle (Goal)
            Text(task.goal)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Divider()
                .padding(0)
            
            // Bottom row
            HStack {
                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(task.duration) minutes")
                }
                
                Spacer()
                
                // Category
                HStack(spacing: 4) {
                    Image(systemName: "tag")
                    Text(task.category.rawValue)
                }
                
                Spacer()
                
                // Anxiety Level
                HStack(spacing: 4) {
                    Image(systemName: gaugeIcon)
                    Text("\(task.anxietyLevel) / 5")
                }
                .padding(.trailing, 6)
            }
            .font(.system(size: 12))
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            showingTaskDetail = true
        }
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            // Archive
            Button {
                withAnimation(.easeOut) {
                    taskManager.archiveTask(task)
                }
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            
            Divider()
            
            // Delete
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation(.easeOut) {
                    taskManager.deleteTask(task)
                }
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
        .sheet(isPresented: $showingTaskDetail) {
            TaskDetailView(task: task)
        }
        .sheet(isPresented: $showingEditSheet) {
            TaskFormView(task: task)
                .environmentObject(taskManager)
        }
    }
    
    /// Returns the appropriate gauge icon depending on anxiety level
    private var gaugeIcon: String {
        if task.anxietyLevel < 3 {
            return "gauge.low"
        } else if task.anxietyLevel == 3 {
            return "gauge.medium"
        } else {
            return "gauge.high"
        }
    }
}

/// TaskListContent is a view that displays a list of tasks in a card format.
/// It is displayed in the center of the available tasks view.
@available(iOS 17.0, *)
struct TaskListContent: View {
    let tasks: [Task]
    
    var body: some View {
        List(tasks) { task in
            TaskCard(task: task)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
        .listRowSpacing(16)
        .scrollIndicators(.hidden)
        .contentMargins(.top, 24, for: .scrollContent)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .mask(
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 30)
                
                Rectangle()
                    .fill(.black)
                    .frame(maxHeight: .infinity)
                
                LinearGradient(
                    gradient: Gradient(colors: [.black, .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
            }
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
