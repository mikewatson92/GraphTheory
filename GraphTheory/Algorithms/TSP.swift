//
//  TSP.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class TSPModel: ObservableObject {
    @Published var graph: Graph
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
        for vertex in graph.vertices {
            var otherVertices = graph.vertices
            otherVertices.removeAll(where: { $0 == vertex })
            for otherVertex in otherVertices {
                if !graph.verticesConnected(vertex, otherVertex) {
                    return false
                }
            }
        }
        return true
    }
    var lowerBoundModel = Graph()
    var kruskal: Kruskal?
    
    var nearestNeighborFinished: Bool {
        vertexPath.count == graph.vertices.count + 1
    }
    
    init(graph: Graph) {
        self.graph = graph
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
        
        for edge in graph.edges {
            if currentVertex!.edgeIsConnected(edge: edge) {
                if edge.endVertex == currentVertex {
                    edge.swapVertices()
                }
                if lowestWeight == nil {
                    if !vertexPath.contains(edge.endVertex) || (vertexPath.count == graph.vertices.count && edge.endVertex == startVertex) {
                        lowestWeight = edge.weight
                    }
                } else if edge.weight < lowestWeight! && !vertexPath.contains(edge.endVertex) {
                    lowestWeight = edge.weight
                } else if edge.weight < lowestWeight! && vertexPath.count == graph.vertices.count && edge.endVertex == startVertex {
                    /* If the weight of the edge is less than lowestWeight, and all vertices have already been visited except
                     for the return to the startVertex, and the edge's endVertex is equal to startVertex, thus completing the
                     Hamiltonian cycle, then set lowestWeight to the weight of the edge. */
                    lowestWeight = edge.weight
                }
            }
        }
        if vertexPath.contains(edge.endVertex) && edge.endVertex == startVertex && vertexPath.count == graph.vertices.count {
            return edge.weight == lowestWeight!
        } else {
            return edge.weight == lowestWeight!
        }
    }
    
    func populateLowerBoundModel() {
        for vertex in graph.vertices {
            if vertex != deletedVertex {
                lowerBoundModel.vertices.append(vertex)
            }
        }
        for edge in graph.edges {
            if !deletedEdges.contains(edge) {
                lowerBoundModel.edges.append(edge)
            }
        }
        kruskal = Kruskal(graph: lowerBoundModel)
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
        graph.highlightedVertex = nil
        for edge in graph.edges {
            edge.status = .none
        }
        for vertex in graph.vertices {
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
        lowerBoundModel = Graph()
        kruskal = nil
    }
    
    func resetForLowerBound() {
        for edge in graph.edges {
            edge.status = .none
        }
        for vertex in graph.vertices {
            vertex.status = .none
        }
    }
    
}

struct TSP: View {
    @StateObject var tspModel: TSPModel
    @ObservedObject var graph: Graph
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
    
    init(graph: Graph) {
        self.graph = graph
        _tspModel = .init(wrappedValue: TSPModel(graph: graph))
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
                
                ForEach(graph.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(true), graph: graph)
                        .onAppear {
                            graph.algorithm = .tsp
                            graph.changesLocked = true
                            graph.weightChangeLocked = true
                        }
                        .onTapGesture(count: 1) {
                            if !graph.changesLocked {
                                edge.isSelected = !edge.isSelected
                            }
                            if tspModel.status == .inProgressUpperBound {
                                if tspModel.isNearestNeighbor(edge) {
                                    edge.status = .correct
                                    tspModel.edgePath.append(edge)
                                    tspModel.vertexPath.append(edge.endVertex)
                                    tspModel.currentVertex!.status = .visited
                                    tspModel.currentVertex = edge.endVertex
                                    graph.highlightedVertex = edge.endVertex
                                } else if edge.status == .none {
                                    edge.status = .error
                                } else if edge.status == .error {
                                    edge.status = .none
                                }
                                if tspModel.nearestNeighborFinished {
                                    graph.highlightedVertex = nil
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
                
                ForEach(graph.vertices) { vertex in
                    VertexView(vertex: vertex, graph: graph)
                        .onAppear {
                            graph.algorithm = .tsp
                            graph.changesLocked = true
                            graph.weightChangeLocked = true
                        }
                        .simultaneousGesture(SimultaneousGesture(TapGesture(count: 1), TapGesture(count: 2))
                            .onEnded{ gestures in
                                if gestures.second == nil { // Single tap gesture
                                    if tspModel.status == .startUpperBound {
                                        tspModel.startVertex = vertex
                                        tspModel.currentVertex = vertex
                                        graph.highlightedVertex = vertex
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
                                        for edge in graph.edges {
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
                graph.algorithm = .none
                graph.changesLocked = false
                graph.weightChangeLocked = false
                graph.highlightedVertex = nil
                for edge in graph.edges {
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
        TSP(graph: Graph())
    }
}
