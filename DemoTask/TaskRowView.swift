import SwiftUI

struct TaskRowView: View {
    let TaskItem: Item
    @AppStorage("accentColor") private var accentColor: String = "blue" // Default to blue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(TaskItem.title ?? "Untitled Task")
                    .font(.headline)
                    .foregroundColor(Color.primary) // Adapts to light/dark mode
                
                Text(TaskItem.details ?? "No description available")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                
                HStack {
                    Text("Priority: \(TaskItem.priority ?? "Low")")
                        .font(.caption)
                        .bold()
                        .foregroundColor(priorityColor(priority: TaskItem.priority))
                    
                    Spacer()
                    
                    Text(TaskItem.dueDate ?? Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Image(systemName: TaskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(Color(accentColor)) // Uses user-selected accent color
                .onTapGesture {
                    toggleCompletion()
                }
        }
        .padding(.vertical, 5)
    }
    
    private func priorityColor(priority: String?) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .gray
        }
    }
    
    private func toggleCompletion() {
        TaskItem.isCompleted.toggle()
        do {
            try TaskItem.managedObjectContext?.save()
        } catch {
            print("Failed to save task completion status: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Item(context: context)
    task.title = "Sample Task"
    task.details = "This is a sample description."
    task.priority = "High"
    task.dueDate = Date()
    task.isCompleted = false

    return TaskRowView(TaskItem: task)
        .previewLayout(.sizeThatFits)
}
