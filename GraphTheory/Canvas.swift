//
//  Canvas.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct Canvas: View {
    //@Environment(\.modelContext) private var modelContext
    @ObservedObject var graphViewModel: GraphViewModel
    //@State private var isLoadViewVisible = false // State to control visibility
    @State private var algorithm: Algorithm = .none
    
    enum Algorithm: String, CaseIterable, Identifiable {
        case none = "No Algorithm"
        case kruskal = "Kruskal"
        var id: String { self.rawValue }
    }
    
    /*
    private func saveGraph() {
        modelContext.insert(graphViewModel.getGraph())
        try? modelContext.save()
    }
     */
    
    var body: some View {
        
        GeometryReader { geometry in
            if algorithm == .none {
                ZStack {
                    // Background to detect taps
                    Color.clear
                        .contentShape(Rectangle()) // Ensures the tap area spans the entire view
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { tapLocation in
                                    if graphViewModel.mode == .edit {
                                        // Add a vertex at the tap location
                                        let normalizedLocation = CGPoint(
                                            x: tapLocation.location.x / geometry.size.width,
                                            y: tapLocation.location.y / geometry.size.height
                                        )
                                        let newVertex = Vertex(position: normalizedLocation)
                                        graphViewModel.addVertex(newVertex)
                                    }
                                }
                        )
                    
                    // Render the graph
                    GraphView(graphViewModel: graphViewModel)
                }
            } else if algorithm == .kruskal {
                KruskalView(graph: graphViewModel.getGraph())
            }
        }
        /*
        .sheet(isPresented: $isLoadViewVisible) {
            LoadView(isVisible: $isLoadViewVisible) // Pass binding to manage visibility
        }
         */
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                /*
                Button("Save") {
                    saveGraph()
                }
                
                Button("Load") {
                 isLoadViewVisible = true
                 }
                 */
                Text("Algorithm:")
                Picker("Algorithm", selection: $algorithm) {
                    ForEach(Algorithm.allCases, id: \.self) { alg in
                        Text(alg.rawValue).tag(alg)
                    }
                }
                if algorithm == .none {
                    Toggle("Weights", isOn: $graphViewModel.showWeights)
                }
            }
        }
    }
}

#Preview {
    let graphViewModel = GraphViewModel(graph: Graph())
    Canvas(graphViewModel: graphViewModel)
}
