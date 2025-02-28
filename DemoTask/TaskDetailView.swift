import SwiftUI

struct TaskItemDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var TaskItem: Item

    var body: some View {
        VStack(spacing: 20) {
            Text(TaskItem.title ?? "No Title")
                .font(.largeTitle)
                .padding()

            Text(TaskItem.details ?? "No description provided")
                .padding()

            Text("Priority: \(TaskItem.priority ?? "Low")")
                .padding()

            Text("Due Date: \(TaskItem.dueDate ?? Date(), style: .date)")
                .padding()

            Button(action: {
                TaskItem.isCompleted.toggle()
                saveContext()
            }) {
                Text(TaskItem.isCompleted ? "Mark as Pending" : "Mark as Completed")
                    .padding()
                    .background(TaskItem.isCompleted ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                viewContext.delete(TaskItem)
                saveContext()
            }) {
                Text("Delete TaskItem")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("TaskItem Details")
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving TaskItem: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let TaskItem = Item(context: context)
    TaskItem.title = "Sample TaskItem"
    TaskItem.details = "Detailed description of the TaskItem."
    TaskItem.priority = "Medium"
    TaskItem.dueDate = Date()
    TaskItem.isCompleted = false

    return NavigationView {
        TaskItemDetailView(TaskItem: TaskItem)
            .environment(\.managedObjectContext, context)
    }
}
