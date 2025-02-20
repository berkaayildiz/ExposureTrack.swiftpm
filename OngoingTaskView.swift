import SwiftUI
import Combine

/// OngoingTaskView is a view that is displayed when a user has started a task.
/// It displays the task's title, goal, and a timer that counts down the remaining time.
/// It also has a button to complete the task earlier and a button to cancel the task.
struct OngoingTaskView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @StateObject private var viewModel: OngoingTaskViewModel

    init(task: Task) {
        _viewModel = StateObject(wrappedValue: OngoingTaskViewModel(taskDuration: task.duration))
        self.task = task
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Timer Display
                VStack(spacing: 8) {
                    Text(timeString(for: viewModel.remainingSeconds))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()

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
                        Text(viewModel.timerEnded ? "Done" : "Mark as Completed")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }

                    if !viewModel.timerEnded {
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
        .onAppear { viewModel.startTimer() }
        .onDisappear { viewModel.stopTimer() }
    }

    private func timeString(for seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func completeTask() {
        taskManager.markTaskCompleted(task)
        dismiss()
    }

    private func cancelTask() {
        let updatedTask = task.updated(status: .available)
        taskManager.updateTask(updatedTask)
        dismiss()
    }
}

/// OngoingTaskViewModel is a view model that is used to manage the ongoing task view.
/// It contains the logic for the timer and the buttons.
class OngoingTaskViewModel: ObservableObject {
    @Published var remainingSeconds: Int
    @Published var timerEnded = false
    private var cancellable: AnyCancellable?

    init(taskDuration: Int) {
        self.remainingSeconds = taskDuration * 60
    }

    func startTimer() {
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.timerEnded = true
                    self.cancellable?.cancel()
                }
            }
    }

    func stopTimer() {
        cancellable?.cancel()
    }
}
