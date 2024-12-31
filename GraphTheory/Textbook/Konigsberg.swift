//
//  Konigsberg.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/29/24.
//

import SwiftUI

struct Konigsberg {
    let graph: Graph
    
    init() {
        let a = Vertex(position: CGPoint(x: 0.2, y: 0.5))
        let b = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        let c = Vertex(position: CGPoint(x: 0.8, y: 0.5))
        let d = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        var edgeAB1 = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB1.controlPoint1 = CGPoint(x: 0.2, y: 0.35)
        edgeAB1.controlPoint2 = CGPoint(x: 0.4, y: 0.2)
        var edgeAB2 = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB2.controlPoint1 = CGPoint(x: 0.3, y: 0.5)
        edgeAB2.controlPoint2 = CGPoint(x: 0.5, y: 0.35)
        let edgeAC = Edge(startVertexID: a.id, endVertexID: c.id)
        var edgeAD1 = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD1.controlPoint1 = CGPoint(x: 0.2, y: 0.65)
        edgeAD1.controlPoint2 = CGPoint(x: 0.4, y: 0.8)
        var edgeAD2 = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD2.controlPoint1 = CGPoint(x: 0.3, y: 0.5)
        edgeAD2.controlPoint2 = CGPoint(x: 0.5, y: 0.65)
        let edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        let edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        let vertices = [a, b, c, d]
        let edges = [edgeAB1, edgeAB2, edgeAC, edgeAD1, edgeAD2, edgeBC, edgeCD]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.mode = .explore
        graph.resetMethod = .restoreToOriginal
        self.graph = graph
    }
}

struct KonigsbergView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: Konigsberg().graph)
    @State private var step = Step.addOrDeleteEdge {
        willSet {
            showInstructions = true
        }
    }
    @State private var selectedVertex: Vertex?
    @State private var currentVertex: Vertex?
    @State private var selectedEdges: [Edge] = []
    @State private var showInstructions = true
    
    enum Step: String {
        case addOrDeleteEdge = "Select two different vertices to add an edge, or double tap an edge to delete it."
        case chooseStartVertex = "Choose a starting vertex."
        case selectingEdges = "Choose edges to design your walk."
        case finished = "Congratulations, you solved the Seven Bridges of Konigsberg!"
    }
    
    func clear() {
        graphViewModel.clear()
        step = .addOrDeleteEdge
        selectedVertex = nil
        currentVertex = nil
        selectedEdges = []
        showInstructions = true
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if showInstructions {
                    Instructions(showBanner: $showInstructions, text: step.rawValue)
                }
                Spacer()
                Button {
                    clear()
                } label: {
                    Image(systemName: "arrow.uturn.left.circle")
                        .tint(themeViewModel.theme!.accentColor)
                }
                .padding()
            }
            
            GeometryReader { geometry in
                ForEach(graphViewModel.getEdges()) { edge in
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                    EdgeView(edgeViewModel: edgeViewModel)
                        .highPriorityGesture(TapGesture(count: 2)
                            .onEnded {
                                if step == .addOrDeleteEdge {
                                    graphViewModel.removeEdge(edge)
                                    step = .chooseStartVertex
                                    selectedVertex = nil
                                }
                            }
                            .simultaneously(with: TapGesture(count: 1)
                                .onEnded {
                                    
                                    if step == .selectingEdges {
                                        if !selectedEdges.contains(where: { $0.id == edge.id }) &&
                                            graphViewModel.graph.getConnectedEdges(to: currentVertex!.id).contains(where: { $0.id == edge.id }) {
                                            selectedEdges.append(edge)
                                            graphViewModel.setColorForEdge(edge: edge, color: .green)
                                            let nextVertexID = edge.traverse(from: currentVertex!.id)!
                                            currentVertex = graphViewModel.graph.vertices[nextVertexID]!
                                            if selectedEdges.count == graphViewModel.graph.edges.count {
                                                step = .finished
                                            }
                                        } else if edge.id == selectedEdges.last?.id {
                                            let lastVertexID = edge.traverse(from: currentVertex!.id)!
                                            currentVertex = graphViewModel.graph.vertices[lastVertexID]!
                                            graphViewModel.setColorForEdge(edge: edge, color: colorScheme == .light ? .black : .white)
                                            selectedEdges.removeLast()
                                        }
                                    }
                                }
                            )
                        )
                }
                ForEach(graphViewModel.getVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        .shadow(color: (vertex.id == currentVertex?.id || vertex.id == selectedVertex?.id) ? .green : .clear, radius: 10)
                        .highPriorityGesture(TapGesture(count: 1)
                            .onEnded {
                                if step == .chooseStartVertex {
                                    currentVertex = vertex
                                    step = .selectingEdges
                                } else if step == .addOrDeleteEdge {
                                    if let selectedVertex = selectedVertex {
                                        if vertex.id == selectedVertex.id {
                                            self.selectedVertex = nil
                                        } else {
                                            graphViewModel.addEdge(Edge(startVertexID: selectedVertex.id, endVertexID: vertex.id))
                                            self.selectedVertex = nil
                                            step = .chooseStartVertex
                                        }
                                    } else {
                                        selectedVertex = vertex
                                    }
                                } else if step == .selectingEdges && selectedEdges.count == 0 {
                                    if vertex.id == selectedVertex?.id {
                                        selectedVertex = nil
                                        step = .chooseStartVertex
                                    }
                                }
                            }
                        )
                }
            }
        }
    }
}

#Preview {
    KonigsbergView()
        .environmentObject(ThemeViewModel())
}
