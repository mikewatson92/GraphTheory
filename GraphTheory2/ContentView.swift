//
//  ContentView.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/27/24.
//

import SwiftUI

struct ContentView: View {
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
        } detail: {
            NavigationStack {
                Canvas(graphViewModel: canvasGraphViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}

