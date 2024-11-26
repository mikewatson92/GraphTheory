//
//  Canvas.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

struct Canvas: View {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @ObservedObject var graph: Graph
    @State private var showWeights: Bool = false
    @State private var startVertex: Vertex?
    @State private var endVertex: Vertex?
    @State private var weight: Double?
    @State private var pickerAlgorithm: Graph.Algorithm = .none
    @State private var action: Int? = 0
    @State private var algorithms: [Graph.Algorithm] = Graph.Algorithm.allCases
    
    init(graph: Graph) {
        self.graph = graph
    }
    
    // Creates a vertex at the location the user clicks on the canvas
    public var placeVertexGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged {_ in
            }
            .onEnded {
                if !graph.changesLocked {
                    let x = CGFloat($0.location.x)
                    let y = CGFloat($0.location.y)
                    let point = CGPoint(x: x, y: y)
                    let newVertex = Vertex(position: point)
                    newVertex.label = graph.labels.sorted(by: < )[0]
                    graph.labels.removeAll(where: { $0 == newVertex.label })
                    graph.vertices.append(newVertex)
                }
            }
    }
    
    var canvas: some View {
        
        ZStack {
            Rectangle()
                .opacity(1)
                .foregroundColor(darkGray)
                .gesture(placeVertexGesture)
            
            // Draws all of the edges in the ModelData
            ForEach(graph.edges) { edge in
                EdgeView(edge: edge, showWeights: $showWeights, graph: graph)
                    .shadow(color: edge.isSelected ? Color.green : .clear, radius: 8)
            }
            
            // Draws all the vertices in the ModelData
            ForEach(graph.vertices) { vertex in
                VertexView(vertex: vertex, graph: graph)
                    .onTapGesture (count: 1){
                        let vertexGesture = VertexGesture(startVertex: $startVertex, endVertex: $endVertex, graph: graph, vertex: vertex)
                        vertexGesture.addEdgeGesture()
                    }
            }
        }
        .preferredColorScheme(.dark)

    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            canvas
            
            HStack {
                Toggle(isOn: $showWeights) {
                    Text("Weights")
                }
                .frame(maxWidth: 125)
                Spacer()
                Button("Clear") {
                    graph.edges = []
                    graph.vertices = []
                    graph.highlightedVertex = nil
                    graph.isMoving = false
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            graph.algorithm = .none
            graph.highlightedVertex = nil
            graph.changesLocked = false
            graph.weightChangeLocked = false
            for edge in graph.edges {
                edge.isSelected = false
                edge.status = .none
            }
            for vertex in graph.vertices {
                vertex.isSelected = false
            }
        }
        .navigationTitle("Canvas")
        .toolbar { Toolbars(graph: graph) }
        .preferredColorScheme(.dark)
    }
}
    
    
    
    struct Canvas_Previews: PreviewProvider {
        static var previews: some View {
            Canvas(graph: Graph())
        }
    }
