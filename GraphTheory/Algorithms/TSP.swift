//
//  TSP.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class TSPModel: ObservableObject {
    var model: ModelData
    var startVertex: Vertex?
    var currentVertex: Vertex?
    var edgePath: [Edge] = []
    var vertexPath: [Vertex] = []
    var deletedVertex: Vertex?
    var deletedEdges: [Edge] = []
    var addBackEdges: [Edge] = []
    var upperBound: Double = 0
    var lowerBound: Double = 0
    @Published var status: Status = .startUpperBound
    var isCompleteGraph: Bool {
        for vertex in model.vertices {
            var otherVertices = model.vertices
            otherVertices.removeAll(where: { $0 == vertex })
            for otherVertex in otherVertices {
                if !model.verticesConnected(vertex, otherVertex) {
                    return false
                }
            }
        }
        return true
    }
    var lowerBoundModel: ModelData = ModelData()
    var kruskal: Kruskal?
    
    var nearestNeighborFinished: Bool {
        vertexPath.count == model.vertices.count + 1
    }
    
    init(model: ModelData) {
        self.model = model
    }
    
    enum Status {
        case startUpperBound
        case inProgressUpperBound
        case startLowerBound
        case inProgressLowerBound
        case addBackVertex
        case addBackEdges
        case finished
    }
    
    func isNearestNeighbor(_ edge: Edge) -> Bool {
        var lowestWeight: Double?
        
        if edge.endVertex == currentVertex {
            edge.swapVertices()
        }
        
        for edge in model.edges {
            if currentVertex!.edgeIsConnected(edge: edge) {
                if edge.endVertex == currentVertex {
                    edge.swapVertices()
                }
                if lowestWeight == nil {
                    if !vertexPath.contains(edge.endVertex) || (vertexPath.count == model.vertices.count && edge.endVertex == startVertex) {
                        lowestWeight = edge.weight
                    }
                } else if edge.weight < lowestWeight! && !vertexPath.contains(edge.endVertex) {
                    lowestWeight = edge.weight
                } else if edge.weight < lowestWeight! && vertexPath.count == model.vertices.count && edge.endVertex == startVertex {
                    /* If the weight of the edge is less than lowestWeight, and all vertices have already been visited except
                     for the return to the startVertex, and the edge's endVertex is equal to startVertex, thus completing the
                     Hamiltonian cycle, then set lowestWeight to the weight of the edge. */
                    lowestWeight = edge.weight
                }
            }
        }
        if vertexPath.contains(edge.endVertex) && edge.endVertex == startVertex && vertexPath.count == model.vertices.count {
            return edge.weight == lowestWeight!
        } else {
            return edge.weight == lowestWeight!
        }
    }
    
    func populateLowerBoundModel() {
        for vertex in model.vertices {
            if vertex != deletedVertex {
                lowerBoundModel.vertices.append(vertex)
            }
        }
        for edge in model.edges {
            if !deletedEdges.contains(edge) {
                lowerBoundModel.edges.append(edge)
            }
        }
        kruskal = Kruskal(model: lowerBoundModel)
    }
    
    func computeUpperBound() {
        for edge in edgePath {
            upperBound += edge.weight
        }
    }
    
    func computeLowerBound() {
        for edge in kruskal!.chosenEdges {
            lowerBound += edge.weight
        }
        for edge in addBackEdges {
            lowerBound += edge.weight
        }
    }
    
    func reset() {
        model.highlightedVertex = nil
        for edge in model.edges {
            edge.status = .none
        }
        for vertex in model.vertices {
            vertex.status = .none
        }
        
        startVertex = nil
        currentVertex = nil
        edgePath = []
        vertexPath = []
        deletedVertex = nil
        deletedEdges = []
        addBackEdges = []
        upperBound = 0
        lowerBound = 0
        status = .startUpperBound
        lowerBoundModel = ModelData()
        kruskal = nil
    }
    
    func resetForLowerBound() {
        for edge in model.edges {
            edge.status = .none
        }
        for vertex in model.vertices {
            vertex.status = .none
        }
    }
    
}

struct TSP: View {
    @StateObject var tspModel: TSPModel
    @ObservedObject var model: ModelData
    var message: String {
        switch tspModel.status {
        case .startUpperBound:
            return "Select a starting vertex."
        case .inProgressUpperBound:
            return "Apply the nearest neighbor algorithm."
        case .startLowerBound:
            return "Double click any vertex to delete it."
        case .inProgressLowerBound:
            return "Apply Kruskal's algorithm to find a minimum spanning tree."
        case .addBackVertex:
            return "Click on the deleted vertex to add it back to the graph."
        case .addBackEdges:
            return "Select the two smallest weight edges to add them back to the graph"
        case .finished:
            return """
                    Upper Bound: \(tspModel.upperBound)
                    Lower Bound: \(tspModel.lowerBound)
                   """
        }
    }
    
    init(model: ModelData) {
        self.model = model
        _tspModel = .init(wrappedValue: TSPModel(model: model))
    }
    
    var body: some View {
        if !tspModel.isCompleteGraph {
            Text("Error. This is not a complete graph. For the classical Traveling Salesman Problem, all vertices must be directly connected by an edge.")
                .foregroundColor(.red)
                .font(.largeTitle)
                .navigationTitle("Traveling Salesman Problem")
        } else {
            ZStack(alignment: .topLeading) {
                if tspModel.status == .finished {
                    Rectangle()
                        .foregroundStyle(blueGradient)
                } else {
                    Rectangle()
                        .foregroundColor(darkGray)
                }
                
                HStack{
                    Spacer()
                    Text(message)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top)
                    Spacer()
                    Button("Clear") {
                        tspModel.reset()
                    }
                    .padding()
                }
                
                ForEach(model.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(true), model: model)
                        .onAppear {
                            model.algorithm = .tsp
                            model.changesLocked = true
                            model.weightChangeLocked = true
                        }
                        .onTapGesture(count: 1) {
                            if tspModel.status == .inProgressUpperBound {
                                if tspModel.isNearestNeighbor(edge) {
                                    edge.status = .correct
                                    tspModel.edgePath.append(edge)
                                    tspModel.vertexPath.append(edge.endVertex)
                                    tspModel.currentVertex!.status = .visited
                                    tspModel.currentVertex = edge.endVertex
                                    model.highlightedVertex = edge.endVertex
                                } else if edge.status == .none {
                                    edge.status = .error
                                } else if edge.status == .error {
                                    edge.status = .none
                                }
                                if tspModel.nearestNeighborFinished {
                                    model.highlightedVertex = nil
                                    tspModel.computeUpperBound()
                                    tspModel.status = .startLowerBound
                                }
                            } else if tspModel.status == .inProgressLowerBound {
                                if tspModel.kruskal!.error != .none {
                                    if edge.status == .error {
                                        edge.status = .none
                                        tspModel.kruskal!.error = .none
                                        edge.isSelected = !edge.isSelected
                                    }
                                } else if edge.status != .correct && edge.status != .deleted && !tspModel.kruskal!.finished {
                                    let edgeError = !tspModel.kruskal!.nextEdge(edge: edge)
                                    if edgeError {
                                        edge.status = .error
                                    } else {
                                        edge.status = .correct
                                    }
                                    edge.isSelected = !edge.isSelected
                                }
                                if tspModel.kruskal!.finished {
                                    tspModel.status = .addBackVertex
                                }
                            } else if tspModel.status == .addBackEdges {
                                if edge.status == .deleted && edge.weight == tspModel.deletedEdges.sorted(by: { $0.weight < $1.weight })[0].weight {
                                    tspModel.addBackEdges.append(edge)
                                    tspModel.deletedEdges.removeAll(where: { $0.id == edge.id })
                                    edge.status = .correct
                                    if tspModel.addBackEdges.count == 2 {
                                        tspModel.computeLowerBound()
                                        tspModel.status = .finished
                                    }
                                }
                            }
                        }
                }
                
                ForEach(model.vertices) { vertex in
                    VertexView(vertex: vertex, model: model)
                        .onAppear {
                            model.algorithm = .tsp
                            model.changesLocked = true
                            model.weightChangeLocked = true
                        }
                        .simultaneousGesture(SimultaneousGesture(TapGesture(count: 1), TapGesture(count: 2))
                            .onEnded{ gestures in
                                if gestures.second == nil { // Single tap gesture
                                    if tspModel.status == .startUpperBound {
                                        tspModel.startVertex = vertex
                                        tspModel.currentVertex = vertex
                                        model.highlightedVertex = vertex
                                        tspModel.status = .inProgressUpperBound
                                        tspModel.vertexPath.append(vertex)
                                    }
                                    if tspModel.status == .addBackVertex {
                                        if vertex.status == .deleted {
                                            vertex.status = .none
                                            tspModel.status = .addBackEdges
                                        }
                                    }
                                } else { // Double tap gesture
                                    if tspModel.status == .startLowerBound {
                                        tspModel.resetForLowerBound()
                                        vertex.status = .deleted
                                        tspModel.deletedVertex = vertex
                                        for edge in model.edges {
                                            if vertex.edgeIsConnected(edge: edge) {
                                                edge.status = .deleted
                                                tspModel.deletedEdges.append(edge)
                                            }
                                        }
                                        tspModel.status = .inProgressLowerBound
                                        tspModel.populateLowerBoundModel()
                                    }
                                }
                            }
                        )
                }
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
            .navigationTitle("Traveling Salesman Problem")
        }
    }
}

struct TSP_Previews: PreviewProvider {
    static var previews: some View {
        TSP(model: ModelData())
    }
}
