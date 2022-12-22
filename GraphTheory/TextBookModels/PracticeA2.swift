//
//  PracticeA2.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class PracticeA2Model: ObservableObject {
    @Published var model = ModelData()
    var vertexP: Vertex
    var vertexQ: Vertex
    var vertexR: Vertex
    var vertexS: Vertex
    var vertexT: Vertex
    var vertexU: Vertex
    var edgePQ: Edge
    var edgePU: Edge
    var edgeQR: Edge
    var edgeQS: Edge
    var edgeQT: Edge
    var edgeST: Edge
    var edgeTP: Edge
    var edgeTU: Edge
    
    init(width: CGFloat, height: CGFloat) {
        self.vertexP = Vertex(position: CGPoint(x: (1.2 / 5) * width, y: (1.2 / 5) * height), label: "P")
        self.vertexQ = Vertex(position: CGPoint(x: (3 / 5) * width, y: (1 / 5) * height), label: "Q")
        self.vertexR = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 2) * height), label: "R")
        self.vertexS = Vertex(position: CGPoint(x: (3.5 / 5) * width, y: (4 / 5) * height), label: "S")
        self.vertexT = Vertex(position: CGPoint(x: (1 / 2) * width, y: (3.5 / 5) * height), label: "T")
        self.vertexU = Vertex(position: CGPoint(x: (1 / 5) * width, y: (4 / 5) * height), label: "U")
        self.edgePQ = Edge(vertexP, vertexQ, 0.5, .forward)
        self.edgePU = Edge(vertexP, vertexU, 0.5, .forward)
        self.edgeQR = Edge(vertexQ, vertexR, 0.5, .bidirectional)
        self.edgeQS = Edge(vertexQ, vertexS, 0.5, .forward)
        self.edgeQT = Edge(vertexQ, vertexT, 0.5, .forward)
        self.edgeST = Edge(vertexS, vertexT, 0.5, .forward)
        self.edgeTP = Edge(vertexT, vertexP, 0.5, .forward)
        self.edgeTU = Edge(vertexT, vertexU, 0.5, .bidirectional)
        self.model.vertices.append(contentsOf: [vertexP, vertexQ, vertexR, vertexS, vertexT, vertexU])
        self.model.edges.append(contentsOf: [edgePQ, edgePU, edgeQR, edgeQS, edgeQT, edgeST, edgeTP, edgeTU])
        self.model.changesLocked = true
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        model.isMoving = true
        model.vertices[0].position = CGPoint(x: (1.2 / 5) * width, y: (1.2 / 5) * height)
        model.vertices[1].position = CGPoint(x: (3 / 5) * width, y: (1 / 5) * height)
        model.vertices[2].position = CGPoint(x: (4 / 5) * width, y: (1 / 2) * height)
        model.vertices[3].position = CGPoint(x: (3.5 / 5) * width, y: (4 / 5) * height)
        model.vertices[4].position = CGPoint(x: (1 / 2) * width, y: (3.5 / 5) * height)
        model.vertices[5].position = CGPoint(x: (1 / 5) * width, y: (4 / 5) * height)
        model.isMoving = false
    }
}

struct PracticeA2: View {
    @StateObject var practiceA2Model = PracticeA2Model(width: 500, height: 500)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                ForEach(practiceA2Model.model.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), model: practiceA2Model.model)
                }
                ForEach(practiceA2Model.model.vertices) { vertex in
                    VertexView(vertex: vertex, model: practiceA2Model.model)
                }
            }
            .onAppear {
                practiceA2Model.resize(width: width, height: height)
            }
            .onChange(of: geometry.size) { size in
                let width = size.width
                let height = size.height
                practiceA2Model.resize(width: width, height: height)
            }
        }
    }
}

struct PracticeA2_Previews: PreviewProvider {
    static var previews: some View {
        PracticeA2()
    }
}
