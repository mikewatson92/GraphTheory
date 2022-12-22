//
//  Prim.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

import SwiftUI

class Prim: ObservableObject {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @Published var finished: Bool = false
    var model: ModelData
    var numVertices: Int
    var numEdges: Int
    var availableEdges: [Edge]
    var chosenEdges: [Edge] = []
    var loopEdges: [Edge] = []
    var startPhase: Bool = true
    var startVertex: Vertex?
    var error: PrimError = .none
    
    enum PrimError: Error {
        case loop, notLowestWeight, notConnected, none
    }
    
    init(model: ModelData) {
        self.model = model
        self.numVertices = model.vertices.count
        self.numEdges = model.edges.count
        self.availableEdges = model.edges.sorted(by: { $0.weight < $1.weight })
    }
    
    func setStartVertex(_ newVertex: Vertex) {
        self.startVertex = newVertex
    }
    
    // Determines whether the graph consisting of the edges selected by the user, chosenEdges, contains a cycle.
    func containsCycle() -> Bool {
        let graph = Graph(chosenEdges: chosenEdges, model: model)
        let result = graph.hasCycle(availableEdges: chosenEdges)
        if result == true {
            return true
        }
        return false
        
    }
    
    // Determine if a newEdge's weight has the lowest weight of all available edges. There may be multiple edges with the lowest weight.
    func lowestWeight(newEdge: Edge) -> Bool {
        guard availableEdges.count > 0 else { return true }
        return (newEdge == availableEdges[0])
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
    
    // Returns true if a new edge is connected to a vertex of an existing tree. Otherwise, returns false.
    func isConnected(newEdge: Edge) -> Bool {
        chosenEdges.removeAll(where: { $0.id == newEdge.id })
        if chosenEdges.count == 0 {
            return true
        } else {
            for edge in chosenEdges {
                if edge.startVertex.id == newEdge.startVertex.id || edge.startVertex.id == newEdge.endVertex.id || edge.endVertex.id == newEdge.startVertex.id || edge.endVertex.id == newEdge.endVertex.id {
                    chosenEdges.append(newEdge)
                    return true
                }
            }
            return false
        }
    }
    
    // When the user clicks an edge, this function will be called to determine if it is a correct selection or not, and updates the edge status to correct if it is a correct selection.
    func nextEdge(edge: Edge) -> Bool {
        chosenEdges.append(edge)
        availableEdges.removeAll(where: {$0.id == edge.id })
        removeEdgesFormingLoops()
        
        //If the user has selected a starting vertex, make sure the first edge is connnected to it
        if chosenEdges.count == 1 {
            if edge.startVertex.id != startVertex?.id && edge.endVertex.id != startVertex?.id {
                print("Starting edge is not connected to starting vertex")
                error = .notConnected
                chosenEdges.removeAll(where: {$0.id == edge.id })
                return false
            }
        }
        
        // Return false if the selected edge is not connected to the current tree
        else if !isConnected(newEdge: edge){
            print("Invalid selection. Edge is not connected to current tree.")
            error = .notConnected
            chosenEdges.removeAll(where: { $0.id == edge.id })
            return false
        }
        
        // Return false if the user selected edge forms a cycle
        else if containsCycle() {
            print("Invalid selection. A loop is generated")
            error = .loop
            chosenEdges.removeAll(where: { $0.id == edge.id })
            return false
        } else if !isConnected(newEdge: edge) {
            chosenEdges.removeAll(where: { $0.id == edge.id })
            error = .notConnected
            print("Edges not connected.")
            return false
        }
        
        // Return false if the user selects a connected edge that is not of minimal weight.
        else if availableEdges.count > 0 {
            var filteredEdges = availableEdges.filter({ isConnected(newEdge: $0) })
            filteredEdges.sort(by: { $0.weight < $1.weight })
            if edge.weight > filteredEdges[0].weight {
                chosenEdges.removeAll(where: { $0.id == edge.id })
                error = .notLowestWeight
                print("Not the lowest weight. The weight is \(edge.weight)")
                return false
            }
        }
        edge.status = .correct
        // Check if the algorithm is complete:
        if chosenEdges.count == numVertices - 1 {
            finished = true
        }
        return true
    }
    
    func reset() {
        chosenEdges = []
        availableEdges = model.edges
        loopEdges = []
        error = .none
        finished = false
        for edge in model.edges {
            edge.isSelected = false
            edge.status = .none
        }
        for vertex in model.vertices {
            vertex.isSelected = false
        }
        model.highlightedVertex = nil
    }
}

struct PrimView: View {
    @ObservedObject var model: ModelData
    @StateObject var prim: Prim
    
    init(model: ModelData) {
        self.model = model
        _prim = .init(wrappedValue: Prim(model: model))
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
            
            ForEach(model.edges) { edge in
                let edgeView = EdgeView(edge: edge, showWeights: .constant(true), model: model)
                edgeView
                    .onTapGesture(count: 1) {
                        if !prim.startPhase {
                            if prim.error != .none {
                                if edge.status == .error {
                                    edge.status = .none
                                    prim.error = .none
                                    edge.isSelected = !edge.isSelected
                                }
                            }
                            else if edge.status != .correct && !prim.finished {
                                let edgeError = !prim.nextEdge(edge: edge)
                                if edgeError {
                                    edge.status = .error
                                } else {
                                    edge.status = .correct
                                }
                                edge.isSelected = !edge.isSelected
                            }
                        }
                    }
                
                
                ForEach(model.vertices) { vertex in
                    let vertexView = VertexView(vertex: vertex, model: model)
                    vertexView
                        .onTapGesture(count: 1) {
                            if prim.startPhase {
                                prim.startPhase = false
                                model.highlightedVertex = vertex
                                prim.startVertex = vertex
                            }
                        }
                }
            }
        }
        .onAppear{
            model.algorithm = .prim
            model.changesLocked = true
            model.weightChangeLocked = true
        }
        .onDisappear {
            model.algorithm = .none
            model.changesLocked = false
            model.weightChangeLocked = false
            model.highlightedVertex = nil
            for edge in model.edges {
                edge.status = .none
                edge.isSelected = false
            }
        }
        .navigationTitle("Prim's Algorithm")
    }
}

struct PrimView_Previews: PreviewProvider {
    static var previews: some View {
        PrimView(model: ModelData())
    }
}
