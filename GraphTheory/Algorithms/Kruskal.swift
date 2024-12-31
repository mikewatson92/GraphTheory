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
    @Published var graphViewModel: GraphViewModel
    @Published var errorStatus = ErrorStatus.none
    @Published var completionStatus = CompletionStatus.inProgress
    @Published var errorEdge: Edge?
    var selectedEdge: Edge?
    
    init(graphViewModel: GraphViewModel) {
        self.kruskal = Kruskal(graph: graphViewModel.graph)
        self.graphViewModel = graphViewModel
        self.graphViewModel.showWeights = true
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
    
    func chooseEdge(_ edge: Edge) {
        guard kruskal.validEdges.count > 0 else { return }
        guard completionStatus == .inProgress else { return }
        if let error = errorEdge {
            if edge.id == error.id {
                errorEdge = nil
                errorStatus = .none
                graphViewModel.setColorForEdge(edge: edge, color: Color.primary)
            }
            return
        }
        
        kruskal.removeEdgesFormingCycles()
        kruskal.sortEdges()
        var newSubGraph = kruskal.subGraph
        newSubGraph.edges[edge.id] = edge
        
        if newSubGraph.hasCycle() {
            withAnimation {
                errorStatus = .cycleError
                graphViewModel.setColorForEdge(edge: edge, color: .red)
                errorEdge = edge
            }
            return
        }
        
        if edge.weight > kruskal.validEdges[0].weight {
            withAnimation {
                errorStatus = .notLowestWeightError
                graphViewModel.setColorForEdge(edge: edge, color: .red)
                errorEdge = edge
            }
            return
        }
        
        kruskal.subGraph.edges[edge.id] = edge

        if isComplete() {
            completionStatus = .completed
        }
        kruskal.validEdges.removeAll { $0.id == edge.id }
        graphViewModel.setColorForEdge(edge: edge, color: .green)
        graphViewModel.setVertexColor(vertex: kruskal.graph.vertices[edge.startVertexID]!, color: .green)
        graphViewModel.setVertexColor(vertex: kruskal.graph.vertices[edge.endVertexID]!, color: .green)
        return
    }
}

struct KruskalView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @ObservedObject var kruskalViewModel: KruskalViewModel
    @State private var showBanner = false
    @Binding var completion: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ForEach(kruskalViewModel.graphViewModel.getEdges(), id: \.id) { edge in
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: kruskalViewModel.graphViewModel)
                    EdgeView(edgeViewModel: edgeViewModel)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                                kruskalViewModel.chooseEdge(edge)
                                if kruskalViewModel.completionStatus == .completed {
                                    withAnimation {
                                        completion = true
                                        showBanner = true
                                    }
                                }
                            })
                }
                
                ForEach(kruskalViewModel.graphViewModel.getVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: kruskalViewModel.graphViewModel, mode: [.showLabels, .noEditLabels])
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                }
            }
            // Banner shown upon completion
            if showBanner {
                VStack {
                    Text("The weight of the minimum spanning tree is: \(kruskalViewModel.getTreeWeight().formatted())")
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
            } else if kruskalViewModel.errorStatus == .cycleError {
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
            } else if kruskalViewModel.errorStatus == .notLowestWeightError {
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
    //KruskalView()
}
