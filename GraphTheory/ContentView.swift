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
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                }
                Section(header: Text("Create")) {
                    NavigationLink("Graph", destination: Canvas(graphViewModel: canvasGraphViewModel))
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    NavigationLink("Matrix", destination: Matrix2DView(matrixViewModel: matrixViewModel))
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                }
                Section(header: Text("Textbook")) {
                    NavigationLink("Konigsberg", destination: KonigsbergView())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: ClebschGraphCompleteColoringView())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                        
                    NavigationLink("Peterson Graph", destination: PetersonView())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    
                    NavigationLink("Complex Polygon", destination: ComplexPolygonView())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    
                }
                Section(header: Text("Games")) {
                    NavigationLink("Icosian Game", destination: IcosianView())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                }
                Section(header: Text("Practice")) {
                    NavigationLink("Kruskal's Algorithm", destination: Kruskal1View())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    NavigationLink("Prim's Table Algorithm", destination: Prim1View())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    NavigationLink("Chinese Postman Problem", destination: ChinesePostman1View())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    NavigationLink("Classical Travelling Salesman Problem", destination: ClassicalTSP1View())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                    NavigationLink("Practical Travelling Salesman Problem", destination: PracticalTSP1View())
                        .foregroundStyle(themeViewModel.theme!.secondaryColor)
                }
            }
            .foregroundStyle(themeViewModel.theme!.primaryColor)
            .accentColor(themeViewModel.theme!.accentColor)
            .environmentObject(themeViewModel)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Picker("Theme", selection: Binding(get: {themeViewModel.theme}, set: {newTheme in themeViewModel.theme = newTheme})) {
                            Text("Natural")
                                .tag(DefaultThemes.natural)
                            Text("Default Light Mode")
                                .tag(DefaultThemes.defaultLight)
                            Text("Default Dark Mode")
                                .tag(DefaultThemes.defaultDark)
                            Text("Cyber Punk Light")
                                .tag(DefaultThemes.cyberPunkLight)
                            Text("Cyber Punk Dark")
                                .tag(DefaultThemes.cyberPunkDark)
                        }
                    } label: {
                        Label("Theme", systemImage: "sparkles")
                            .tint(themeViewModel.theme!.accentColor)
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
