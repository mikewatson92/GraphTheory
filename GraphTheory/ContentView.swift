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
    @StateObject private var canvasGraphViewModel = GraphViewModel(graph: Graph())
    @StateObject private var matrixViewModel = Matrix2DViewModel(matrix: Matrix2D(numberOfItems: 3))

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Learn")) {
                    NavigationLink("Tutorial", destination: TutorialView())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                }
                Section(header: Text("Create")) {
                    NavigationLink("Graph", destination: Canvas(graphViewModel: canvasGraphViewModel))
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Matrix", destination: Matrix2DView(matrixViewModel: matrixViewModel))
                        .foregroundStyle(themeViewModel.theme!.secondary)
                }
                Section(header: Text("Textbook")) {
                    NavigationLink("Introduction", destination: Intro())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Overview", destination: Overview())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Terminology", destination: Terminology())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Undirected Graphs", destination: UndirectedGraph())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Directed Graphs", destination: DirectedGraph())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: ClebschGraphCompleteColoringView())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                        
                    NavigationLink("Peterson Graph", destination: PetersonView())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    
                    NavigationLink("Complex Polygon", destination: ComplexPolygonView())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    
                }
                Section(header: Text("Games")) {
                    NavigationLink("Icosian Game", destination: IcosianView())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Uncross the Edges", destination: PlanarGraph1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                }
                Section(header: Text("Practice")) {
                    NavigationLink("Kruskal's Algorithm", destination: Kruskal1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Prim's Table Algorithm", destination: Prim1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Chinese Postman Problem", destination: ChinesePostman1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Classical Travelling Salesman Problem", destination: ClassicalTSP1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                    NavigationLink("Practical Travelling Salesman Problem", destination: PracticalTSP1View())
                        .foregroundStyle(themeViewModel.theme!.secondary)
                }
            }
            .foregroundStyle(themeViewModel.theme!.primary)
            .accentColor(themeViewModel.theme!.accent)
            .environmentObject(themeViewModel)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: ThemeSelector()) {
                        Label("Theme", systemImage: "sparkles")
                            .tint(themeViewModel.theme!.accent)
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
        .modelContainer(for: Theme.self, inMemory: true)
        .environmentObject(ThemeViewModel())
}
