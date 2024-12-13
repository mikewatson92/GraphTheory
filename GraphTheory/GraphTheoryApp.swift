//
//  GraphTheoryApp.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
import SwiftData

@main
struct GraphTheoryApp: App {
    @StateObject private var themeViewModel = ThemeViewModel()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
   
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(themeViewModel)
                .accentColor(themeViewModel.accentColor)
        }
        .modelContainer(sharedModelContainer)
    }
}
