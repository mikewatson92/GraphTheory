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
        edgeAB1.controlPoint1 = CGPoint(x: 0.25, y: 0.35)
        edgeAB1.controlPoint2 = CGPoint(x: 0.45, y: 0.2)
        var edgeAB2 = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeAB2.controlPoint1 = CGPoint(x: 0.3, y: 0.5)
        edgeAB2.controlPoint2 = CGPoint(x: 0.4, y: 0.35)
        let edgeAC = Edge(startVertexID: a.id, endVertexID: c.id)
        var edgeAD1 = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD1.controlPoint1 = CGPoint(x: 0.25, y: 0.65)
        edgeAD1.controlPoint2 = CGPoint(x: 0.45, y: 0.8)
        var edgeAD2 = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeAD2.controlPoint1 = CGPoint(x: 0.3, y: 0.5)
        edgeAD2.controlPoint2 = CGPoint(x: 0.4, y: 0.65)
        let edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        let edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        let vertices = [a, b, c, d]
        let edges = [edgeAB1, edgeAB2, edgeAC, edgeAD1, edgeAD2, edgeBC, edgeCD]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.mode = .explore
        self.graph = graph
    }
}

struct KonigsbergView: View {
    @StateObject private var graphViewModel = GraphViewModel(graph: Konigsberg().graph)
    
    var body: some View {
        GraphView(graphViewModel: graphViewModel)
    }
}

#Preview {
    KonigsbergView()
}
