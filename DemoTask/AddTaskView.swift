import SwiftUI

struct AddTaskItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title: String = ""
    @State private var id: String = ""
    @State private var details: String = ""
    @State private var priority: String = "Medium"
    @State private var dueDate: Date = Date()

    let priorities = ["Low", "Medium", "High"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("TaskItem Details")) {
                    TextField("Title", text: $title)
                        .disableAutocorrection(true)
                    TextField("Description", text: $details)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Due Date")) {
                    DatePicker("Select a date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add TaskItem")
            .toolbar {
                Button("Save") {
                    addTaskItem()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func addTaskItem() {
        let newTaskItem = Item(context: viewContext)
        newTaskItem.title = title
        newTaskItem.id = id
        newTaskItem.details = details
        newTaskItem.priority = priority
        newTaskItem.dueDate = dueDate
        newTaskItem.isCompleted = false

        do {
            try viewContext.save()
        } catch {
            print("Error saving TaskItem: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return AddTaskItemView()
        .environment(\.managedObjectContext, context)
}
