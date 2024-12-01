//
//  ContentView.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/27/24.
//

import SwiftUI

struct ContentView: View {
    let k33 = K33()
    @StateObject var graphViewModel = GraphViewModel(graph: Graph())
    let clebschGraphView = GraphView(graphViewModel: GraphViewModel(graph: ClebschGraphCompleteColoring().graph))
    let petersonGraphView = GraphView(graphViewModel: GraphViewModel(graph: PetersonGraph().graph))
    let complexPolygonView = GraphView(graphViewModel: GraphViewModel(graph: ComplexPolygon().graph))
    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Create")) {
                    NavigationLink("Canvas", destination: Canvas(graphViewModel: graphViewModel))
                }
                Section(header: Text("Sample Graphs")) {
                    NavigationLink("Clebsch Graph Complete Coloring", destination: clebschGraphView)
                    NavigationLink("Peterson Graph", destination: petersonGraphView)
                    NavigationLink("Complex Polygon", destination: complexPolygonView)
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

