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
   
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .modelContainer(for: Theme.self)
                .environmentObject(themeViewModel)
                .accentColor(themeViewModel.theme!.accent)
        }
    }
}
