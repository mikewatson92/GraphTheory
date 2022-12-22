//
//  PracticeA3.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class PracticeA3Model: ObservableObject {
    @Published var model = ModelData()
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var vertexF: Vertex
    var edgeAB: Edge
    var edgeAC: Edge
    var edgeAF: Edge
    var edgeBD: Edge
    var edgeBE: Edge
    var edgeBF: Edge
    var edgeCE: Edge
    var edgeDF: Edge
    var edgeEF: Edge
    
    init(width: CGFloat, height: CGFloat) {
        vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (1 / 5) * height), label: "A")
        vertexB = Vertex(position: CGPoint(x: (2.75 / 5) * width, y: (0.75 / 5) * height), label: "B")
        vertexC = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 2) * height), label: "C")
        vertexD = Vertex(position: CGPoint(x: (1 / 2) * width, y: (1 / 2) * height), label: "D")
        vertexE = Vertex(position: CGPoint(x: (3 / 5) * width, y: (4 / 5) * height), label: "E")
        vertexF = Vertex(position: CGPoint(x: (1.25 / 5) * width, y: (3 / 5) * height), label: "F")
        edgeAB = Edge(vertexA, vertexB)
        edgeAC = Edge(vertexA, vertexC)
        edgeAF = Edge(vertexA, vertexF)
        edgeBD = Edge(vertexB, vertexD)
        edgeBE = Edge(vertexB, vertexE)
        edgeBF = Edge(vertexB, vertexF)
        edgeCE = Edge(vertexC, vertexE)
        edgeDF = Edge(vertexD, vertexF)
        edgeEF = Edge(vertexE, vertexF)
        model.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE, vertexF])
        model.edges.append(contentsOf: [edgeAB, edgeAC, edgeAF, edgeBD, edgeBE, edgeBF, edgeCE, edgeDF, edgeEF])
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        model.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (1 / 5) * height)
        model.vertices[1].position = CGPoint(x: (2.75 / 5) * width, y: (0.75 / 5) * height)
        model.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (1 / 2) * height)
        model.vertices[3].position = CGPoint(x: (1 / 2) * width, y: (1 / 2) * height)
        model.vertices[4].position = CGPoint(x: (3 / 5) * width, y: (4 / 5) * height)
        model.vertices[5].position = CGPoint(x: (1.25 / 5) * width, y: (3 / 5) * height)
    }
}

struct PracticeA3: View {
    @StateObject var practiceA3Model = PracticeA3Model(width: 500, height: 500)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                ForEach(practiceA3Model.model.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), model: practiceA3Model.model)
                }
                ForEach(practiceA3Model.model.vertices) { vertex in
                    VertexView(vertex: vertex, model: practiceA3Model.model)
                }
            }
            .onAppear {
                practiceA3Model.resize(width: width, height: height)
            }
            .onChange(of: geometry.size) { size in
                let width = size.width
                let height = size.height
                practiceA3Model.resize(width: width, height: height)
            }
        }
    }
}

struct PracticeA3_Previews: PreviewProvider {
    static var previews: some View {
        PracticeA3()
    }
}
