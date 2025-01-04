//
//  Prim.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/16/24.
//

import SwiftUI

struct Prim {
    var graph: Graph
    var subGraph: Graph
    var validEdges: [Edge] = []
    
    init(graph: Graph) {
        self.graph = graph
        self.subGraph = Graph(vertices: Array(graph.vertices.values), edges: [])
    }
    
    mutating func removeEdgesFormingCycles() {
        for edge in validEdges {
            var newSubGraph = subGraph
            newSubGraph.edges[edge.id] = edge
            if newSubGraph.hasCycle() {
                validEdges.removeAll { $0.id == edge.id }
            }
        }
    }
    
    mutating func sortEdges() {
        validEdges = validEdges.sorted(by: { $0.weight <= $1.weight })
    }
}

class PrimViewModel: ObservableObject {
    @Published private(set) var prim: Prim
    @Published var step = Step.chooseVertex
    @Published var error = Error.none
    @Published var graphViewModel: GraphViewModel
    var visitedVertices: [Vertex] = []
    var themeViewModel = ThemeViewModel()
    
    init(graphViewModel: GraphViewModel) {
        self.prim = Prim(graph: graphViewModel.graph)
        self.graphViewModel = graphViewModel
    }
    
    enum Step {
        case chooseVertex
        case selectingEdges
        case complete
    }
    
    enum Error: String {
        case none
        case notConnected = "That edge is not connected to any of your current vertices."
        case cycle = "This edge forms a cycle."
        case notLowestWeight = "This is not the lowest available weight."
    }
    
    func doesEdgeFormCycle(_ edge: Edge) -> Bool {
        var newSubgraph = prim.subGraph
        newSubgraph.edges[edge.id] = edge
        return newSubgraph.hasCycle()
    }
    
    func isLowestWeight(_ edge: Edge) -> Bool {
        prim.removeEdgesFormingCycles()
        prim.sortEdges()
        return edge.weight == prim.validEdges[0].weight
    }
    
    func checkForCompletion() -> Bool {
        if prim.subGraph.edges.count == prim.subGraph.vertices.count - 1 {
            step = .complete
            return true
        } else {
            return false
        }
    }
    
    // When a new vertex is added to the growing tree, add new
    // edges that are connected to this vertex to prim.validEdges.
    // Do not add any edges if they are already in prim.validEdges,
    // or if the tree contains that edge.
    func addConnectedEdges(for vertex: Vertex) {
        for edge in prim.graph.getConnectedEdges(to: vertex.id) {
            if !prim.validEdges.contains(where: {$0.id == edge.id}) &&
                !prim.subGraph.edges.contains(where: {$0.key == edge.id}) {
                prim.validEdges.append(edge)
            }
        }
        prim.removeEdgesFormingCycles()
    }
    
    func addNewVertex(for edge: Edge) {
        var newVertex: Vertex
        if visitedVertices.contains(where: {$0.id == edge.startVertexID}) {
            newVertex = prim.graph.vertices[edge.endVertexID]!
            graphViewModel.setVertexColor(vertex: newVertex, color: themeViewModel.theme!.accent)
            visitedVertices.append(newVertex)
        } else {
            newVertex = prim.graph.vertices[edge.startVertexID]!
            graphViewModel.setVertexColor(vertex: newVertex, color: themeViewModel.theme!.accent)
            visitedVertices.append(newVertex)
        }
        addConnectedEdges(for: newVertex)
    }
    
    // Attempts to add the edge to the subgraph if the edge is valid and returns true,
    // otherwise it sets the error status and returns false.
    func tryEdge(_ edge: Edge) -> Bool {
        if !visitedVertices.contains(where: {$0.id == edge.startVertexID}) && !visitedVertices.contains(where: {$0.id == edge.endVertexID}) {
            error = .notConnected
            graphViewModel.setColorForEdge(edge: edge, color: .red)
            return false
        } else if doesEdgeFormCycle(edge) {
            error = .cycle
            graphViewModel.setColorForEdge(edge: edge, color: .red)
            return false
        } else if !isLowestWeight(edge) {
            error = .notLowestWeight
            graphViewModel.setColorForEdge(edge: edge, color: .red)
            return false
        } else { // If there are no errors and the edge is valid
            graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
            prim.subGraph.edges[edge.id] = edge
            prim.validEdges.removeAll { $0.id == edge.id }
            prim.removeEdgesFormingCycles()
            addNewVertex(for: edge)
            return true
        }
    }
    
    func getTreeWeight() -> Double {
        var totalWeight = 0.0
        for edge in prim.subGraph.edges.values {
            totalWeight += edge.weight
        }
        return totalWeight
    }
}

struct PrimView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject var primViewModel: PrimViewModel
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var errorEdge: Edge?
    @State private var showBanner = false
    
    init(graph: Graph) {
        let graphViewModel = GraphViewModel(graph: graph, showWeights: true)
        _primViewModel = StateObject(wrappedValue: PrimViewModel(graphViewModel: graphViewModel))
        self.graphViewModel = graphViewModel
    }
    
    var body: some View {
        
        VStack {
            if showBanner {
                if primViewModel.step == .complete {
                    Instructions(showBanner: $showBanner, text: "The weight of the minimum spanning tree is: \(primViewModel.getTreeWeight().formatted())")
                } else if primViewModel.error != .none {
                    Instructions(showBanner: $showBanner, text: primViewModel.error.rawValue)
                }
            }
            GeometryReader { geometry in
                ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                    EdgeView(edgeViewModel: edgeViewModel)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                                if primViewModel.step == .selectingEdges {
                                    if edge.id == errorEdge?.id {
                                        errorEdge = nil
                                        withAnimation {
                                            primViewModel.error = .none
                                        }
                                        graphViewModel.setColorForEdge(edge: edge, color: primViewModel.prim.graph.originalEdges[edge.id]?.color)
                                    } else {
                                        withAnimation {
                                            if !primViewModel.tryEdge(edge) {
                                                errorEdge = edge
                                            } else if primViewModel.checkForCompletion() {
                                                showBanner = true
                                            }
                                        }
                                    }
                                }
                            })
                }
                ForEach(graphViewModel.getVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                                if primViewModel.step == .chooseVertex {
                                    primViewModel.visitedVertices.append(vertex)
                                    primViewModel.addConnectedEdges(for: vertex)
                                    primViewModel.step = .selectingEdges
                                    graphViewModel.setVertexColor(vertex: vertex, color: themeViewModel.theme!.accent)
                                }
                            })
                }
            }
        }
        .onAppear {
            primViewModel.themeViewModel = themeViewModel
        }
    }
}

#Preview {
    //PrimView()
}
