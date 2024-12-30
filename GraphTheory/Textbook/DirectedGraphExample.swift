//
//  DirectedGraphExample.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct DirectedGraphExample {
    let graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.1, y: 0.2))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.9, y: 0.1))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.5, y: 0.6))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.3, y: 0.9))
        d.label = "D"
        var e = Vertex(position: CGPoint(x: 0.25, y: 0.5))
        e.label = "E"
        var edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB.directed = .forward
        edgeAB.controlPoint1 = CGPoint(x: 0.3, y: 0.05)
        edgeAB.controlPoint2 = CGPoint(x: 0.7, y: 0.05)
        var edgeAE = Edge(startVertexID: a.id, endVertexID: e.id)
        edgeAE.directed = .reverse
        var edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeBC.directed = .forward
        var edgeBD = Edge(startVertexID: b.id, endVertexID: d.id)
        edgeBD.directed = .bidirectional
        edgeBD.controlPoint1 = CGPoint(x: 0.9, y: 0.5)
        edgeBD.controlPoint2 = CGPoint(x: 0.5, y: 0.8)
        var edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        edgeBE.directed = .bidirectional
        var edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeCD.directed = .forward
        var edgeCE = Edge(startVertexID: c.id, endVertexID: e.id)
        edgeCE.directed = .reverse
        var edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeDE.directed = .forward
        let vertices = [a, b, c, d, e]
        let edges = [edgeAB, edgeAE, edgeBC, edgeBD, edgeBE, edgeCD, edgeCE, edgeDE]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.resetMethod = .restoreToOriginal
        self.graph = graph
    }
}

struct DirectedGraphExampleView: View {
    @StateObject private var graphViewModel = GraphViewModel(graph: DirectedGraphExample().graph)
    
    var body: some View {
        Canvas(graphViewModel: graphViewModel)
    }
}

#Preview {
    DirectedGraphExampleView()
        .environmentObject(ThemeViewModel())
}
