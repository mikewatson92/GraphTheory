//
//  UndirectedGraphExample.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct UndirectedGraphExample {
    let graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.2, y: 0.2))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.75, y: 0.2))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.75, y: 0.75))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.2, y: 0.75))
        d.label = "D"
        var e = Vertex(position: CGPoint(x: 0.6, y: 0.5))
        e.label = "E"
        var f = Vertex(position: CGPoint(x: 0.175, y: 0.5))
        f.label = "F"
        let edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        let edgeAF = Edge(startVertexID: a.id, endVertexID: f.id)
        let edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        let edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        var edgeCLoop = Edge(startVertexID: c.id, endVertexID: c.id)
        edgeCLoop.controlPoint1 = CGPoint(x: 0.95, y: 0.7)
        edgeCLoop.controlPoint2 = CGPoint(x: 0.7, y: 1)
        let edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        let edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        let edgeEF = Edge(startVertexID: e.id, endVertexID: f.id)
        let vertices = [a, b, c, d, e, f]
        let edges = [edgeAB, edgeAF, edgeBC, edgeBE, edgeCLoop, edgeCD, edgeDE, edgeEF]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.resetMethod = .restoreToOriginal
        self.graph = graph
    }
}

struct UndirectedGraphExampleView: View {
    @StateObject private var graphViewModel = GraphViewModel(graph: UndirectedGraphExample().graph)
    
    var body: some View {
        Canvas(graphViewModel: graphViewModel)
    }
}

#Preview {
    UndirectedGraphExampleView()
        .environmentObject(ThemeViewModel())
}
