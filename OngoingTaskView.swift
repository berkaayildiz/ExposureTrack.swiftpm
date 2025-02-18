import SwiftUI

/// OngoingTaskView is a view that is displayed when a user has started a task.
/// It displays the task's title, goal, and a timer that counts down the remaining time.
/// It also has a button to complete the task earlier and a button to cancel the task.
struct OngoingTaskView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @State private var startTime = Date()
    @State private var timerEnded = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Timer Display
                VStack(spacing: 8) {
                    TimelineView(.animation(minimumInterval: 1.0)) { timeline in
                        let remainingSeconds = max(0, task.duration * 60 - Int(timeline.date.timeIntervalSince(startTime)))
                        timerEnded = remainingSeconds == 0
                        return Text(timeString(for: timeline.date))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                    Text("remaining")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 96)
                
                // Task Info
                VStack(spacing: 16) {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(task.goal)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 36)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 16) {
                    Button(action: completeTask) {
                        Text(timerEnded ? "Done" : "Mark as Completed")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    if !timerEnded {
                        Button(action: cancelTask) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.bottom, 32)
                .padding(.horizontal)
            }
        }
    }
    
    // Returns a string that displays the remaining time in minutes and seconds
    private func timeString(for currentDate: Date) -> String {
        let elapsedSeconds = Int(currentDate.timeIntervalSince(startTime))
        let remainingSeconds = max(0, task.duration * 60 - elapsedSeconds)
        
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Marks the task as completed
    private func completeTask() {
        taskManager.markTaskCompleted(task)
        dismiss()
    }
    
    // Cancels the task
    private func cancelTask() {
        let updatedTask = task.updated(status: .available)
        taskManager.updateTask(updatedTask)
        dismiss()
    }
}
