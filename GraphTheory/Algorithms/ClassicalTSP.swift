//
//  ClassicalTSP.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/27/24.
//

import SwiftUI

struct ClassicalTSP {
    let graph: Graph
    var step = Step.choosingStartVertex
    var nearestNeighborStartVertex: Vertex?
    var nearestNeighborEdges: [Edge] = []
    var nearestNeighborVisitedVertices: [Vertex] = []
    var deletedVertex: Vertex?
    var deletedEdges: [Edge] = []
    var addBackEdges: [Edge] = []
    var upperBound = 0.0
    var lowerBound = 0.0
    
    init(graph: Graph) {
        self.graph = graph
    }
    
    enum Step: String {
        case choosingStartVertex = "Choose a starting vertex."
        case findingUpperBound = "Apply the nearest neighbor algorithm."
        case deletingVertex = "Tap a vertex to delete it."
        case findingMinimumSpanningTree = "Apply Kruskal's algorithm to find a minimum spanning tree."
        case addBackEdges = "Add back the two smallest weight edges that were deleted."
        case finished
    }
}

class ClassicalTSPViewModel: ObservableObject {
    @Published private(set) var classicalTSP: ClassicalTSP
    @Published var graphViewModel: GraphViewModel
    @Published var deletedVertexGraphViewModel: GraphViewModel
    @Published var edgeError: Edge?
    @Published var nearestNeighborCurrentVertex: Vertex?
    @Published var kruskalViewModel = KruskalViewModel(graphViewModel: GraphViewModel(graph: Graph()))
    var themeViewModel = ThemeViewModel()
    var deletedVertexGraph: Graph
    var step: ClassicalTSP.Step {
        get {
            classicalTSP.step
        } set {
            classicalTSP.step = newValue
        }
    }
    var upperBound: Double {
        classicalTSP.upperBound
    }
    var lowerBound: Double {
        classicalTSP.lowerBound
    }
    init(graph: Graph) {
        self.classicalTSP = ClassicalTSP(graph: graph)
        self.graphViewModel = GraphViewModel(graph: graph, showWeights: true)
        self.deletedVertexGraph = graph
        self.deletedVertexGraphViewModel = GraphViewModel(graph: graph, showWeights: true)
        self.kruskalViewModel = KruskalViewModel(graphViewModel: deletedVertexGraphViewModel)
    }
    
    func chooseVertex(_ vertex: Vertex) {
        if classicalTSP.step == .choosingStartVertex {
            classicalTSP.nearestNeighborStartVertex = vertex
            nearestNeighborCurrentVertex = vertex
            classicalTSP.step = .findingUpperBound
            classicalTSP.nearestNeighborVisitedVertices.append(vertex)
        } else if classicalTSP.step == .deletingVertex {
            classicalTSP.deletedVertex = vertex
            graphViewModel.setVertexOpacity(vertex: vertex, opacity: 0.5)
            for edge in classicalTSP.graph.getConnectedEdges(to: vertex.id) {
                graphViewModel.setEdgeStrokeStyle(edge: edge, strokeStyle: .dashed)
                classicalTSP.deletedEdges.append(edge)
            }
            // Remove the deleted vertex and all connected edges from the subgraph
            withAnimation {
                deletedVertexGraphViewModel.removeVertex(vertex)
                classicalTSP.step = .findingMinimumSpanningTree
                kruskalViewModel = KruskalViewModel(graphViewModel: deletedVertexGraphViewModel)
            }
        }
    }
    
    @MainActor
    func chooseEdge(_ edge: Edge) async {
        if let edgeError = edgeError {
            if edge.id == edgeError.id {
                self.edgeError = nil
                graphViewModel.setColorForEdge(edge: edge, color: graphViewModel.graph.originalEdges[edge.id]?.color)
            }
        } else if classicalTSP.step == .findingUpperBound {
            var availableEdges = classicalTSP.graph.getConnectedEdges(to: nearestNeighborCurrentVertex!.id)
            for edge in classicalTSP.nearestNeighborEdges {
                availableEdges.removeAll(where: { $0.id == edge.id })
            }
            for edge in availableEdges {
                if classicalTSP.nearestNeighborVisitedVertices.contains(where: { $0.id == edge.startVertexID }) &&
                    classicalTSP.nearestNeighborVisitedVertices.contains(where: { $0.id == edge.endVertexID }) {
                    availableEdges.removeAll(where: { $0.id == edge.id })
                }
            }
            var availableEdgeWeights: [Double] = []
            for edge in availableEdges {
                availableEdgeWeights.append(edge.weight)
            }
            let minimumWeight = availableEdgeWeights.min()
            if classicalTSP.nearestNeighborVisitedVertices.count < classicalTSP.graph.vertices.count {
                if edge.weight == minimumWeight {
                    classicalTSP.nearestNeighborEdges.append(edge)
                    graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
                    let nextVertexID = edge.traverse(from: nearestNeighborCurrentVertex!.id)!
                    let nextVertex = classicalTSP.graph.vertices[nextVertexID]!
                    nearestNeighborCurrentVertex = nextVertex
                    if !classicalTSP.nearestNeighborVisitedVertices.contains(where: { $0.id == nextVertexID }) {
                        classicalTSP.nearestNeighborVisitedVertices.append(nextVertex)
                    }
                } else { // If there was an error
                    if !classicalTSP.nearestNeighborEdges.contains(where: { $0.id == edge.id }) {
                        edgeError = edge
                        graphViewModel.setColorForEdge(edge: edge, color: .red)
                    }
                }
            } else { // If this is the final edge for the nearest neighbor algorithm
                var finalEdgeWeights: [Double] = []
                for edge in Array(classicalTSP.graph.edges.values) {
                    if (edge.startVertexID == nearestNeighborCurrentVertex!.id && edge.endVertexID == classicalTSP.nearestNeighborStartVertex!.id) ||
                        (edge.startVertexID == classicalTSP.nearestNeighborStartVertex!.id && edge.endVertexID == nearestNeighborCurrentVertex!.id) {
                        finalEdgeWeights.append(edge.weight)
                    }
                }
                let minWeight = finalEdgeWeights.min()
                if edge.weight == minWeight {
                    classicalTSP.nearestNeighborEdges.append(edge)
                    graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        computeUpperBound()
                        nearestNeighborCurrentVertex = nil
                        classicalTSP.step = .deletingVertex
                        // Reset the edge colors
                        for edge in classicalTSP.nearestNeighborEdges {
                            graphViewModel.setColorForEdge(edge: edge, color: graphViewModel.graph.originalEdges[edge.id]?.color)
                        }
                    }
                } else { // If there was an error
                    edgeError = edge
                    graphViewModel.setColorForEdge(edge: edge, color: .red)
                }
            }
        } else if classicalTSP.step == .findingMinimumSpanningTree {
            if deletedVertexGraph.edges.values.contains(where: { $0.id == edge.id }) {
                kruskalViewModel.chooseEdge(edge)
                if kruskalViewModel.errorStatus == .none {
                    classicalTSP.lowerBound += edge.weight
                    graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
                }
                if kruskalViewModel.completionStatus == .completed {
                    classicalTSP.step = .addBackEdges
                }
            }
        } else if classicalTSP.step == .addBackEdges {
            var deletedEdgeWeights: [Double] = []
            for edge in classicalTSP.deletedEdges {
                deletedEdgeWeights.append(edge.weight)
            }
            if edge.weight == deletedEdgeWeights.min() {
                classicalTSP.deletedEdges.removeAll(where: { $0.id == edge.id })
                graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
                classicalTSP.addBackEdges.append(edge)
                classicalTSP.lowerBound += edge.weight
            } else { // If there is an error
                graphViewModel.setColorForEdge(edge: edge, color: .red)
                edgeError = edge
            }
            if classicalTSP.addBackEdges.count == 2 {
                computeLowerBound()
                classicalTSP.step = .finished
            }
        }
    }
    
    func computeUpperBound() {
        for edge in classicalTSP.nearestNeighborEdges {
            classicalTSP.upperBound += edge.weight
        }
    }
    
    func computeLowerBound() {
        classicalTSP.lowerBound = kruskalViewModel.getTreeWeight() + classicalTSP.addBackEdges[0].weight + classicalTSP.addBackEdges[1].weight
    }
}

struct ClassicalTSPView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var classicalTSPViewModel: ClassicalTSPViewModel
    @State private var showBanner = true
    @State private var kruskalComplete = false
    @State private var showKruskalInstructions = true
    
    init(graph: Graph) {
        _classicalTSPViewModel = StateObject(wrappedValue: ClassicalTSPViewModel(graph: graph))
    }
    
    var body: some View {
        if !classicalTSPViewModel.graphViewModel.graph.isComplete() || !classicalTSPViewModel.graphViewModel.graph.isEuclidean() {
            Text("In order to apply the classical travelling salesman problem, the graph must be both complete and have the Euclidean property.")
                .padding()
        } else if classicalTSPViewModel.step == .findingMinimumSpanningTree && !kruskalComplete {
            VStack {
                KruskalView(kruskalViewModel: classicalTSPViewModel.kruskalViewModel, completion: $kruskalComplete)
            }
            .transition(.opacity)
        } else {
            VStack {
                if showBanner {
                    if classicalTSPViewModel.step != .finished {
                        Instructions(showBanner: $showBanner, text: classicalTSPViewModel.step.rawValue)
                            .transition(.move(edge: .top))
                    } else {
                        let text = """
                        The upper bound is: \(classicalTSPViewModel.upperBound.formatted())
                        The lower bound is: \(classicalTSPViewModel.lowerBound.formatted())
                        """
                        Instructions(showBanner: $showBanner, text: text)
                            .transition(.move(edge: .top))
                    }
                }
                GeometryReader { geometry in
                    ForEach(classicalTSPViewModel.graphViewModel.getEdges(), id: \.id) { edge in
                        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: classicalTSPViewModel.graphViewModel)
                        EdgeView(edgeViewModel: edgeViewModel)
                            .highPriorityGesture(TapGesture(count: 1).onEnded({ _ in
                                let previousStep = classicalTSPViewModel.step
                                Task {
                                    await classicalTSPViewModel.chooseEdge(edge)
                                }
                                let currentStep = classicalTSPViewModel.step
                                if previousStep != currentStep {
                                    showBanner = true
                                }
                            }))
                    }
                    ForEach(classicalTSPViewModel.graphViewModel.getVertices()) { vertex in
                        let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: classicalTSPViewModel.graphViewModel)
                        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                            .shadow(color: (vertex.id == classicalTSPViewModel.nearestNeighborCurrentVertex?.id ? themeViewModel.theme!.accent : Color.clear), radius: 10)
                            .highPriorityGesture(TapGesture(count: 1).onEnded({ _ in
                                let previousStep = classicalTSPViewModel.step
                                classicalTSPViewModel.chooseVertex(vertex)
                                let currentStep = classicalTSPViewModel.step
                                if previousStep != currentStep {
                                    showBanner = true
                                }
                            }))
                    }
                }
            }
            .transition(.opacity)
            .onAppear {
                classicalTSPViewModel.themeViewModel = themeViewModel
                if classicalTSPViewModel.step == .findingMinimumSpanningTree && classicalTSPViewModel.kruskalViewModel.completionStatus == .completed {
                    classicalTSPViewModel.step = .addBackEdges
                    for edge in classicalTSPViewModel.kruskalViewModel.kruskal.subGraph.edges.values {
                        classicalTSPViewModel.graphViewModel.setColorForEdge(edge: edge, color: themeViewModel.theme!.accent)
                        classicalTSPViewModel.graphViewModel.setVertexOpacity(vertex: classicalTSPViewModel.classicalTSP.deletedVertex!, opacity: 1)
                    }
                }
            }
        }
    }
}

#Preview {
    //ClassicalTSPView()
}
