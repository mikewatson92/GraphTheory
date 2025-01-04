//
//  Saved Graphs.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI

struct K33 {
    let a: Vertex
    let b: Vertex
    let c: Vertex
    let d: Vertex
    let e: Vertex
    let f: Vertex
    let edgeAB: Edge
    let edgeBC: Edge
    let edgeCD: Edge
    let edgeDE: Edge
    let edgeEF: Edge
    let edgeFA: Edge
    let edgeCF: Edge
    let edgeAD: Edge
    let edgeBE: Edge
    let graph: Graph
    
    init() {
        a = Vertex(position: CGPoint(x: 0.35, y: 0.2))
        b = Vertex(position: CGPoint(x: 0.65, y: 0.2))
        c = Vertex(position: CGPoint(x: 0.8, y: 0.5))
        d = Vertex(position: CGPoint(x: 0.65, y: 0.8))
        e = Vertex(position: CGPoint(x: 0.35, y: 0.8))
        f = Vertex(position: CGPoint(x: 0.2, y: 0.5))
        
        
        edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeEF = Edge(startVertexID: e.id, endVertexID: f.id)
        edgeFA = Edge(startVertexID: f.id, endVertexID: a.id)
        edgeCF = Edge(startVertexID: c.id, endVertexID: f.id)
        edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        
        let vertices: [Vertex] = [a, b, c, d, e, f]
        let edges: [Edge] = [edgeAB, edgeBC, edgeCD, edgeDE, edgeEF, edgeFA, edgeCF, edgeAD, edgeBE]
        
        graph = Graph(vertices: vertices, edges: edges)
    }
}

struct ClebschGraphCompleteColoring {
    // Outsides vertices for the larger regular pentagon
    var vertexA1 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.900))
    var vertexB1 = Vertex(position: CGPoint(x: 0.880, y: 1 - 0.624))
    var vertexC1 = Vertex(position: CGPoint(x: 0.735, y: 1 - 0.176))
    var vertexD1 = Vertex(position: CGPoint(x: 0.265, y: 1 - 0.176))
    var vertexE1 = Vertex(position: CGPoint(x: 0.120, y: 1 - 0.624))
    // Middle vertices for the medium regular pentagon
    var vertexA2 = Vertex(position: CGPoint(x: 0.338, y: 1 - 0.723))
    var vertexB2 = Vertex(position: CGPoint(x: 0.662, y: 1 - 0.723))
    var vertexC2 = Vertex(position: CGPoint(x: 0.761, y: 1 - 0.415))
    var vertexD2 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.225))
    var vertexE2 = Vertex(position: CGPoint(x: 0.238, y: 1 - 0.415))
    // Inner vertices for the small regular pentagon
    var vertexA3 = Vertex(position: CGPoint(x: 0.500, y: 1 - 0.628))
    var vertexB3 = Vertex(position: CGPoint(x: 0.622, y: 1 - 0.540))
    var vertexC3 = Vertex(position: CGPoint(x: 0.575, y: 1 - 0.396))
    var vertexD3 = Vertex(position: CGPoint(x: 0.426, y: 1 - 0.396))
    var vertexE3 = Vertex(position: CGPoint(x: 0.378, y: 1 - 0.540))
    // Center vertex
    var centerVertex = Vertex(position: CGPoint(x: 0.5, y: 0.5))
    // Edges starting from the top middle outside vertex
    var edgeA1B1: Edge
    var edgeA1C2: Edge
    var edgeA1A3: Edge
    var edgeA1E2: Edge
    var edgeA1E1: Edge
    // Remaining edges starting from the top right outside vertex
    var edgeB1A2: Edge
    var edgeB1B3: Edge
    var edgeB1D2: Edge
    var edgeB1C1: Edge
    // Remaining edges starting from the bottom right outside vertex
    var edgeC1B2: Edge
    var edgeC1C3: Edge
    var edgeC1E2: Edge
    var edgeC1D1: Edge
    // Remaining edges starting from the bottom left outside vertex
    var edgeD1C2: Edge
    var edgeD1D3: Edge
    var edgeD1E1: Edge
    var edgeD1A2: Edge
    // Remaining edges starting from the top left outside vertex
    var edgeE1D2: Edge
    var edgeE1E3: Edge
    var edgeE1B2: Edge
    // Remaining edges starting from the top left middle vertex
    var edgeA2A3: Edge
    var edgeA2E3: Edge
    var edgeA2Center: Edge
    // Remaining edges starting from the top right middle vertex
    var edgeB2B3: Edge
    var edgeB2Center: Edge
    var edgeB2A3: Edge
    // Remaining edges starting from the bottom right middle vertex
    var edgeC2B3: Edge
    var edgeC2Center: Edge
    var edgeC2C3: Edge
    // Remaining edges starting from the bottom middle vertex
    var edgeD2C3: Edge
    var edgeD2Center: Edge
    var edgeD2D3: Edge
    // Remaining edges starting from the bottom left middle vertex
    var edgeE2D3: Edge
    var edgeE2E3: Edge
    var edgeE2Center: Edge
    // The final remaining edges
    var edgeA3C3: Edge
    var edgeA3D3: Edge
    var edgeB3D3: Edge
    var edgeB3E3: Edge
    var edgeC3E3: Edge
    // The graph
    var graph: Graph
    
    init() {
        vertexA1.color = .black
        vertexB1.color = .white
        vertexC1.color = .black
        vertexD1.color = .red
        vertexE1.color = .teal
        vertexA2.color = .green
        vertexB2.color = .green
        vertexC2.color = .blue
        vertexD2.color = .red
        vertexE2.color = .white
        vertexA3.color = .pink
        vertexB3.color = .yellow
        vertexC3.color = .yellow
        vertexD3.color = .teal
        vertexE3.color = .blue
        centerVertex.color = .pink
        
        edgeA1B1 = Edge(startVertexID: vertexA1.id, endVertexID: vertexB1.id)
        edgeA1C2 = Edge(startVertexID: vertexA1.id, endVertexID: vertexC2.id)
        edgeA1A3 = Edge(startVertexID: vertexA1.id, endVertexID: vertexA3.id)
        edgeA1E2 = Edge(startVertexID: vertexA1.id, endVertexID: vertexE2.id)
        edgeA1E1 = Edge(startVertexID: vertexA1.id, endVertexID: vertexE1.id)
        // Remaining edges starting from the top right outside vertex
        edgeB1A2 = Edge(startVertexID: vertexB1.id, endVertexID: vertexA2.id)
        edgeB1B3 = Edge(startVertexID: vertexB1.id, endVertexID: vertexB3.id)
        edgeB1D2 = Edge(startVertexID: vertexB1.id, endVertexID: vertexD2.id)
        edgeB1C1 = Edge(startVertexID: vertexB1.id, endVertexID: vertexC1.id)
        // Remaining edges starting from the bottom right outside vertex
        edgeC1B2 = Edge(startVertexID: vertexC1.id, endVertexID: vertexB2.id)
        edgeC1C3 = Edge(startVertexID: vertexC1.id, endVertexID: vertexC3.id)
        edgeC1E2 = Edge(startVertexID: vertexC1.id, endVertexID: vertexE2.id)
        edgeC1D1 = Edge(startVertexID: vertexC1.id, endVertexID: vertexD1.id)
        // Remaining edges starting from the bottom left outside vertex
        edgeD1C2 = Edge(startVertexID: vertexD1.id, endVertexID: vertexC2.id)
        edgeD1D3 = Edge(startVertexID: vertexD1.id, endVertexID: vertexD3.id)
        edgeD1E1 = Edge(startVertexID: vertexD1.id, endVertexID: vertexE1.id)
        edgeD1A2 = Edge(startVertexID: vertexD1.id, endVertexID: vertexA2.id)
        // Remaining edges starting from the top left outside vertex
        edgeE1D2 = Edge(startVertexID: vertexE1.id, endVertexID: vertexD2.id)
        edgeE1E3 = Edge(startVertexID: vertexE1.id, endVertexID: vertexE3.id)
        edgeE1B2 = Edge(startVertexID: vertexE1.id, endVertexID: vertexB2.id)
        // Remaining edges starting from the top left middle vertex
        edgeA2A3 = Edge(startVertexID: vertexA2.id, endVertexID: vertexA3.id)
        edgeA2E3 = Edge(startVertexID: vertexA2.id, endVertexID: vertexE3.id)
        edgeA2Center = Edge(startVertexID: vertexA2.id, endVertexID: centerVertex.id)
        // Remaining edges starting from the top right middle vertex
        edgeB2B3 = Edge(startVertexID: vertexB2.id, endVertexID: vertexB3.id)
        edgeB2Center = Edge(startVertexID: vertexB2.id, endVertexID: centerVertex.id)
        edgeB2A3 = Edge(startVertexID: vertexB2.id, endVertexID: vertexA3.id)
        // Remaining edges starting from the bottom right middle vertex
        edgeC2B3 = Edge(startVertexID: vertexC2.id, endVertexID: vertexB3.id)
        edgeC2Center = Edge(startVertexID: vertexC2.id, endVertexID: centerVertex.id)
        edgeC2C3 = Edge(startVertexID: vertexC2.id, endVertexID: vertexC3.id)
        // Remaining edges starting from the bottom middle vertex
        edgeD2C3 = Edge(startVertexID: vertexD2.id, endVertexID: vertexC3.id)
        edgeD2Center = Edge(startVertexID: vertexD2.id, endVertexID: centerVertex.id)
        edgeD2D3 = Edge(startVertexID: vertexD2.id, endVertexID: vertexD3.id)
        // Remaining edges starting from the bottom left middle vertex
        edgeE2D3 = Edge(startVertexID: vertexE2.id, endVertexID: vertexD3.id)
        edgeE2E3 = Edge(startVertexID: vertexE2.id, endVertexID: vertexE3.id)
        edgeE2Center = Edge(startVertexID: vertexE2.id, endVertexID: centerVertex.id)
        // The final remaining edges
        edgeA3C3 = Edge(startVertexID: vertexA3.id, endVertexID: vertexC3.id)
        edgeA3D3 = Edge(startVertexID: vertexA3.id, endVertexID: vertexD3.id)
        edgeB3D3 = Edge(startVertexID: vertexB3.id, endVertexID: vertexD3.id)
        edgeB3E3 = Edge(startVertexID: vertexB3.id, endVertexID: vertexE3.id)
        edgeC3E3 = Edge(startVertexID: vertexC3.id, endVertexID: vertexE3.id)
        
        graph = Graph(vertices: [vertexA1, vertexB1, vertexC1, vertexD1, vertexE1, vertexA2, vertexB2, vertexC2, vertexD2, vertexE2, vertexA3, vertexB3, vertexC3, vertexD3, vertexE3, centerVertex],
                      edges: [edgeA1B1, edgeA1C2, edgeA1A3, edgeA1E2, edgeA1E1, edgeB1A2, edgeB1B3, edgeB1D2, edgeB1C1, edgeC1B2, edgeC1C3, edgeC1E2, edgeC1D1, edgeD1C2, edgeD1D3, edgeD1E1, edgeD1A2, edgeE1D2, edgeE1E3, edgeE1B2, edgeA2A3, edgeA2E3, edgeA2Center, edgeB2B3, edgeB2Center, edgeB2A3, edgeC2B3, edgeC2Center, edgeC2C3, edgeD2C3, edgeD2Center, edgeD2D3, edgeE2D3, edgeE2E3, edgeE2Center, edgeA3C3, edgeA3D3, edgeB3D3, edgeB3E3, edgeC3E3])
        graph.resetMethod = .restoreToOriginal
    }
}

struct ClebschGraphCompleteColoringView: View {
    @StateObject private var clebschGraphViewModel = GraphViewModel(graph: ClebschGraphCompleteColoring().graph)
    var body: some View {
        GraphView(graphViewModel: clebschGraphViewModel)
    }
}

struct PetersonGraph {
    // The vertices of the outer pentagon
    var A1: Vertex
    var B1: Vertex
    var C1: Vertex
    var D1: Vertex
    var E1: Vertex
    // The vertices of the inner pentagon
    var A2: Vertex
    var B2: Vertex
    var C2: Vertex
    var D2: Vertex
    var E2: Vertex
    // The edges
    var edgeA1B1: Edge
    var edgeA1A2: Edge
    var edgeA1E1: Edge
    var edgeB1C1: Edge
    var edgeB1B2: Edge
    var edgeC1D1: Edge
    var edgeC1C2: Edge
    var edgeD1E1: Edge
    var edgeD1D2: Edge
    var edgeE1E2: Edge
    var edgeA2C2: Edge
    var edgeA2D2: Edge
    var edgeB2D2: Edge
    var edgeB2E2: Edge
    var edgeC2E2: Edge
    // The graph
    var graph: Graph
    
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
        // Set the vertex colors
        A1.color = .pink
        B1.color = .teal
        C1.color = .green
        D1.color = .pink
        E1.color = .teal
        A2.color = .teal
        B2.color = .pink
        C2.color = .pink
        D2.color = .green
        E2.color = .green
        // Initialize the edges
        edgeA1B1 = Edge(startVertexID: A1.id, endVertexID: B1.id)
        edgeA1A2 = Edge(startVertexID: A1.id, endVertexID: A2.id)
        edgeA1E1 = Edge(startVertexID: A1.id, endVertexID: E1.id)
        edgeB1C1 = Edge(startVertexID: B1.id, endVertexID: C1.id)
        edgeB1B2 = Edge(startVertexID: B1.id, endVertexID: B2.id)
        edgeC1D1 = Edge(startVertexID: C1.id, endVertexID: D1.id)
        edgeC1C2 = Edge(startVertexID: C1.id, endVertexID: C2.id)
        edgeD1E1 = Edge(startVertexID: D1.id, endVertexID: E1.id)
        edgeD1D2 = Edge(startVertexID: D1.id, endVertexID: D2.id)
        edgeE1E2 = Edge(startVertexID: E1.id, endVertexID: E2.id)
        edgeA2C2 = Edge(startVertexID: A2.id, endVertexID: C2.id)
        edgeA2D2 = Edge(startVertexID: A2.id, endVertexID: D2.id)
        edgeB2D2 = Edge(startVertexID: B2.id, endVertexID: D2.id)
        edgeB2E2 = Edge(startVertexID: B2.id, endVertexID: E2.id)
        edgeC2E2 = Edge(startVertexID: C2.id, endVertexID: E2.id)
        // Initialize the graph
        graph = Graph(vertices: [A1, B1, C1, D1, E1, A2, B2, C2, D2, E2], edges: [edgeA1B1, edgeA1A2, edgeA1E1, edgeB1C1, edgeB1B2, edgeC1D1, edgeC1C2, edgeD1E1, edgeD1D2, edgeE1E2, edgeA2C2, edgeA2D2, edgeB2D2, edgeB2E2, edgeC2E2])
        graph.resetMethod = .restoreToOriginal
    }
}

struct PetersonView: View {
    @StateObject private var petersonGraphViewModel = GraphViewModel(graph: PetersonGraph().graph)
    var body: some View {
        GraphView(graphViewModel: petersonGraphViewModel)
    }
}

struct ComplexPolygon {
    // The vertices
    // Outer vertices
    var A1: Vertex
    var B1: Vertex
    var C1: Vertex
    var D1: Vertex
    var E1: Vertex
    var F1: Vertex
    var G1: Vertex
    var H1: Vertex
    // Inner vertices
    var A2: Vertex
    var B2: Vertex
    var C2: Vertex
    var D2: Vertex
    var E2: Vertex
    var F2: Vertex
    var G2: Vertex
    var H2: Vertex
    // The edges
    // Edges starting from an outer vertex
    var edgeA1B1: Edge
    var edgeA1B2: Edge
    var edgeA1H2: Edge
    var edgeA1H1: Edge
    var edgeB1C1: Edge
    var edgeB1C2: Edge
    var edgeB1A2: Edge
    var edgeC1D1: Edge
    var edgeC1D2: Edge
    var edgeC1B2: Edge
    var edgeD1E1: Edge
    var edgeD1E2: Edge
    var edgeD1C2: Edge
    var edgeE1F1: Edge
    var edgeE1F2: Edge
    var edgeE1D2: Edge
    var edgeF1G1: Edge
    var edgeF1G2: Edge
    var edgeF1E2: Edge
    var edgeG1H1: Edge
    var edgeG1F2: Edge
    var edgeG1H2: Edge
    var edgeH1G2: Edge
    var edgeH1A2: Edge
    // Remaining edges starting from an inner vertex
    var edgeA2D2: Edge
    var edgeA2F2: Edge
    var edgeB2E2: Edge
    var edgeB2G2: Edge
    var edgeC2F2: Edge
    var edgeC2H2: Edge
    var edgeD2G2: Edge
    var edgeE2H2: Edge
    // The graph
    var graph: Graph
    
    init() {
        // Initialize the vertices
        A1 = Vertex(position: CGPoint(x: 0.347, y: 1 - 0.870))
        B1 = Vertex(position: CGPoint(x: 0.653, y: 1 - 0.870))
        C1 = Vertex(position: CGPoint(x: 0.870, y: 1 - 0.653))
        D1 = Vertex(position: CGPoint(x: 0.870, y: 1 - 0.347))
        E1 = Vertex(position: CGPoint(x: 0.653, y: 1 - 0.130))
        F1 = Vertex(position: CGPoint(x: 0.347, y: 1 - 0.130))
        G1 = Vertex(position: CGPoint(x: 0.130, y: 1 - 0.347))
        H1 = Vertex(position: CGPoint(x: 0.130, y: 1 - 0.653))
        A2 = Vertex(position: CGPoint(x: 0.423, y: 1 - 0.685))
        B2 = Vertex(position: CGPoint(x: 0.577, y: 1 - 0.685))
        C2 = Vertex(position: CGPoint(x: 0.685, y: 1 - 0.577))
        D2 = Vertex(position: CGPoint(x: 0.685, y: 1 - 0.423))
        E2 = Vertex(position: CGPoint(x: 0.577, y: 1 - 0.315))
        F2 = Vertex(position: CGPoint(x: 0.423, y: 1 - 0.315))
        G2 = Vertex(position: CGPoint(x: 0.315, y: 1 - 0.423))
        H2 = Vertex(position: CGPoint(x: 0.315, y: 1 - 0.577))
        // Set the vertex colors
        A1.color = .green
        B1.color = .green
        C1.color = .green
        D1.color = .green
        E1.color = .green
        F1.color = .green
        G1.color = .green
        H1.color = .green
        A2.color = .green
        B2.color = .green
        C2.color = .green
        D2.color = .green
        E2.color = .green
        F2.color = .green
        G2.color = .green
        H2.color = .green
        // Initialize the edges
        edgeA1B1 = Edge(startVertexID: A1.id, endVertexID: B1.id)
        edgeA1B2 = Edge(startVertexID: A1.id, endVertexID: B2.id)
        edgeA1H2 = Edge(startVertexID: A1.id, endVertexID: H2.id)
        edgeA1H1 = Edge(startVertexID: A1.id, endVertexID: H1.id)
        edgeB1C1 = Edge(startVertexID: B1.id, endVertexID: C1.id)
        edgeB1C2 = Edge(startVertexID: B1.id, endVertexID: C2.id)
        edgeB1A2 = Edge(startVertexID: B1.id, endVertexID: A2.id)
        edgeC1D1 = Edge(startVertexID: C1.id, endVertexID: D1.id)
        edgeC1D2 = Edge(startVertexID: C1.id, endVertexID: D2.id)
        edgeC1B2 = Edge(startVertexID: C1.id, endVertexID: B2.id)
        edgeD1E1 = Edge(startVertexID: D1.id, endVertexID: E1.id)
        edgeD1E2 = Edge(startVertexID: D1.id, endVertexID: E2.id)
        edgeD1C2 = Edge(startVertexID: D1.id, endVertexID: C2.id)
        edgeE1F1 = Edge(startVertexID: E1.id, endVertexID: F1.id)
        edgeE1F2 = Edge(startVertexID: E1.id, endVertexID: F2.id)
        edgeE1D2 = Edge(startVertexID: E1.id, endVertexID: D2.id)
        edgeF1G1 = Edge(startVertexID: F1.id, endVertexID: G1.id)
        edgeF1G2 = Edge(startVertexID: F1.id, endVertexID: G2.id)
        edgeF1E2 = Edge(startVertexID: F1.id, endVertexID: E2.id)
        edgeG1H1 = Edge(startVertexID: G1.id, endVertexID: H1.id)
        edgeG1F2 = Edge(startVertexID: G1.id, endVertexID: F2.id)
        edgeG1H2 = Edge(startVertexID: G1.id, endVertexID: H2.id)
        edgeH1G2 = Edge(startVertexID: H1.id, endVertexID: G2.id)
        edgeH1A2 = Edge(startVertexID: H1.id, endVertexID: A2.id)
        // Initialize remaining edges starting from an inner vertex
        edgeA2D2 = Edge(startVertexID: A2.id, endVertexID: D2.id)
        edgeA2F2 = Edge(startVertexID: A2.id, endVertexID: F2.id)
        edgeB2E2 = Edge(startVertexID: B2.id, endVertexID: E2.id)
        edgeB2G2 = Edge(startVertexID: B2.id, endVertexID: G2.id)
        edgeC2F2 = Edge(startVertexID: C2.id, endVertexID: F2.id)
        edgeC2H2 = Edge(startVertexID: C2.id, endVertexID: H2.id)
        edgeD2G2 = Edge(startVertexID: D2.id, endVertexID: G2.id)
        edgeE2H2 = Edge(startVertexID: E2.id, endVertexID: H2.id)
        // Set the edge colors
        edgeA1B1.color = .blue
        edgeA1B2.color = .red
        edgeA1H2.color = .blue
        edgeA1H1.color = .red
        edgeB1C1.color = .red
        edgeB1C2.color = .blue
        edgeB1A2.color = .red
        edgeC1D1.color = .blue
        edgeC1D2.color = .red
        edgeC1B2.color = .blue
        edgeD1E1.color = .red
        edgeD1E2.color = .blue
        edgeD1C2.color = .red
        edgeE1F1.color = .blue
        edgeE1F2.color = .red
        edgeE1D2.color = .blue
        edgeF1G1.color = .red
        edgeF1G2.color = .blue
        edgeF1E2.color = .red
        edgeG1H1.color = .blue
        edgeG1F2.color = .blue
        edgeG1H2.color = .red
        edgeH1G2.color = .red
        edgeH1A2.color = .blue
        // Initialize remaining edges starting from an inner vertex
        edgeA2D2.color = .red
        edgeA2F2.color = .blue
        edgeB2E2.color = .blue
        edgeB2G2.color = .red
        edgeC2F2.color = .red
        edgeC2H2.color = .blue
        edgeD2G2.color = .blue
        edgeE2H2.color = .red
        graph = Graph(vertices: [A1, B1, C1, D1, E1, F1, G1, H1, A2, B2, C2, D2, E2, F2, G2, H2], edges: [edgeA1B1, edgeA1B2, edgeA1H2, edgeA1H1, edgeB1C1, edgeB1C2, edgeB1A2, edgeC1D1, edgeC1D2, edgeC1B2, edgeD1E1, edgeD1E2, edgeD1C2, edgeE1F1, edgeE1F2, edgeE1D2, edgeF1G1, edgeF1G2, edgeF1E2, edgeG1H1, edgeG1F2, edgeG1H2, edgeH1G2, edgeH1A2, edgeA2D2, edgeA2F2, edgeB2E2, edgeB2G2, edgeC2F2, edgeC2H2, edgeD2G2, edgeE2H2])
        graph.resetMethod = .restoreToOriginal
    }
}

struct ComplexPolygonView: View {
    @StateObject private var complexPolygonGraphViewModel = GraphViewModel(graph: ComplexPolygon().graph)
    
    var body: some View {
        GraphView(graphViewModel: complexPolygonGraphViewModel)
    }
}

struct Kruskal1 {
    var graph: Graph
    
    init() {
        var vertex0 = Vertex(position: CGPoint(x: 0.1, y: 0.5))
        vertex0.label = "0"
        var vertex1 = Vertex(position: CGPoint(x: 0.3, y: 0.2))
        vertex1.label = "1"
        var vertex2 = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        vertex2.label = "2"
        var vertex3 = Vertex(position: CGPoint(x: 0.7, y: 0.2))
        vertex3.label = "3"
        var vertex4 = Vertex(position: CGPoint(x: 0.9, y: 0.5))
        vertex4.label = "4"
        var vertex5 = Vertex(position: CGPoint(x: 0.7, y: 0.8))
        vertex5.label = "5"
        var vertex6 = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        vertex6.label = "6"
        var vertex7 = Vertex(position: CGPoint(x: 0.3, y: 0.8))
        vertex7.label = "7"
        var vertex8 = Vertex(position: CGPoint(x: 0.5, y: 0.5))
        vertex8.label = "8"
        var edge01 = Edge(startVertexID: vertex0.id, endVertexID: vertex1.id)
        edge01.weight = 4
        var edge07 = Edge(startVertexID: vertex0.id, endVertexID: vertex7.id)
        edge07.weight = 8
        var edge12 = Edge(startVertexID: vertex1.id, endVertexID: vertex2.id)
        edge12.weight = 8
        var edge17 = Edge(startVertexID: vertex1.id, endVertexID: vertex7.id)
        edge17.weight = 11
        var edge23 = Edge(startVertexID: vertex2.id, endVertexID: vertex3.id)
        edge23.weight = 7
        var edge25 = Edge(startVertexID: vertex2.id, endVertexID: vertex5.id)
        edge25.weight = 4
        var edge28 = Edge(startVertexID: vertex2.id, endVertexID: vertex8.id)
        edge28.weight = 2
        edge28.sign = -1
        var edge34 = Edge(startVertexID: vertex3.id, endVertexID: vertex4.id)
        edge34.weight = 9
        var edge35 = Edge(startVertexID: vertex3.id, endVertexID: vertex5.id)
        edge35.weight = 14
        var edge45 = Edge(startVertexID: vertex4.id, endVertexID: vertex5.id)
        edge45.weight = 10
        var edge56 = Edge(startVertexID: vertex5.id, endVertexID: vertex6.id)
        edge56.weight = 2
        var edge67 = Edge(startVertexID: vertex6.id, endVertexID: vertex7.id)
        edge67.weight = 1
        var edge68 = Edge(startVertexID: vertex6.id, endVertexID: vertex8.id)
        edge68.weight = 6
        var edge78 = Edge(startVertexID: vertex7.id, endVertexID: vertex8.id)
        edge78.weight = 7
        let vertices = [vertex0, vertex1, vertex2, vertex3, vertex4, vertex5, vertex6, vertex7, vertex8]
        let edges = [edge01, edge07, edge12, edge17, edge23, edge25, edge28, edge34, edge35, edge45, edge56, edge67, edge68, edge78]
        self.graph = Graph(vertices: vertices, edges: edges)
    }
}

struct Kruskal1View: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var kruskalViewModel = KruskalViewModel(graphViewModel: GraphViewModel(graph: Kruskal1().graph))
    
    var body: some View {
        KruskalView(kruskalViewModel: kruskalViewModel, completion: .constant(false))
    }
}

struct ChinesePostman1 {
    var graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.2, y: 0.3))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.8, y: 0.3))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.8, y: 0.7))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.2, y: 0.7))
        d.label = "D"
        var e = Vertex(position: CGPoint(x: 0.5, y: 0.5))
        e.label = "E"
        var edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB.weight = 9
        var edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD.weight = 6
        var edgeAE = Edge(startVertexID: a.id, endVertexID: e.id)
        edgeAE.weight = 3
        var edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeBC.weight = 8
        var edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        edgeBE.weight = 5
        var edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeCD.weight = 7
        var edgeCE = Edge(startVertexID: c.id, endVertexID: e.id)
        edgeCE.weight = 4
        var edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeDE.weight = 2
        self.graph = Graph(vertices: [a, b, c, d, e], edges: [edgeAB, edgeAD, edgeAE, edgeBC, edgeBE, edgeCD, edgeCE, edgeDE])
    }
}

struct ChinesePostman1View: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var chinesePostmanViewModel = ChinesePostmanViewModel(graph: ChinesePostman1().graph)
    
    var body: some View {
        ChinesePostmanView(graph: ChinesePostman1().graph)
    }
}

struct ClassicalTSP1 {
    var graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.8, y: 0.2))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.8, y: 0.8))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        d.label = "D"
        var e = Vertex(position: CGPoint(x: 0.2, y: 0.5))
        e.label = "E"
        var edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB.weight = 10
        edgeAB.sign = -1
        var edgeAC = Edge(startVertexID: a.id, endVertexID: c.id)
        edgeAC.weight = 5
        edgeAC.weightPositionParameterT = 0.7
        var edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD.weight = 8
        edgeAD.sign = -1
        var edgeAE = Edge(startVertexID: a.id, endVertexID: e.id)
        edgeAE.weight = 7
        edgeAE.sign = -1
        var edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeBC.weight = 8
        var edgeBD = Edge(startVertexID: b.id, endVertexID: d.id)
        edgeBD.weight = 6
        edgeBD.weightPositionParameterT = 0.3
        var edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        edgeBE.weight = 6
        edgeBE.weightPositionParameterT = 0.7
        var edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeCD.weight = 9
        var edgeCE = Edge(startVertexID: c.id, endVertexID: e.id)
        edgeCE.weight = 7
        edgeCE.weightPositionParameterT = 0.3
        var edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeDE.weight = 4
        edgeDE.sign = -1
        self.graph = Graph(vertices: [a, b, c, d, e], edges: [edgeAB, edgeAC, edgeAD, edgeAE, edgeBC, edgeBD, edgeBE, edgeCD, edgeCE, edgeDE])
    }
}

struct ClassicalTSP1View: View {
    
    var body: some View {
        ClassicalTSPView(graph: ClassicalTSP1().graph)
    }
}

struct PracticalTSP1 {
    let graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.25, y: 0.2))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.7, y: 0.3))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.5, y: 0.5))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.6, y: 0.8))
        d.label = "D"
        var e = Vertex(position: CGPoint(x: 0.3, y: 0.65))
        e.label = "E"
        var edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB.weight = 30
        var edgeAC = Edge(startVertexID: a.id, endVertexID: c.id)
        edgeAC.weight = 45
        var edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeBC.weight = 35
        var edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeCD.weight = 60
        var edgeCE = Edge(startVertexID: c.id, endVertexID: e.id)
        edgeCE.weight = 25
        var edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeDE.weight = 30
        graph = Graph(vertices: [a, b, c, d, e], edges: [edgeAB, edgeAC, edgeBC, edgeCD, edgeCE, edgeDE])
    }
}

struct PracticalTSP1View: View {
    
    var body: some View {
        PracticalTSPView(graph: PracticalTSP1().graph)
    }
}
