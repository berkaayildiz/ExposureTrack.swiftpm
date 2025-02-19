import SwiftUI

@available(iOS 17, *)
@main
struct ExposureTrackApp: App {
    @StateObject private var taskManager = TaskManager()
    
    var body: some Scene {
        WindowGroup {
            TaskListView(isArchiveView: false)
                .environmentObject(taskManager)
        }
    }
}
