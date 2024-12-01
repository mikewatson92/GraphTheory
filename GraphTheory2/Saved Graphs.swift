//
//  Saved Graphs.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/28/24.
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
        
        graph = Graph(vertices: [vertexA1, vertexB1, vertexC1, vertexD1, vertexE1, vertexA2, vertexB2, vertexC2, vertexD2, vertexE2, vertexA3, vertexB3, vertexC3, vertexD3, vertexE3, centerVertex], edges: [edgeA1B1, edgeA1C2, edgeA1A3, edgeA1E2, edgeA1E1, edgeB1A2, edgeB1B3, edgeB1D2, edgeB1C1, edgeC1B2, edgeC1C3, edgeC1E2, edgeC1D1, edgeD1C2, edgeD1D3, edgeD1E1, edgeD1A2, edgeE1D2, edgeE1E3, edgeE1B2, edgeA2A3, edgeA2E3, edgeA2Center, edgeB2B3, edgeB2Center, edgeB2A3, edgeC2B3, edgeC2Center, edgeC2C3, edgeD2C3, edgeD2Center, edgeD2D3, edgeE2D3, edgeE2E3, edgeE2Center, edgeA3C3, edgeA3D3, edgeB3D3, edgeB3E3, edgeC3E3])
        graph.resetMethod = .restoreToOriginal
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

struct Saved_Graphs: View {
    var body: some View {
        GraphView(graphViewModel: GraphViewModel(graph: K33().graph))
    }
}

#Preview {
    Saved_Graphs()
}
