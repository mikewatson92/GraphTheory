//
//  ChinesePostmanModel1.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class ChinesePostmanModel1: ObservableObject {
    @Published var graph: Graph = Graph()
    var width: CGFloat
    var height: CGFloat
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var edgeAB: Edge
    var edgeAD: Edge
    var edgeAE: Edge
    var edgeBC: Edge
    var edgeBE: Edge
    var edgeCD: Edge
    var edgeCE: Edge
    var edgeDE: Edge
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self.vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (4 / 5) * height))
        self.vertexA.label = "A"
        self.vertexB = Vertex(position: CGPoint(x: (4 / 5) * width, y: (4 / 5) * height))
        self.vertexB.label = "B"
        self.vertexC = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 5) * height))
        self.vertexC.label = "C"
        self.vertexD = Vertex(position: CGPoint(x: (1 / 5) * width, y: (1 / 5) * height))
        self.vertexD.label = "D"
        self.vertexE = Vertex(position: CGPoint(x: (1 / 2) * width, y: (1 / 2) * height))
        self.vertexE.label = "E"
        self.edgeAB = Edge(vertexA, vertexB)
        self.edgeAD = Edge(vertexA, vertexD)
        self.edgeAE = Edge(vertexA, vertexE)
        self.edgeBC = Edge(vertexB, vertexC)
        self.edgeBE = Edge(vertexB, vertexE)
        self.edgeCD = Edge(vertexC, vertexD)
        self.edgeCE = Edge(vertexC, vertexE)
        self.edgeDE = Edge(vertexD, vertexE)
        edgeAB.weight = 8
        edgeAD.weight = 7
        edgeAE.weight = 4
        edgeBC.weight = 9
        edgeBE.weight = 5
        edgeCD.weight = 6
        edgeCE.weight = 3
        edgeDE.weight = 2
        self.graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE])
        self.graph.edges.append(contentsOf: [edgeAB, edgeAD, edgeAE, edgeBC, edgeBE, edgeCD, edgeCE, edgeDE])
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        self.graph.isMoving = true
        self.graph.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (4 / 5) * height)
        self.graph.vertices[1].position = CGPoint(x: (4 / 5) * width, y: (4 / 5) * height)
        self.graph.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (1 / 5) * height)
        self.graph.vertices[3].position = CGPoint(x: (1 / 5) * width, y: (1 / 5) * height)
        self.graph.vertices[4].position = CGPoint(x: (1 / 2) * width, y: (1 / 2) * height)
        for edge in graph.edges {
            edge.textPosition = edge.textStartPosition
        }
        self.graph.isMoving = false
    }
    
}

struct ChinesePostman1View: View {
    
    @StateObject var chinesePostman1Model = ChinesePostmanModel1(width: 500, height: 500)
    lazy var chinesePostman1ViewModel = ChinesePostman(graph: chinesePostman1Model.graph)
    
    var body: some View {
        GeometryReader{ geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ChinesePostman(graph: chinesePostman1Model.graph)
                .onAppear {
                    chinesePostman1Model.resize(width: width, height: height)

                }
                .onChange(of: geometry.size) { size in
                    let width = size.width
                    let height = size.height
                    chinesePostman1Model.resize(width: width, height: height)
                }
        }
    }
}
