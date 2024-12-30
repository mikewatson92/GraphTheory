//
//  ExampleGraph1.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct ExampleGraph1 {
    let graph: Graph
    
    init() {
        var a = Vertex(position: CGPoint(x: 0.1, y: 0.3))
        a.label = "A"
        var b = Vertex(position: CGPoint(x: 0.8, y: 0.1))
        b.label = "B"
        var c = Vertex(position: CGPoint(x: 0.925, y: 0.85))
        c.label = "C"
        var d = Vertex(position: CGPoint(x: 0.4, y: 0.4))
        d.label = "D"
        d.color = .green
        var e = Vertex(position: CGPoint(x: 0.25, y: 0.725))
        e.label = "E"
        var edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB.controlPoint1 = CGPoint(x: 0.33, y: 0.05)
        edgeAB.controlPoint2 = CGPoint(x: 0.57, y: 0.05)
        var edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD.controlPoint1 = CGPoint(x: 0.15, y: 0.25)
        edgeAD.controlPoint2 = CGPoint(x: 0.3, y: 0.25)
        var edgeAE = Edge(startVertexID: a.id, endVertexID: e.id)
        edgeAE.controlPoint1 = CGPoint(x: 0.1, y: 0.51)
        edgeAE.controlPoint2 = CGPoint(x: 0.175, y: 0.72)
        var edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeBC.controlPoint1 = CGPoint(x: 0.95, y: 0.1)
        edgeBC.controlPoint2 = CGPoint(x: 0.95, y: 0.6)
        edgeBC.color = .teal
        var edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeCD.controlPoint1 = CGPoint(x: 0.75, y: 0.85)
        edgeCD.controlPoint2 = CGPoint(x: 0.525, y: 0.6)
        let edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        var edgeELoop = Edge(startVertexID: e.id, endVertexID: e.id)
        edgeELoop.color = .pink
        edgeELoop.controlPoint1 = CGPoint(x: 0.05, y: 1)
        edgeELoop.controlPoint2 = CGPoint(x: 0.45, y: 1)
        let vertices = [a, b, c, d, e]
        let edges = [edgeAB, edgeAD, edgeAE, edgeBC, edgeCD, edgeDE, edgeELoop]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.resetMethod = .restoreToOriginal
        self.graph = graph
    }
}

struct ExampleGraph1View: View {
    @StateObject private var graphViewModel = GraphViewModel(graph: ExampleGraph1().graph)
    
    var body: some View {
        Canvas(graphViewModel: graphViewModel)
    }
}

#Preview {
    ExampleGraph1View()
        .environmentObject(ThemeViewModel())
}
