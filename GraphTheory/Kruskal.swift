//
//  Kruskal.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/11/24.
//

import SwiftUI

struct Kruskal {
    var graph: Graph
    var subGraph: Graph
    var validEdges: [Edge]
    
    init(graph: Graph) {
        self.graph = graph
        self.graph.mode = .algorithm
        self.subGraph = Graph(vertices: Array(graph.vertices.values), edges: [])
        self.validEdges = Array(graph.edges.values)
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

class KruskalViewModel: ObservableObject {
    @Published private var kruskal: Kruskal
    @Published var errorStatus = ErrorStatus.none
    @Published var completionStatus = CompletionStatus.inProgress
    var selectedEdge: Edge?
    
    init(graph: Graph) {
        self.kruskal = Kruskal(graph: graph)
    }
    
    enum ErrorStatus {
        case none
        case cycleError
        case notLowestWeightError
    }
    
    enum CompletionStatus {
        case inProgress
        case completed
    }
    
    func getGraph() -> Graph {
        kruskal.graph
    }
    
    func addEdge(_ edge: Edge) {
        kruskal.subGraph.edges[edge.id] = edge
    }
    
    func hasEdgeBeenSelected(_ edge: Edge) -> Bool {
        kruskal.subGraph.edges.keys.contains(where: {$0 == edge.id})
    }
    
    func getTreeWeight() -> Double {
        var totalWeight = 0.0
        for edge in kruskal.subGraph.edges.values {
            totalWeight += edge.weight
        }
        return totalWeight
    }
    
    func getWeight(edge: Edge) -> Double {
        kruskal.graph.edges[edge.id]!.weight
    }
    
    func setWeight(edge: Edge, weight: Double) {
        kruskal.graph.edges[edge.id]?.weight = weight
    }
    
    func isComplete() -> Bool {
        if errorStatus == .none {
            if kruskal.subGraph.edges.count == kruskal.subGraph.vertices.count - 1 {
                return true
            }
        }
        return false
    }
    
    func setVertexColor(vertexID: UUID, color: Color) {
        kruskal.graph.vertices[vertexID]?.color = color
    }
    
    func setEdgeColor(edgeID: UUID, color: Color) {
        kruskal.graph.edges[edgeID]?.color = color
    }
    
    func getAllEdges() -> [Edge] {
        Array(kruskal.graph.edges.values)
    }
    
    func getAllVertices() -> [Vertex] {
        Array(kruskal.graph.vertices.values)
    }
    
    func edgeIsValid(_ edge: Edge) -> Bool {
        guard kruskal.validEdges.count > 0 else { return false }
        
        kruskal.removeEdgesFormingCycles()
        kruskal.sortEdges()
        
        var newSubGraph = kruskal.subGraph
        newSubGraph.edges[edge.id] = edge
        
        if newSubGraph.hasCycle() {
            withAnimation {
                errorStatus = .cycleError
            }
            return false
        }
        
        if edge.weight > kruskal.validEdges[0].weight {
            withAnimation {
                errorStatus = .notLowestWeightError
            }
            return false
        }
        
        if isComplete() {
            completionStatus = .completed
        }
        kruskal.validEdges.removeAll { $0.id == edge.id }
        setVertexColor(vertexID: edge.startVertexID, color: .green)
        setVertexColor(vertexID: edge.endVertexID, color: .green)
        return true
    }
}

struct KruskalView: View {
    @ObservedObject var kruskalViewModel: KruskalViewModel
    var graphViewModel: GraphViewModel
    @State private var errorEdge: Edge? = nil
    @State private var showBanner = false
    
    init(graph: Graph) {
        self.kruskalViewModel = KruskalViewModel(graph: graph)
        self.graphViewModel = GraphViewModel(graph: graph, showWeights: true, showModeMenu: false, showAlgorithms: false)
    }
    
    func handleTap(forEdge edge: Edge) {
        if kruskalViewModel.completionStatus == .inProgress {
            if errorEdge == nil { // If there are no errors yet
                if kruskalViewModel.edgeIsValid(edge) { // and the edge is a correct selection
                    if !kruskalViewModel.hasEdgeBeenSelected(edge) {
                        kruskalViewModel.addEdge(edge)
                        kruskalViewModel.setEdgeColor(edgeID: edge.id, color: Color.green)
                        if kruskalViewModel.isComplete() {
                            withAnimation {
                                showBanner = true
                                kruskalViewModel.completionStatus = .completed
                            }
                        }
                    }
                } else {
                    kruskalViewModel.setEdgeColor(edgeID: edge.id, color: Color.red)
                    errorEdge = edge
                }
            } else { // If there is an edge error
                if edge.id == errorEdge?.id {
                    // and the user selects the error edge
                    kruskalViewModel.setEdgeColor(edgeID: edge.id, color: Color.primary)
                    errorEdge = nil
                    withAnimation {
                        kruskalViewModel.errorStatus = .none
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ForEach(kruskalViewModel.getAllEdges()) { edge in
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                    EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                            handleTap(forEdge: edge)
                        })
                }
                
                ForEach(kruskalViewModel.getAllVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel, mode: [.showLabels, .noEditLabels])
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                }
            }
            // Banner shown upon completion
            if showBanner {
                VStack {
                    Text("The weight of the minimum spanning tree is: \(kruskalViewModel.getTreeWeight().formatted())")
                        .foregroundColor(Color.primary)
                        .padding()
                        .background(Color.secondary)
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
            } else if kruskalViewModel.errorStatus == .cycleError {
                VStack {
                    Text("This edge forms a cycle.")
                        .foregroundColor(Color.primary)
                        .padding()
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding([.top], 25)
                .zIndex(1)
                .transition(.move(edge: .top))
            } else if kruskalViewModel.errorStatus == .notLowestWeightError {
                VStack {
                    Text("There is another edge with smaller weight.")
                        .foregroundColor(Color.primary)
                        .padding()
                        .background(Color.secondary)
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
    //KruskalView()
}
