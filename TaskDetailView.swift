import SwiftUI

/// TaskDetailView is a view that displays the details of an ERP task.
/// It also has a button to start the task.
struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss
    @State private var showingTimerView = false
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Metadata Row
                HStack {
                    // Duration
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Text("\(task.duration) min")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    // Category
                    HStack(spacing: 6) {
                        Image(systemName: "tag")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Text(task.category.rawValue)
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    // Anxiety Level
                    HStack(spacing: 6) {
                        Image(systemName: gaugeIcon)
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Text("\(task.anxietyLevel) / 5")
                            .font(.body)
                    }
                    .padding(.trailing, 12)
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Trigger
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trigger")
                                .font(.headline)
                            Text(task.trigger)
                                .font(.body)
                        }
                        
                        // Goal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal")
                                .font(.headline)
                            Text(task.goal)
                                .font(.body)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            ForEach(Array(task.instructions.enumerated()), id: \.element) { index, instruction in
                                Text("\(index + 1). \(instruction)")
                                    .font(.body)
                            }
                        }
                        
                        // Latest Completions
                        if !task.completions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Latest Completions")
                                    .font(.headline)
                                ForEach(Array(task.completions.prefix(3).enumerated()), id: \.element) { _, date in
                                    HStack {
                                        Text("●")
                                            .font(.system(size: 8))
                                        Text(date.formatted(date: .long, time: .shortened))
                                            .font(.body)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
                .modifier(FadingScrollMask())
                
                // Start Task Button
                Button {
                    showingTimerView = true
                } label: {
                    Text("Start Task")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle(task.title)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showingTimerView) {
                OngoingTaskView(task: task.updated(status: .ongoing))
                    .environmentObject(taskManager)
            }
        }
    }
    
    /// Returns the icon for the anxiety level.
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

/// FadingScrollMask is a view modifier that adds a fading effect to the scroll view.
struct FadingScrollMask: ViewModifier {
    func body(content: Content) -> some View {
        content
            .mask(
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    
                    Rectangle().fill(Color.white)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 50)
                }
            )
    }
}
