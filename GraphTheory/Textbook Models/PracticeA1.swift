//
//  PracticeA1.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class PracticeA1Model: ObservableObject {
    @Published var graph: Graph
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var vertexF: Vertex
    var edgeAB: Edge
    var edgeAE: Edge
    var edgeBD: Edge
    var edgeCE: Edge
    var edgeDE: Edge
    var edgeDF: Edge
    var edgeEF: Edge
    var edgeFF: Edge
    
    init(graph: Graph, width: CGFloat, height: CGFloat) {
        self.graph = graph
        self.vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (2 / 5) * height), label: "A")
        self.vertexB = Vertex(position: CGPoint(x: (3 / 5) * width, y: (1 / 5) * height), label: "B")
        self.vertexC = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 2) * height), label: "C")
        self.vertexD = Vertex(position: CGPoint(x: (3 / 5) * width, y: (4 / 5) * height), label: "D")
        self.vertexE = Vertex(position: CGPoint(x: (1 / 2) * width, y: (3.5 / 5) * height), label: "E")
        self.vertexF = Vertex(position: CGPoint(x: (1 / 5) * width, y: (4 / 5) * height), label: "F")
        self.edgeAB = Edge(vertexA, vertexB)
        self.edgeAE = Edge(vertexA, vertexE)
        self.edgeBD = Edge(vertexB, vertexD)
        self.edgeCE = Edge(vertexC, vertexE)
        self.edgeDE = Edge(vertexD, vertexE)
        self.edgeDF = Edge(vertexD, vertexF)
        self.edgeEF = Edge(vertexE, vertexF)
        self.edgeFF = Edge(vertexF, vertexF)
        self.graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE, vertexF])
        self.graph.edges.append(contentsOf: [edgeAB, edgeAE, edgeBD, edgeCE, edgeDE, edgeDF, edgeEF, edgeFF])
        self.graph.changesLocked = true
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        graph.isMoving = true
        graph.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (2 / 5) * height)
        graph.vertices[1].position = CGPoint(x: (3 / 5) * width, y: (1 / 5) * height)
        graph.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (1 / 2) * height)
        graph.vertices[3].position = CGPoint(x: (3 / 5) * width, y: (4 / 5) * height)
        graph.vertices[4].position = CGPoint(x: (1 / 2) * width, y: (3.5 / 5) * height)
        graph.vertices[5].position = CGPoint(x: (1 / 5) * width, y: (4 / 5) * height)
        graph.isMoving = false
    }
}

struct PracticeA1: View {
    @StateObject var practiceA1Model = PracticeA1Model(graph: Graph(), width: 500.0, height: 500.0)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                ForEach(practiceA1Model.graph.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), graph: practiceA1Model.graph)
                }
                ForEach(practiceA1Model.graph.vertices) { vertex in
                    VertexView(vertex: vertex, graph: practiceA1Model.graph)
                }
            }
            .onAppear {
                practiceA1Model.resize(width: width, height: height)
            }
            .onChange(of: geometry.size) { size in
                let width = size.width
                let height = size.height
                practiceA1Model.resize(width: width, height: height)
            }
        }
    }
}

struct PracticeA1_Previews: PreviewProvider {
    static var previews: some View {
        PracticeA1()
    }
}
