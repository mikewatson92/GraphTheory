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
    @Published private var prim: Prim
    @Published var step = Step.chooseVertex
    @Published var error = Error.none
    var visitedVertices: [Vertex] = []
    
    init(graph: Graph) {
        self.prim = Prim(graph: graph)
    }
    
    enum Step {
        case chooseVertex
        case selectingEdges
        case complete
    }
    
    enum Error {
        case none
        case notConnected
        case cycle
        case notLowestWeight
    }

    func getAllEdges() -> [Edge] {
        return Array(prim.graph.edges.values)
    }
    
    func getAllVertices() -> [Vertex] {
        return Array(prim.graph.vertices.values)
    }
    
    func setVertexColor(vertex: Vertex, color: Color) {
        prim.graph.vertices[vertex.id]?.color = color
    }
    
    func setEdgeColor(edge: Edge, color: Color) {
        prim.graph.edges[edge.id]?.color = color
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
            setVertexColor(vertex: newVertex, color: .green)
            visitedVertices.append(newVertex)
        } else {
            newVertex = prim.graph.vertices[edge.startVertexID]!
            setVertexColor(vertex: newVertex, color: .green)
            visitedVertices.append(newVertex)
        }
        addConnectedEdges(for: newVertex)
    }
    
    // Attempts to add the edge to the subgraph if the edge is valid and returns true,
    // otherwise it sets the error status and returns false.
    func tryEdge(_ edge: Edge) -> Bool {
        if !visitedVertices.contains(where: {$0.id == edge.startVertexID}) && !visitedVertices.contains(where: {$0.id == edge.endVertexID}) {
            error = .notConnected
            setEdgeColor(edge: edge, color: .red)
            return false
        } else if doesEdgeFormCycle(edge) {
            error = .cycle
            setEdgeColor(edge: edge, color: .red)
            return false
        } else if !isLowestWeight(edge) {
            error = .notLowestWeight
            setEdgeColor(edge: edge, color: .red)
            return false
        } else { // If there are no errors and the edge is valid
            setEdgeColor(edge: edge, color: .green)
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
    var graphViewModel: GraphViewModel
    @State private var errorEdge: Edge?
    @State private var showBanner = false
    
    init(graph: Graph) {
        _primViewModel = StateObject(wrappedValue: PrimViewModel(graph: graph))
        graphViewModel = GraphViewModel(graph: graph, showWeights: true)
    }
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                ForEach(primViewModel.getAllEdges(), id: \.id) { edge in
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
                                        primViewModel.setEdgeColor(edge: edge, color: Color.primary)
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
                ForEach(primViewModel.getAllVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel, mode: [.noEditLabels, .showLabels])
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                                if primViewModel.step == .chooseVertex {
                                    primViewModel.visitedVertices.append(vertex)
                                    primViewModel.addConnectedEdges(for: vertex)
                                    primViewModel.step = .selectingEdges
                                    primViewModel.setVertexColor(vertex: vertex, color: .green)
                                }
                            })
                }
            }
            if showBanner {
                VStack {
                    Text("The weight of the minimum spanning tree is: \(primViewModel.getTreeWeight().formatted())")
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Button {
                        withAnimation {
                            showBanner = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding([.top], 25)
                .zIndex(1)
                .transition(.move(edge: .top))
            } else if primViewModel.error == .notConnected {
                VStack {
                    Text("This edge is not connected to any of your chosen vertices.")
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding([.top], 25)
                .zIndex(1)
                .transition(.move(edge: .top))
                
            } else if primViewModel.error == .cycle {
                VStack {
                    Text("This edge forms a cycle.")
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding([.top], 25)
                .zIndex(1)
                .transition(.move(edge: .top))
            } else if primViewModel.error == .notLowestWeight {
                VStack {
                    Text("There is another edge with smaller weight.")
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding([.top], 25)
                .zIndex(1)
                .transition(.move(edge: .top))
            }
        }
    }
}

#Preview {
    //PrimView()
}
