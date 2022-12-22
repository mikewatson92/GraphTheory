//
//  TSP1.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class TSP1Model: ObservableObject {
    @Published var model: ModelData = ModelData()
    var width: CGFloat
    var height: CGFloat
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var edgeAB: Edge
    var edgeAC: Edge
    var edgeAD: Edge
    var edgeAE: Edge
    var edgeBC: Edge
    var edgeBD: Edge
    var edgeBE: Edge
    var edgeCD: Edge
    var edgeCE: Edge
    var edgeDE: Edge
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self.vertexA = Vertex(position: CGPoint(x: (2 / 5) * width, y: (1 / 5) * height))
        self.vertexA.label = "A"
        self.vertexB = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 5) * height))
        self.vertexB.label = "B"
        self.vertexC = Vertex(position: CGPoint(x: (4 / 5) * width, y: (4 / 5) * height))
        self.vertexC.label = "C"
        self.vertexD = Vertex(position: CGPoint(x: (2 / 5) * width, y: (4 / 5) * height))
        self.vertexD.label = "D"
        self.vertexE = Vertex(position: CGPoint(x: (1 / 5) * width, y: (2 / 5) * height))
        self.vertexE.label = "E"
        self.edgeAB = Edge(vertexA, vertexB)
        self.edgeAC = Edge(vertexA, vertexC, 3 / 4)
        self.edgeAD = Edge(vertexA, vertexD, 1 / 3)
        self.edgeAE = Edge(vertexA, vertexE)
        self.edgeBC = Edge(vertexB, vertexC)
        self.edgeBD = Edge(vertexB, vertexD, 1 / 3)
        self.edgeBE = Edge(vertexB, vertexE, 1 / 3)
        self.edgeCD = Edge(vertexC, vertexD)
        self.edgeCE = Edge(vertexC, vertexE, 1 / 3)
        self.edgeDE = Edge(vertexD, vertexE)
        self.edgeAB.weight = 10
        self.edgeAC.weight = 5
        self.edgeAD.weight = 8
        self.edgeAE.weight = 7
        self.edgeBC.weight = 8
        self.edgeBD.weight = 6
        self.edgeBE.weight = 6
        self.edgeCD.weight = 9
        self.edgeCE.weight = 7
        self.edgeDE.weight = 4
        edgeAB.textDirection = .negative
        edgeAB.textDistance = 40
        edgeAD.textDistance = 10
        edgeAE.textDirection = .negative
        edgeAE.textDistance = 40
        edgeCE.textDirection = .negative
        edgeDE.textDirection = .negative
        edgeDE.textDistance = 40
        model.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE])
        model.edges.append(contentsOf: [edgeAB, edgeAC, edgeAD, edgeAE, edgeBC, edgeBD, edgeBE, edgeCD, edgeCE, edgeDE])
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        self.model.isMoving = true
        self.model.vertices[0].position = CGPoint(x: (2 / 5) * width, y: (1 / 5) * height)
        self.model.vertices[1].position = CGPoint(x: (4 / 5) * width, y: (1 / 5) * height)
        self.model.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (4 / 5) * height)
        self.model.vertices[3].position = CGPoint(x: (2 / 5) * width, y: (4 / 5) * height)
        self.model.vertices[4].position = CGPoint(x: (1 / 5) * width, y: (2 / 5) * height)
        for edge in model.edges {
            edge.textPosition = edge.textStartPosition
        }
        self.model.isMoving = false
    }
}

struct TSP1: View {
    @StateObject var tsp1Model = TSP1Model(width: 500, height: 500)
    
    var body: some View {
        GeometryReader{ geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            TSP(model: tsp1Model.model)
                .onAppear {
                    tsp1Model.resize(width: width, height: height)

                }
                .onChange(of: geometry.size) { size in
                    let width = size.width
                    let height = size.height
                    tsp1Model.resize(width: width, height: height)
                }
        }
    }
}

struct TSP1_Previews: PreviewProvider {
    static var previews: some View {
        TSP1()
    }
}
