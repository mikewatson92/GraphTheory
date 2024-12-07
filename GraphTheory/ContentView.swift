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
    @StateObject private var canvasGraphViewModel = GraphViewModel(graph: Graph())

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Create")) {
                    NavigationLink("Canvas", destination: Canvas(graphViewModel: canvasGraphViewModel))
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: ClebschGraphCompleteColoringView())
                        
                    NavigationLink("Peterson Graph", destination: PetersonView())
                  
                    NavigationLink("Complex Polygon", destination: ComplexPolygonView())
                        
                }
                Section(header: Text("Games")) {
                    NavigationLink("Icosian Game", destination: IcosianView())
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
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
}
