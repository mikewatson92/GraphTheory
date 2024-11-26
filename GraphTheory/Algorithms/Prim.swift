//
//  Prim.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class Prim: ObservableObject {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @Published var finished: Bool = false
    var graph: Graph
    var numVertices: Int
    var numEdges: Int
    var availableEdges: [Edge] // The edges not chosen yet
    var chosenEdges: [Edge] = [] // Edges selected by user
    var connectedVertices: [Vertex] = [] // An array of the
    // vertices connected by the subgraph
    var startPhase: Bool = true
    var error: PrimError = .none
    
    enum PrimError: Error {
        case cycle, notLowestWeight, notConnected, none
    }
    
    init(graph: Graph) {
        self.graph = graph
        self.numVertices = graph.vertices.count
        self.numEdges = graph.edges.count
        self.availableEdges = graph.edges.sorted(by: { $0.weight < $1.weight })
        self.graph.algorithm = .prim
        self.graph.changesLocked = true
        self.graph.weightChangeLocked = true
    }
    
    // Determine if a newEdge's weight has the lowest weight of all available edges. There may be multiple edges with the lowest weight.
    func lowestWeight(newEdge: Edge) -> Bool {
        return newEdge.weight == availableEdges.sorted(by: { $0.weight < $1.weight })[0].weight
        
    }
    
    // Returns true if a new edge is connected to a vertex of an existing tree. Otherwise, returns false.
    func isConnected(newEdge: Edge) -> Bool {
        var connectedVertexIDs: [UUID] = []
        for vertex in connectedVertices {
            connectedVertexIDs.append(vertex.id)
        }
        if connectedVertexIDs.contains(newEdge.startVertex.id) {
            return true
        } else if connectedVertexIDs.contains(newEdge.endVertex.id) {
            return true
        }
        return false
    }
    
    func formsCycle(newEdge: Edge) -> Bool {
        let newGraph = Graph()
        newGraph.vertices = graph.vertices
        newGraph.edges = chosenEdges
        newGraph.edges.append(newEdge)
        return newGraph.hasCycle()
    }
    
    func edgeIsValid(newEdge: Edge) -> Bool {
        if !lowestWeight(newEdge: newEdge) {
            error = .notLowestWeight
            return false
        }
        if !isConnected(newEdge: newEdge) {
            error = .notConnected
            return false
        }
        if formsCycle(newEdge: newEdge) {
            error = .cycle
            return false
        }
        // Return true if newEdge is the lowest weight,
        // is connected to the subgraph, and doesn't
        // form a cycle.
        return true
    }
    
    // Add a new vertex to the array connectedVertices
    // based on a new vertex introduced by forEdge.
    func addVertex(forEdge edge: Edge) {
        // Add all connectedVertices vertex ID's to an array
        var connectedVertexIDs: [UUID] = []
        for vertex in connectedVertices {
            connectedVertexIDs.append(vertex.id)
        }
        
        // Add the new vertex to connectedVertices
        if !connectedVertexIDs.contains(edge.startVertex.id) {
            connectedVertices.append(edge.startVertex)
        } else if !connectedVertexIDs.contains(edge.endVertex.id) {
            connectedVertices.append(edge.endVertex)
        }
    }
    
    func checkIfFinished () {
        let finished = chosenEdges.count == graph.vertices.count - 1
        self.finished = finished
    }
    
    func reset() {
        chosenEdges = []
        availableEdges = graph.edges
        error = .none
        finished = false
        graph.highlightedVertex = nil
        connectedVertices = []
        startPhase = true
        for edge in graph.edges {
            edge.isSelected = false
            edge.status = .none
        }
        for vertex in graph.vertices {
            vertex.isSelected = false
        }
    }
}

struct PrimView: View {
    @ObservedObject var graph: Graph
    @StateObject var prim: Prim
    
    init(graph: Graph) {
        self.graph = graph
        _prim = .init(wrappedValue: Prim(graph: graph))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading){
            if prim.finished {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(blueGradient)
            } else {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundColor(darkGray)
            }
            
            HStack {
                Spacer()
                Button("Clear") {
                    prim.reset()
                }
                .padding()
            }
            
            ForEach(graph.edges) { edge in
                EdgeView(edge: edge, showWeights: .constant(true), graph: graph)
                    .onTapGesture(count: 1) {
                        guard !prim.finished else { return }
                        let validEdge = prim.edgeIsValid(newEdge: edge)
                        if validEdge {
                            edge.status = .correct
                            edge.isSelected = true
                            prim.chosenEdges.append(edge)
                            prim.addVertex(forEdge: edge)
                            prim.checkIfFinished()
                        } else if edge.status != .none {
                            edge.status = .none
                            edge.isSelected = false
                            prim.error = .none
                        } else {
                            edge.status = .error
                            edge.isSelected = true
                        }
                    }
            }
            
            
            ForEach(graph.vertices) { vertex in
                VertexView(vertex: vertex, graph: graph)
                    .onTapGesture(count: 1) {
                        if prim.startPhase {
                            prim.startPhase = false
                            graph.highlightedVertex = vertex
                            prim.connectedVertices.append(vertex)
                        }
                    }
            }
        }
        .onDisappear {
            prim.reset()
            graph.algorithm = .none
            graph.changesLocked = false
            graph.weightChangeLocked = false
        }
        .navigationTitle("Prim's Algorithm")
    }
}

struct PrimView_Previews: PreviewProvider {
    static var previews: some View {
        PrimView(graph: Graph())
    }
}
