import SwiftUI
import Charts

/// TaskInsightsView is a view that displays insights about the user's ERP task completions.
struct TaskInsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    /// Returns the current streak of task completions.
    private var currentStreak: Int {
        let calendar = Calendar.current
        let completionDays = Set(
            taskManager.tasks
                .flatMap { $0.completions }
                .map { calendar.startOfDay(for: $0) }
        )
        guard let mostRecentDay = completionDays.max() else {
            return 0
        }
        
        var streak = 0
        var dayCursor = mostRecentDay
        
        while completionDays.contains(dayCursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
            dayCursor = previousDay
        }
        
        return streak
    }
    
    /// Returns the most common category of task completions.
    private var mostCommonCategory: String {
        let categoryCount = taskManager.tasks.reduce(into: [:]) { counts, task in
            counts[task.category, default: 0] += task.completions.count
        }
        
        // Return "None" if no completions exist
        guard let maxCount = categoryCount.values.max(), maxCount > 0 else { return "None" }
        
        // Get all categories with this count and return first alphabetically
        return categoryCount.filter { $0.value == maxCount }
                          .map { $0.key.rawValue }
                          .sorted()
                          .first ?? "None"
    }
    
    /// Returns the total number of tasks completed.
    private var totalTasksCompleted: Int {
        taskManager.tasks.reduce(0) { $0 + $1.completions.count }
    }
    
    /// Returns the number of tasks completed this week.
    private var tasksThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return taskManager.tasks.reduce(0) { count, task in
            count + task.completions.filter { $0 >= weekStart }.count
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text("Insights")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                // Cards Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    InsightCard(title: "Current Streak",
                                value: "\(currentStreak) days",
                                icon: "flame.fill")
                    
                    InsightCard(title: "Top Category",
                                value: mostCommonCategory,
                                icon: "tag.fill")
                    
                    InsightCard(title: "Total Tasks Done",
                                value: "\(totalTasksCompleted)",
                                icon: "checkmark.circle.fill")
                    
                    InsightCard(title: "This Week",
                                value: "\(tasksThisWeek)",
                                icon: "calendar")
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

/// InsightCard is a view that displays an insight about the user's ERP task completions.
struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .bold()
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
