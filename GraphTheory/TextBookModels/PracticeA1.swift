//
//  PracticeA1.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class PracticeA1Model: ObservableObject {
    @Published var model: ModelData
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
    
    init(model: ModelData, width: CGFloat, height: CGFloat) {
        self.model = model
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
        self.model.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE, vertexF])
        self.model.edges.append(contentsOf: [edgeAB, edgeAE, edgeBD, edgeCE, edgeDE, edgeDF, edgeEF, edgeFF])
        self.model.changesLocked = true
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        model.isMoving = true
        model.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (2 / 5) * height)
        model.vertices[1].position = CGPoint(x: (3 / 5) * width, y: (1 / 5) * height)
        model.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (1 / 2) * height)
        model.vertices[3].position = CGPoint(x: (3 / 5) * width, y: (4 / 5) * height)
        model.vertices[4].position = CGPoint(x: (1 / 2) * width, y: (3.5 / 5) * height)
        model.vertices[5].position = CGPoint(x: (1 / 5) * width, y: (4 / 5) * height)
        model.isMoving = false
    }
}

struct PracticeA1: View {
    @StateObject var practiceA1Model = PracticeA1Model(model: ModelData(), width: 500.0, height: 500.0)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                ForEach(practiceA1Model.model.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), model: practiceA1Model.model)
                }
                ForEach(practiceA1Model.model.vertices) { vertex in
                    VertexView(vertex: vertex, model: practiceA1Model.model)
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
