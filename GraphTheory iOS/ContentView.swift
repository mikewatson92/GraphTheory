//
//  ContentView.swift
//  GraphTheory iOS
//
//  Created by Mike Watson on 12/1/24.
//

import SwiftUI

struct ContentView: View {
    let k33 = K33()
    @StateObject var graphViewModel = GraphViewModel(graph: Graph())
    let clebschGraphView = GraphView(graphViewModel: GraphViewModel(graph: ClebschGraphCompleteColoring().graph))
    let petersonGraphView = GraphView(graphViewModel: GraphViewModel(graph: PetersonGraph().graph))
    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Create")) {
                    NavigationLink("Canvas", destination: Canvas(graphViewModel: graphViewModel))
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: clebschGraphView)
                    NavigationLink("Peterson Graph", destination: petersonGraphView)
                }
                Section(header: Text("Games")) {
                    NavigationLink("Icosian Game", destination: IcosianView())
                }
            }
        } detail: {
            NavigationStack {
                Canvas(graphViewModel: graphViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
