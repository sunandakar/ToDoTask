//
//  DemoTaskItemApp.swift
//  DemoTaskItem
//
//

import SwiftUI

@main
struct DemoTaskItemApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var themeManager = ThemeManager() // Create ThemeManager instance


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
    }
}
