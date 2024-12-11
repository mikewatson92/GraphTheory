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
        self.validEdges = graph.edges
    }
    
    mutating func removeEdgesFormingCycles() {
        for edge in validEdges {
            var newSubGraph = subGraph
            newSubGraph.edges.append(edge)
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
        kruskal.subGraph.edges.append(edge)
    }
    
    func removeEdge(_ edge: Edge) {
        kruskal.graph.removeEdge(edge)
    }
    
    func hasEdgeBeenSelected(_ edge: Edge) -> Bool {
        kruskal.subGraph.edges.contains(where: {$0.id == edge.id})
    }
    
    func getTreeWeight() -> Double {
        var totalWeight = 0.0
        for edge in kruskal.subGraph.edges {
            totalWeight += edge.weight
        }
        return totalWeight
    }
    
    func getWeight(edge: Edge) -> Double {
        kruskal.graph.edges.first(where: {$0.id == edge.id})!.weight
    }
    
    func setWeight(edge: Edge, weight: Double) {
        if let index = kruskal.graph.edges.firstIndex(where: {$0.id == edge.id}) {
            kruskal.graph.edges[index].weight = weight
        }
    }
    
    func isComplete() -> Bool {
        if errorStatus == .none {
            if kruskal.subGraph.edges.count == kruskal.subGraph.vertices.count - 1 {
                return true
            }
        }
        return false
    }
    
    func setControlPoint1(for edge: Edge, at point: CGPoint) {
        kruskal.graph.setControlPoint1(for: edge, at: point)
            
        }
    
    func setControlPoint2(for edge: Edge, at point: CGPoint)
    {
        kruskal.graph.setControlPoint2(for: edge, at: point)
    }
    
    func setControlPoint1Offset(for edge: Edge, size: CGSize) {
        kruskal.graph.setControlPoint1Offset(for: edge, translation: size)
    }
    
    func setControlPoint2Offset(for edge: Edge, size: CGSize) {
        kruskal.graph.setControlPoint2Offset(for: edge, translation: size)
    }
    
    func setEdgeWeightPosition(edgeID: UUID, position: CGPoint) {
        if let index = kruskal.graph.edges.firstIndex(where: { $0.id == edgeID }) {
            kruskal.graph.edges[index].weightPosition = position
        }
    }
    
    func setWeightPositionOffset(edgeID: UUID, size: CGSize) {
        if let index = kruskal.graph.edges.firstIndex(where: { $0.id == edgeID }) {
            kruskal.graph.edges[index].weightPositionOffset = size
        }
    }
    
    func setVertexPosition(vertexID: UUID, position: CGPoint) {
        kruskal.graph.vertices[vertexID]?.position = position
    }
    
    func setVertexOffset(vertexID: UUID, size: CGSize) {
        kruskal.graph.vertices[vertexID]?.offset = size
    }
    
    func setVertexColor(vertexID: UUID, color: Color) {
        kruskal.graph.vertices[vertexID]?.color = color
    }
    
    func setEdgeColor(edgeID: UUID, color: Color) {
        if let index = kruskal.graph.edges.firstIndex(where: { $0.id == edgeID }) {
            kruskal.graph.edges[index].color = color
        }
    }
    
    func getAllEdges() -> [Edge] {
        kruskal.graph.edges
    }
    
    func getAllVertices() -> [Vertex] {
        Array(kruskal.graph.vertices.values)
    }
    
    func edgeIsValid(_ edge: Edge) -> Bool {
        guard kruskal.validEdges.count > 0 else { return false }
        
        kruskal.removeEdgesFormingCycles()
        kruskal.sortEdges()
        
        var newSubGraph = kruskal.subGraph
        newSubGraph.edges.append(edge)
        
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
        return true
    }
}

struct KruskalView: View {
    @ObservedObject var kruskalViewModel: KruskalViewModel
    @State private var errorEdge: Edge? = nil
    @State private var showBanner = false
    
    init(graph: Graph) {
        self.kruskalViewModel = KruskalViewModel(graph: graph)
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
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size,
                                                      removeEdge: { edge in
                        kruskalViewModel.removeEdge(edge)
                    },
                                                      getVertexPositionByID: { id in
                        let vertex = kruskalViewModel.getGraph().getVertexByID(id)
                        return vertex?.position
                    }, getShowingWeights: { _ in
                        true
                    }, setShowingWeights: { _, _ in },
                                                      getOffset: { id in
                        kruskalViewModel.getGraph().getOffsetByID(id)
                    }, getEdgeControlPoints: { edge in
                        kruskalViewModel.getGraph().getEdgeControlPoints(for: edge)
                    }, setEdgeControlPoint1: { edge, point in
                        kruskalViewModel.setControlPoint1(for: edge, at: point)
                    }, setEdgeControlPoint2: { edge, point in
                        kruskalViewModel.setControlPoint2(for: edge, at: point)
                    },
                                                      
                                                      getEdgeControlPointOffsets: { edge in
                        kruskalViewModel.getGraph().getEdgeControlPointOffsets(for: edge)
                    }, setEdgeControlPoint1Offset: { edge, size in
                        kruskalViewModel.setControlPoint1Offset(for: edge, size: size)
                    }, setEdgeControlPoint2Offset: { edge, size in
                        kruskalViewModel.setControlPoint2Offset(for: edge, size: size)
                    }, getWeightPosition: { edge in
                        kruskalViewModel.getGraph().getEdgeWeightPositionByID(edge.id) ?? CGPoint(x: 0, y: 0)
                    }, setWeightPosition: { edge, point in
                        kruskalViewModel.setEdgeWeightPosition(edgeID: edge.id, position: point)
                    }, getWeightPositionOffset: { edge in
                        kruskalViewModel.getGraph().edges.first(where: { $0.id == edge.id })?.weightPositionOffset ?? CGSize.zero
                    }, setWeightPositionOffset: { edge, size in
                        kruskalViewModel.setWeightPositionOffset(edgeID: edge.id, size: size)
                    }, getWeight: { edge in
                        kruskalViewModel.getWeight(edge: edge)
                    }, setWeight: { edge, weight in
                        kruskalViewModel.setWeight(edge: edge, weight: weight)
                    }, getMode: { kruskalViewModel.getGraph().mode }
                    )
                    EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
                        .onTapGesture(count: 1) {
                            handleTap(forEdge: edge)
                        }
                }
                
                ForEach(kruskalViewModel.getAllVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, mode: [.showLabels, .noEditLabels], getVertexPosition: { id in
                        kruskalViewModel.getGraph().vertices[id]?.position
                    }, setVertexPosition: { id, point in
                        kruskalViewModel.setVertexPosition(vertexID: id, position: point)
                    }, getVertexOffset: { id in
                        kruskalViewModel.getGraph().vertices[id]?.offset
                    }, setVertexOffset: { id, size in
                        kruskalViewModel.setVertexOffset(vertexID: id, size: size)
                    }, setVertexColor: { id, color in
                        kruskalViewModel.setVertexColor(vertexID: id, color: color)
                    })
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                }
            }
            // Banner shown upon completion
            if showBanner {
                withAnimation {
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
                }
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
                .zIndex(1)
                .transition(.move(edge: .top))
            }
        }
    }
}

#Preview {
    //KruskalView()
}
