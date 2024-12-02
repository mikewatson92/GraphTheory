//
//  Icosian.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/30/24.
//

import SwiftUI

struct Icosian {
    // The vertices of the outer pentagon
    var A1: Vertex
    var B1: Vertex
    var C1: Vertex
    var D1: Vertex
    var E1: Vertex
    // The vertices of the middle pentagon
    var A2: Vertex
    var B2: Vertex
    var C2: Vertex
    var D2: Vertex
    var E2: Vertex
    // The midpoints of the edges of the middle pentagon
    var midpointAB: Vertex
    var midpointAE: Vertex
    var midpointBC: Vertex
    var midpointCD: Vertex
    var midpointDE: Vertex
    // The vertices of the inner pentagon, starting from
    // the top left.
    var A3: Vertex
    var B3: Vertex
    var C3: Vertex
    var D3: Vertex
    var E3: Vertex
    //
    var vertices: [Vertex]
    // The edges
    // Edges containing an outer vertex
    var edgeA1_B1: Edge
    var edgeA1_A2: Edge
    var edgeA1_E1: Edge
    var edgeB1_C1: Edge
    var edgeB1_B2: Edge
    var edgeC1_D1: Edge
    var edgeC1_C2: Edge
    var edgeD1_E1: Edge
    var edgeD1_D2: Edge
    var edgeE1_E2: Edge
    // Remaining edges containing a middle vertex
    // The edges around the pentagon through the midpoints
    var edgeA_MAB: Edge
    var edgeMAB_B: Edge
    var edgeB_MBC: Edge
    var edgeMBC_C: Edge
    var edgeC_MCD: Edge
    var edgeMCD_D: Edge
    var edgeD_MDE: Edge
    var edgeMDE_E: Edge
    var edgeE_MAE: Edge
    var edgeMAE_A: Edge
    // Edges between a midpoint of the middle pentagon
    // and an edge of the inner pentagon.
    var edgeMAB_B3: Edge
    var edgeMBC_C3: Edge
    var edgeMCD_D3: Edge
    var edgeMDE_E3: Edge
    var edgeMAE_A3: Edge
    // Edges of the inner pentagon
    var edgeA3B3: Edge
    var edgeB3C3: Edge
    var edgeC3D3: Edge
    var edgeD3E3: Edge
    var edgeA3E3: Edge
    // The graph
    var graph: Graph
    // Keep track of what stage of solving the puzzle we are on
    var step = Step.chooseVertex
    
    init() {
        // Initialize the vertex coordinates
        A1 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.900))
        B1 = Vertex(position: CGPoint(x: 0.880, y: 1 - 0.624))
        C1 = Vertex(position: CGPoint(x: 0.735, y: 1 - 0.176))
        D1 = Vertex(position: CGPoint(x: 0.265, y: 1 - 0.176))
        E1 = Vertex(position: CGPoint(x: 0.120, y: 1 - 0.624))
        A2 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.800))
        B2 = Vertex(position: CGPoint(x: 0.785, y: 1 - 0.593))
        C2 = Vertex(position: CGPoint(x: 0.676, y: 1 - 0.257))
        D2 = Vertex(position: CGPoint(x: 0.324, y: 1 - 0.257))
        E2 = Vertex(position: CGPoint(x: 0.215, y: 1 - 0.593))
        midpointAB = Vertex(position: CGPoint(x: 0.643, y: 1 - 0.696))
        midpointAE = Vertex(position: CGPoint(x: 0.357, y: 1 - 0.696))
        midpointBC = Vertex(position: CGPoint(x: 0.731, y: 1 - 0.425))
        midpointCD = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.257))
        midpointDE = Vertex(position: CGPoint(x: 0.269, y: 1 - 0.425))
        A3 = Vertex(position: CGPoint(x: 0.429, y: 1 - 0.598))
        B3 = Vertex(position: CGPoint(x: 0.571, y: 1 - 0.598))
        C3 = Vertex(position: CGPoint(x: 0.615, y: 1 - 0.463))
        D3 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.379))
        E3 = Vertex(position: CGPoint(x: 0.385, y: 1 - 0.463))
        //
        vertices = [A1, B1, C1, D1, E1, A2, B2, C2, D2, E2,
                    midpointAB, midpointAE, midpointBC, midpointCD, midpointDE,
                    A3, B3, C3, D3, E3]
        // The edges
        // Edges containing an outer vertex
        edgeA1_B1 = Edge(startVertexID: A1.id, endVertexID: B1.id)
        edgeA1_A2 = Edge(startVertexID: A1.id, endVertexID: A2.id)
        edgeA1_E1 = Edge(startVertexID: A1.id, endVertexID: E1.id)
        edgeB1_C1 = Edge(startVertexID: B1.id, endVertexID: C1.id)
        edgeB1_B2 = Edge(startVertexID: B1.id, endVertexID: B2.id)
        edgeC1_D1 = Edge(startVertexID: C1.id, endVertexID: D1.id)
        edgeC1_C2 = Edge(startVertexID: C1.id, endVertexID: C2.id)
        edgeD1_E1 = Edge(startVertexID: D1.id, endVertexID: E1.id)
        edgeD1_D2 = Edge(startVertexID: D1.id, endVertexID: D2.id)
        edgeE1_E2 = Edge(startVertexID: E1.id, endVertexID: E2.id)
        // Remaining edges containing a middle vertex
        // The edges around the pentagon through the midpoints
        edgeA_MAB = Edge(startVertexID: A2.id, endVertexID: midpointAB.id)
        edgeMAB_B = Edge(startVertexID: midpointAB.id, endVertexID: B2.id)
        edgeB_MBC = Edge(startVertexID: B2.id, endVertexID: midpointBC.id)
        edgeMBC_C = Edge(startVertexID: midpointBC.id, endVertexID: C2.id)
        edgeC_MCD = Edge(startVertexID: C2.id, endVertexID: midpointCD.id)
        edgeMCD_D = Edge(startVertexID: midpointCD.id, endVertexID: D2.id)
        edgeD_MDE = Edge(startVertexID: D2.id, endVertexID: midpointDE.id)
        edgeMDE_E = Edge(startVertexID: midpointDE.id, endVertexID: E2.id)
        edgeE_MAE = Edge(startVertexID: E2.id, endVertexID: midpointAE.id)
        edgeMAE_A = Edge(startVertexID: midpointAE.id, endVertexID: A2.id)
        // Edges between a midpoint of the middle pentagon
        // and an edge of the inner pentagon.
        edgeMAB_B3 = Edge(startVertexID: midpointAB.id, endVertexID: B3.id)
        edgeMBC_C3 = Edge(startVertexID: midpointBC.id, endVertexID: C3.id)
        edgeMCD_D3 = Edge(startVertexID: midpointCD.id, endVertexID: D3.id)
        edgeMDE_E3 = Edge(startVertexID: midpointDE.id, endVertexID: E3.id)
        edgeMAE_A3 = Edge(startVertexID: midpointAE.id, endVertexID: A3.id)
        // Edges of the inner pentagon
        edgeA3B3 = Edge(startVertexID: A3.id, endVertexID: B3.id)
        edgeB3C3 = Edge(startVertexID: B3.id, endVertexID: C3.id)
        edgeC3D3 = Edge(startVertexID: C3.id, endVertexID: D3.id)
        edgeD3E3 = Edge(startVertexID: D3.id, endVertexID: E3.id)
        edgeA3E3 = Edge(startVertexID: A3.id, endVertexID: E3.id)
        // The graph
        graph = Graph(vertices: [A1, B1, C1, D1, E1, A2, B2, C2, D2, E2,
                                 midpointAB, midpointAE, midpointBC, midpointCD, midpointDE,
                                 A3, B3, C3, D3, E3],
                      edges: [edgeA1_B1, edgeA1_A2, edgeA1_E1, edgeB1_B2, edgeB1_C1, edgeC1_C2, edgeC1_D1, edgeD1_D2, edgeD1_E1, edgeE1_E2, edgeA_MAB, edgeMAB_B, edgeB_MBC, edgeMBC_C, edgeC_MCD, edgeMCD_D, edgeD_MDE, edgeMDE_E, edgeE_MAE, edgeMAE_A, edgeMAE_A3, edgeMAB_B3, edgeMBC_C3, edgeMCD_D3, edgeMDE_E3, edgeA3B3, edgeB3C3, edgeC3D3, edgeD3E3, edgeA3E3])
        graph.mode = .icosian
        graph.resetMethod = .restoreToOriginal
    }
    
    enum Step {
        case chooseVertex, selectingEdges, complete, error
    }
    
    mutating func setStep(_ step: Step) {
        self.step = step
        if step == .complete {
            for vertex in Array(graph.vertices.values) {
                graph.setVertexColor(forID: vertex.id, color: .green)
            }
        }
    }
}

struct IcosianView: View {
    @State private var icosian = Icosian()
    @State private var selectedVertex: Vertex?
    @State private var edgeError: Edge?
    @State private var chosenEdges: [Edge] = []
    @State private var visitedVertices: [Vertex] = []
    
    init() {
        selectedVertex = nil
        edgeError = nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(icosian.graph.edges) { edge in
                let edgeViewModel = EdgeViewModel(
                    edge: edge, size: geometry.size,
                    getVertexPositionByID: { id in icosian.graph.getVertexByID(id)?.position },
                    getShowingWeights: { id in
                        false
                    },
                    setShowingWeights: { id, show in
                        
                    },
                    getOffset: { id in icosian.graph.getOffsetByID(id)},
                    getEdgeControlPoints: { edge in icosian.graph.getEdgeControlPoints(for: edge)},
                    getEdgeControlPointOffsets: { edge in icosian.graph.getEdgeControlPointOffsets(for: edge)},
                    getWeightPosition: { edge in
                        icosian.graph.getEdgeWeightPositionByID(edge.id)
                    },
                    setWeightPosition: { edge, position in
                        icosian.graph.setEdgeWeightPositionByID(id: edge.id, position: position)
                    },
                    getWeightPositionOffset: { edge in
                        icosian.graph.getEdgeWeightOffsetByID(edge.id)!
                    },
                    setWeightPositionOffset: { edge, offset in
                        icosian.graph.setEdgeWeightOffsetByID(id: edge.id, offset: offset)
                    }
                )
                EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
                    .onTapGesture(count: 1) {
                        if icosian.step == .error && edge.id == edgeError?.id {
                            edgeError = nil
                            icosian.setStep(.selectingEdges)
                            icosian.graph.setEdgeColor(edgeID: edge.id, color: .white)
                        } else if icosian.step == .selectingEdges {
                            // Make sure the edge is connected to the selectedVertex
                            if let selectedVertex = selectedVertex {
                                let connectedEdges = icosian.graph.getConnectedEdges(to: selectedVertex.id)
                                // If the edge is connected to selectedVertex
                                if connectedEdges.contains(where: { $0.id == edge.id }) {
                                    var newChosenEdges = chosenEdges
                                    newChosenEdges.append(edge)
                                    let subGraph = Graph(vertices: icosian.vertices, edges: newChosenEdges)
                                    // If the user finishes the game
                                    if subGraph.isHamiltonianCycle() {
                                        icosian.setStep(.complete)
                                        self.selectedVertex = icosian.graph.getVertexByID(edge.traverse(from: selectedVertex.id)!)!
                                        icosian.graph.setVertexColor(forID: selectedVertex.id, color: .green)
                                        for edge in newChosenEdges {
                                            icosian.graph.setEdgeColor(edgeID: edge.id, color: .green)
                                        }
                                    }
                                    // If the user makes a mistake
                                    else if subGraph.hasCycle() {
                                        edgeError = edge
                                        icosian.setStep(.error)
                                        icosian.graph.setEdgeColor(edgeID: edge.id, color: .red)
                                    }
                                    // If the subGraph formed by the sequences of edges is not a premature cycle, and it hasn't been chosen before
                                    else if !subGraph.hasCycle() && !chosenEdges.contains(where: { $0.id == edge.id }) {
                                        if let nextVertexID = edge.traverse(from: selectedVertex.id) {
                                            icosian.graph.setVertexColor(forID: nextVertexID, color: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)))
                                        }
                                        icosian.graph.setEdgeColor(edgeID: edge.id, color: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)))
                                        chosenEdges.append(edge)
                                        self.selectedVertex = icosian.graph.getVertexByID(edge.traverse(from: selectedVertex.id)!)!
                                    }
                                    // If the user wants to backtrack
                                    else if edge.id == chosenEdges.last?.id {
                                        icosian.graph.setVertexColor(forID: selectedVertex.id, color: icosian.graph.originalVertices[selectedVertex.id]!.color)
                                        let newVertexID = edge.traverse(from: selectedVertex.id)!
                                        self.selectedVertex = icosian.graph.getVertexByID(newVertexID)
                                        visitedVertices.removeAll { $0.id == selectedVertex.id }
                                        chosenEdges.removeAll { $0.id == edge.id }
                                        icosian.graph.setEdgeColor(edgeID: edge.id, color: icosian.graph.originalEdges.first { $0.id == edge.id }!.color)
                                    }
                                }
                            }
                        }
                    }
                
            }
            ForEach(Array(icosian.graph.vertices.values)) { vertex in
                let vertexViewModel = VertexViewModel(
                    vertex: vertex,
                    getVertexPosition: { id in icosian.graph.getVertexByID(id)?.position },
                    setVertexPosition: { id, position in icosian.graph.setVertexPosition(forID: id, position: position) },
                    getVertexOffset: { id in icosian.graph.getVertexByID(id)?.offset},
                    setVertexOffset: { id, size in
                        icosian.graph.setVertexOffset(forID: id, size: size)},
                    setVertexColor: { id, color in
                        icosian.graph.setVertexColor(forID: id, color: color)})
                VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                    .shadow(color: vertexViewModel.getVertexID() == selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                    .onTapGesture(count: 1) {
                        // If the user hasn't started the game yet
                        if icosian.step == .chooseVertex && visitedVertices.count == 0 {
                            selectedVertex = vertex
                            icosian.setStep(.selectingEdges)
                            icosian.graph.setVertexColor(forID: vertex.id, color: Color(#colorLiteral(red: 1, green: 0, blue: 0.909978807, alpha: 1)))
                        }
                        // If the user backtracks to the starting position, reset the game.
                        else if icosian.step == .selectingEdges && chosenEdges.count == 0 && vertex.id == selectedVertex?.id {
                            selectedVertex = nil
                            visitedVertices = []
                            icosian.step = .chooseVertex
                            icosian.graph.setVertexColor(forID: vertex.id, color: icosian.graph.originalVertices[vertex.id]!.color)
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Clear") {
                    edgeError = nil
                    icosian.graph.restoreToOriginal()
                    icosian.step = .chooseVertex
                    selectedVertex = nil
                    chosenEdges = []
                    visitedVertices = []
                }
            }
        }
    }
}

#Preview {
    IcosianView()
}
