//
//  Kruskal.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class Kruskal: ObservableObject {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @Published var finished: Bool = false
    @Published var error: KruskalError = .none
    var graph: Graph
    lazy var numVertices: Int = graph.vertices.count
    lazy var numEdges: Int = graph.edges.count
    lazy var availableEdges: [Edge] = graph.edges.sorted(by: { $0.weight < $1.weight })
    var chosenEdges: [Edge] = []
    var loopEdges: [Edge] = []
    
    init(graph: Graph) {
        self.graph = graph
        self.graph.algorithm = .kruskal
        self.graph.changesLocked = true
        self.graph.weightChangeLocked = true
    }
    
    enum KruskalError: Error {
        case cycle, notLowestWeight, none
    }
    
    // Determines whether the graph consisting of the edges selected by the user, chosenEdges, contains a cycle.
    func containsCycle() -> Bool {
        let newGraph = Graph()
        newGraph.vertices.append(contentsOf: graph.vertices)
        newGraph.edges.append(contentsOf: chosenEdges)
        let result = newGraph.hasCycle()
        if result == true {
            return true
        }
        return false
        
    }
    
    
    // Determine if a newEdge's weight has the lowest weight of all available edges. There may be multiple edges with the lowest weight.
    func lowestWeight(newEdge: Edge) -> Bool {
        guard availableEdges.count > 0 else { return true }
        return (newEdge.weight == availableEdges[0].weight)
    }
    
    // Based on the current edges selected by the user, determine if there any single additional edges which would form loops. If so, append them to the loopEdges array.
    func removeEdgesFormingLoops() {
        var deleteEdges: [Edge] = []
        for edge in availableEdges {
            chosenEdges.append(edge)
            if containsCycle() {
                deleteEdges.append(edge)
            }
            chosenEdges.removeAll(where: {$0.id == edge.id })
        }
        for edge in deleteEdges {
            availableEdges.removeAll(where: { $0.id == edge.id })
            loopEdges.append(edge)
        }
    }
    
    // When the user clicks an edge, this function will be called to determine if it is a correct selection or not, and updates the edge status to correct if it is a correct selection.
    func nextEdge(edge: Edge) -> Bool {
        chosenEdges.append(edge)
        availableEdges.removeAll(where: {$0.id == edge.id })
        // Return false if the user selected edge forms a cycle
        if containsCycle() {
            print("Invalid selection. A loop is generated")
            chosenEdges.removeAll(where: { $0.id == edge.id })
            error = .cycle
            return false
            
            // Return false if the user selects a non cycle forming edge that is not of minimum weight.
        } else if availableEdges.count > 0 {
            availableEdges.sort(by: { $0.weight < $1.weight })
            if edge.weight > availableEdges[0].weight {
                chosenEdges.removeAll(where: {$0.id == edge.id })
                print("Not the lowest weight. The weight is \(edge.weight)")
                error = .notLowestWeight
                availableEdges.append(edge)
                return false
            }
        }
        edge.status = .correct
        error = .none
        // Check if the algorithm is complete:
        if chosenEdges.count == numVertices - 1 {
            finished = true
        }
        removeEdgesFormingLoops()
        return true
    }
    
    // For resetting the algorithm to the beginning
    func reset() {
        availableEdges = graph.edges
        chosenEdges = []
        loopEdges = []
        error = .none
        finished = false
        for edge in graph.edges {
            edge.isSelected = false
            edge.status = .none
        }
        for vertex in graph.vertices {
            vertex.isSelected = false
        }
        graph.highlightedVertex = nil
    }
}


struct KruskalView: View {
    @StateObject var kruskal: Kruskal
    @ObservedObject var graph: Graph
    
    init(graph: Graph) {
        self.graph = graph
        _kruskal = .init(wrappedValue: Kruskal(graph: graph))
    }
    
    var cycleError: some View {
        ZStack {
            Text("This edge forms a cycle.")
                .font(.headline.bold())
                .foregroundColor(.red)
                .padding()
                .background(Color("TextContrast").opacity(0.5), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()
        }
    }
    
    var weightError: some View {
        ZStack {
            Text("This edge doesn't have the lowest possible weight.")
                .font(.headline.bold())
                .foregroundColor(.red)
                .padding()
                .background(Color("TextContrast").opacity(0.5), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if kruskal.finished {
                Rectangle()
                    .foregroundStyle(blueGradient)
            } else {
                Rectangle()
                    .foregroundColor(darkGray)
            }

            HStack{
                Spacer()
                Button("Clear") {
                    kruskal.reset()
                }
                .padding()
            }
            
            if (kruskal.error == .cycle) {
                cycleError
            }
            
            if (kruskal.error == .notLowestWeight) {
                weightError
            }
            
            ForEach(graph.edges) { edge in
                EdgeView(edge: edge, showWeights: .constant(true), graph: graph)
                    .onTapGesture(count: 1) {
                        if kruskal.error != .none {
                            if edge.status == .error {
                                edge.status = .none
                                kruskal.error = .none
                                edge.isSelected = !edge.isSelected
                            }
                        }
                        else if edge.status != .correct && !kruskal.finished {
                            let edgeError = !kruskal.nextEdge(edge: edge)
                            if edgeError {
                                edge.status = .error
                            } else {
                                edge.status = .correct
                            }
                            edge.isSelected = !edge.isSelected
                        }
                    }
                
                
                ForEach(graph.vertices) { vertex in
                    VertexView(vertex: vertex, graph: graph)
                }
            }
        }
        .onDisappear {
            kruskal.reset()
            graph.algorithm = .none
            graph.changesLocked = false
            graph.weightChangeLocked = false
        }
        .navigationTitle("Kruskal's Algorithm")
    }
}


struct KruskalView_Previews: PreviewProvider {
    static var previews: some View {
        KruskalView(graph: Graph())
    }
}
