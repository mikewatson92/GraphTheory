//
//  PracticalTSP.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/28/24.
//

import SwiftUI

struct PracticalTSP {
    let originalGraph: Graph
    var step = Step.makeingCompleteAndEuclidean
    
    enum Step {
        case makeingCompleteAndEuclidean
        case solvingClassicalTSP
    }
    
    init(graph: Graph) {
        self.originalGraph = graph
    }
}

class PracticalTSPViewModel: ObservableObject {
    @Published var practicalTSP: PracticalTSP
    @Published var graphViewModel: GraphViewModel
    @Published var error = Error.none
    
    init(graphViewModel: GraphViewModel) {
        self.practicalTSP = PracticalTSP(graph: graphViewModel.graph)
        self.graphViewModel = graphViewModel
    }
    
    enum Error: String {
        case none
        case notSmallestWeight = "The edge weight should be the smallest possible weight between the two vertices."
        case cannotAddSmallerWeight = "You cannot assign a weight for this edge that is smaller than any available path."
        case directEdgeIsAlreadyShortest = "There is already an edge of smallest weight between these vertices."
    }
    
    func addEdge(_ edge: Edge) {
        let directEdges = graphViewModel.graph.getEdgesBetween(edge.startVertexID, edge.endVertexID)
        let startVertex = graphViewModel.graph.vertices[edge.startVertexID]!
        let endVertex = graphViewModel.graph.vertices[edge.endVertexID]!
        let shortestDistance = graphViewModel.graph.smallestDistance(from: startVertex, to: endVertex)
        if directEdges.isEmpty {
            graphViewModel.addEdge(edge)
        } else {
            // Check if there is a direct edge that has the smallest weight
            var directEdgeWeights: [Double] = []
            for edge in directEdges {
                directEdgeWeights.append(edge.weight)
            }
            let minDirectEdgeWeight = directEdgeWeights.min()
            if minDirectEdgeWeight == shortestDistance {
                error = .directEdgeIsAlreadyShortest
            } else {
                graphViewModel.addEdge(edge)
            }
        }
    }
    
    func checkEdgeWeight(_ edge: Edge) {
        let startVertex = graphViewModel.graph.vertices[edge.startVertexID]!
        let endVertex = graphViewModel.graph.vertices[edge.endVertexID]!
        let shortestDistance = practicalTSP.originalGraph.smallestDistance(from: startVertex, to: endVertex)!

        if edge.weight < shortestDistance {
            error = .cannotAddSmallerWeight
        } else if edge.weight > shortestDistance {
            error = .notSmallestWeight
        } else {
            if error == .cannotAddSmallerWeight || error == .notSmallestWeight {
                error = .none
            }
            checkForCompletion()
        }
    }
    
    func checkForCompletion() {
        if graphViewModel.graph.isComplete() && graphViewModel.graph.isEuclidean() {
            practicalTSP.step = .solvingClassicalTSP
        }
    }
}

struct PracticalTSPView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject var practicalTSPViewModel: PracticalTSPViewModel
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var showBanner = true
    @State private var showInstructions = true
        
    func handleVertexTapGesture(_ vertex: Vertex) {
        if let selectedVertex = graphViewModel.selectedVertex {
            if selectedVertex.id == vertex.id {
                graphViewModel.selectedVertex = nil
            } else {
                practicalTSPViewModel.addEdge(Edge(startVertexID: selectedVertex.id, endVertexID: vertex.id))
                graphViewModel.selectedVertex = nil
            }
        } else {
            showInstructions = false
            showBanner = false
            graphViewModel.selectedVertex = vertex
        }
    }
    
    func handleEdgeTapGesture(_ edge: Edge) {
        if let selectedEdge = graphViewModel.selectedEdge {
            if selectedEdge.id == edge.id {
                graphViewModel.selectedEdge = nil
            } else {
                graphViewModel.selectedEdge = edge
            }
        } else {
            graphViewModel.selectedEdge = edge
        }
    }
    
    var body: some View {
        if practicalTSPViewModel.practicalTSP.step == .solvingClassicalTSP {
            ClassicalTSPView(classicalTSPViewModel: ClassicalTSPViewModel(graph: graphViewModel.graph))
        } else {
            VStack {
                if showBanner {
                    if showInstructions {
                        let text = """
                        Make sure the weights of direct edges are the minimum possible weight.
                        Then, turn the graph into a complete Euclidean graph.
                        """
                        Instructions(showBanner: $showBanner, text: text)
                    } else if practicalTSPViewModel.error != .none {
                        Instructions(showBanner: $showBanner, text: practicalTSPViewModel.error.rawValue)
                    }
                }
                GeometryReader { geometry in
                    ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                        EdgeView(edgeViewModel: edgeViewModel, onWeightChange: { practicalTSPViewModel.checkEdgeWeight(edge)
                            if practicalTSPViewModel.error != .none {
                                showBanner = true
                            }
                        })
                        .onTapGesture(count: 1) {
                            handleEdgeTapGesture(edge)
                        }
                    }
                    ForEach(graphViewModel.getVertices(), id: \.id) { vertex in
                        let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                            .shadow(color: graphViewModel.selectedVertex?.id == vertex.id ? .green : .clear, radius: 10)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    handleVertexTapGesture(vertex)
                                }
                            )
                    }
                }
                .onAppear {
                    graphViewModel.showWeights = true
                    graphViewModel.mode = .edit
                }
            }
        }
    }
}

#Preview {
    //PracticalTSPView()
}
