//
//  Kruskal1.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class Kruskal1Model: ObservableObject {
    @Published var model: ModelData = ModelData()
    var width: CGFloat
    var height: CGFloat
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var vertexF: Vertex
    var vertexG: Vertex
    var edgeAB: Edge
    var edgeAF: Edge
    var edgeAG: Edge
    var edgeBC: Edge
    var edgeBD: Edge
    var edgeBF: Edge
    var edgeDE: Edge
    var edgeDF: Edge
    var edgeFG: Edge
    
    init(width: CGFloat, height: CGFloat) {
        
        self.width = width
        self.height = height
        self.vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (2 / 5) * height))
        self.vertexA.label = "A"
        self.vertexB = Vertex(position: CGPoint(x: (2 / 5) * width, y: (1 / 5) * height))
        self.vertexB.label = "B"
        self.vertexC = Vertex(position: CGPoint(x: (3 / 5) * width, y: (2 / 5) * height))
        self.vertexC.label = "C"
        self.vertexD = Vertex(position: CGPoint(x: (2.75 / 5) * width, y: (2 / 5) * height))
        self.vertexD.label = "D"
        self.vertexE = Vertex(position: CGPoint(x: (4 / 5) * width, y: (3 / 5) * height))
        self.vertexE.label = "E"
        self.vertexF = Vertex(position: CGPoint(x: (2 / 5) * width, y: (3 / 5) * height))
        self.vertexF.label = "F"
        self.vertexG = Vertex(position: CGPoint(x: (1.25 / 5) * width, y: (4 / 5) * height))
        self.vertexG.label = "G"
        self.edgeAB = Edge(vertexA, vertexB)
        self.edgeAF = Edge(vertexA, vertexF, 1 / 3)
        self.edgeAG = Edge(vertexA, vertexG)
        self.edgeBC = Edge(vertexB, vertexC)
        self.edgeBD = Edge(vertexB, vertexD)
        self.edgeBF = Edge(vertexB, vertexF)
        self.edgeDE = Edge(vertexD, vertexE)
        self.edgeDF = Edge(vertexD, vertexF)
        self.edgeFG = Edge(vertexF, vertexG)
        edgeAB.weight = 35
        edgeAB.textDirection = .negative
        edgeAB.textDistance = 50
        edgeAF.weight = 30
        edgeAF.textDistance = 30
        edgeAG.weight = 40
        edgeAG.textDirection = .negative
        edgeAG.textDistance = 40
        edgeBC.weight = 15
        edgeBC.textDirection = .negative
        edgeBC.textDistance = 40
        edgeBD.weight = 20
        edgeBF.weight = 30
        edgeBF.textDistance = 10
        edgeDE.weight = 45
        edgeDF.weight = 45
        edgeFG.weight = 20
        self.model.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE, vertexF, vertexG])
        self.model.edges.append(contentsOf: [edgeAB, edgeAF, edgeAG, edgeBC, edgeBD, edgeBF, edgeDE, edgeDF, edgeFG])
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        self.model.isMoving = true
        self.model.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (2 / 5) * height)
        self.model.vertices[1].position = CGPoint(x: (2 / 5) * width, y: (1 / 5) * height)
        self.model.vertices[2].position = CGPoint(x: (3 / 5) * width, y: (1 / 5) * height)
        self.model.vertices[3].position = CGPoint(x: (2.75 / 5) * width, y: (2 / 5) * height)
        self.model.vertices[4].position = CGPoint(x: (4 / 5) * width, y: (2 / 5) * height)
        self.model.vertices[5].position = CGPoint(x: (2 / 5) * width, y: (3 / 5) * height)
        self.model.vertices[6].position = CGPoint(x: (1.25 / 5) * width, y: (4 / 5) * height)
        for edge in model.edges {
            edge.textPosition = edge.textStartPosition
        }
        self.model.isMoving = false
        
    }
}

struct Kruskal1: View {

    @StateObject var kruskal1Model: Kruskal1Model = Kruskal1Model(width: 500, height: 500)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            KruskalView(model: kruskal1Model.model)
                .onAppear {
                    kruskal1Model.resize(width: width, height: height)
                }
                .onChange(of: geometry.size) { size in
                    let width = size.width
                    let height = size.height
                    kruskal1Model.resize(width: width, height: height)
                }
        }
    }
}

struct Kruskal2_Previews: PreviewProvider {
    static var previews: some View {
        Kruskal1()
    }
}
