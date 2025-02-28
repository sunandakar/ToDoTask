//
//  DemoTaskItemApp.swift
//  DemoTaskItem
//
//  Created by Sunanda Kar on 25/02/25.
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
