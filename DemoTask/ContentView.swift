//
//  ContentView.swift
//  DemoTaskItem
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSettings = false // Controls settings modal
    @State private var recentlyCompletedTask: Item?
    @State private var showUndoSnackbar = false
    @State private var isPulsing = false
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.dueDate, ascending: true)],
//        animation: .default)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.order, ascending: true)],
        animation: .default
    )
    private var TaskItems: FetchedResults<Item>
    // 🏆 Total, Completed, and Pending Counts
        var totalTasks: Int {
            TaskItems.count
        }

        var completedTasks: Int {
            TaskItems.filter { $0.isCompleted }.count
        }

        var pendingTasks: Int {
            totalTasks - completedTasks
        }

        // 🟢 Progress Calculation
        var progress: Double {
            switch filterStatus {
            case "Completed":
                return completedTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)
            case "Pending":
                return totalTasks == 0 ? 0 : Double(pendingTasks) / Double(totalTasks)
            default:
                return 0 // Hide progress view when "All" is selected
            }
        }
    var progressColor: Color {
            switch filterStatus {
            case "Completed":
                return .green
            case "Pending":
                return .orange
            default:
                return .blue
            }
        }
    @AppStorage("accentColor") private var accentColor: String = "blue"
    

    @State private var sortOption: String = "Priority"
    @State private var filterStatus: String = "All"

    var sortedTaskItems: [Item] {
        switch sortOption {
        case "Due Date":
            return TaskItems.sorted { $0.dueDate ?? Date() < $1.dueDate ?? Date() }
        case "Alphabetical":
            return TaskItems.sorted { $0.title ?? "" < $1.title ?? "" }
        default:
            return TaskItems.sorted { $0.priority ?? "Low" < $1.priority ?? "Low" }
        }
    }

    var filteredTaskItems: [Item] {
        switch filterStatus {
        case "Completed":
            return sortedTaskItems.filter { $0.isCompleted }
        case "Pending":
            return sortedTaskItems.filter { !$0.isCompleted }
        default:
            return sortedTaskItems
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                
                // Sorting Options
                Picker("Sort By", selection: $sortOption) {
                    Text("Priority").tag("Priority")
                    Text("Due Date").tag("Due Date")
                    Text("Alphabetical").tag("Alphabetical")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Filtering Options
                Picker("Filter", selection: $filterStatus) {
                    Text("All").tag("All")
                    Text("Completed").tag("Completed")
                    Text("Pending").tag("Pending")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if filteredTaskItems.isEmpty {
                    
                    Spacer()
                    EmptyStateView()
                    Spacer()
                    
                } else {
                    
                    //Progress Indicator at the Top
                    if filterStatus != "All" {
                        HStack {
                            //Spacer()
                            CircularProgressView(progress: progress, color: progressColor)
                            VStack(alignment: .leading) {
                                Text(filterStatus)
                                    .font(.title3)
                                    .bold()
                                Text("\(filteredTaskItems.count) Tasks")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.all)
                    }
                    //.padding(.vertical)
                
                    
                    List {
                        ForEach(filteredTaskItems) { task in
                            NavigationLink(destination: TaskItemDetailView(TaskItem: task)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)))
                            {
                                TaskRowView(TaskItem: task)
                            }
                            .swipeActions(edge: .trailing) {
                                // Swipe to Mark as Completed
                                Button {
                                    withAnimation {
                                        toggleTaskCompletion(task)
                                    }
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                                
                                // Swipe to Delete
                                Button(role: .destructive) {
                                    withAnimation {
                                        deleteTask(task)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                        .onMove(perform: moveTask)
                        .onDelete(perform: deleteTaskItem)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .alert("Task Completed", isPresented: $showUndoSnackbar, actions: {
                Button("Undo") {
                    if let task = recentlyCompletedTask {
                        task.isCompleted.toggle()
                        saveContext()
                    }
                }
                Button("OK", role: .cancel) { }
            })
            .navigationTitle("Task Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink(destination: AddTaskItemView()) {
                        Label("Add TaskItem", systemImage: "plus")
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2).repeatCount(1, autoreverses: true), value: isPulsing)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isPulsing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isPulsing = false
                        }
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    
    private func toggleTaskCompletion(_ task: Item) {
        withAnimation {
            task.isCompleted.toggle() // Toggle completion state
            recentlyCompletedTask = task
            showUndoSnackbar = true
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to update task completion: \(error)")
            }
        }
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        withAnimation {
            var reorderedTasks = filteredTaskItems
            reorderedTasks.move(fromOffsets: source, toOffset: destination)

            // Update Core Data order based on the new array order
            for (index, task) in reorderedTasks.enumerated() {
                task.order = Int16(index) // Assuming "order" is an Int16 attribute in Core Data
            }

            do {
                try viewContext.save()

                // Haptic feedback for successful reorder
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.impactOccurred()

            } catch {
                print("Failed to update task order: \(error)")
            }
        }
    }

    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    func deleteTask(_ task: Item) {
        withAnimation {
            viewContext.delete(task)
            saveContext()
        }
    }
    
    // Delete TaskItem
    private func deleteTaskItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTaskItems[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Error deleting TaskItem: \(error)")
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return ContentView().environment(\.managedObjectContext, context)
}

