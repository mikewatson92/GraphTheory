//
//  ContentView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var canvasGraphViewModel = GraphViewModel(graph: Graph(), showAlgorithms: true)

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Create")) {
                    NavigationLink("Canvas", destination: Canvas(graphViewModel: canvasGraphViewModel))
                        .foregroundStyle(themeViewModel.colorTheme2)
                        .environmentObject(themeViewModel)
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: ClebschGraphCompleteColoringView())
                        .foregroundStyle(themeViewModel.colorTheme2)
                        
                    NavigationLink("Peterson Graph", destination: PetersonView())
                        .foregroundStyle(themeViewModel.colorTheme2)
                    
                    NavigationLink("Complex Polygon", destination: ComplexPolygonView())
                        .foregroundStyle(themeViewModel.colorTheme2)
                    
                }
                Section(header: Text("Games")) {
                    NavigationLink("Icosian Game", destination: IcosianView())
                        .foregroundStyle(themeViewModel.colorTheme2)
                }
            }
            .foregroundStyle(themeViewModel.colorTheme1)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Picker("Theme", selection: Binding(get: {themeViewModel.theme}, set: {newTheme in themeViewModel.theme = newTheme})) {
                            ForEach(ThemeViewModel.Theme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                                    .foregroundColor(themeViewModel.accentColor)
                            }
                        }
                        
                    } label: {
                        Label("Theme", systemImage: "sparkles")
                            .tint(themeViewModel.accentColor)
                    }
                }
            }
        } detail: {
            NavigationStack {
                Canvas(graphViewModel: canvasGraphViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(ThemeViewModel())
}
