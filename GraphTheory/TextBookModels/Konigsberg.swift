//
//  Konigsberg.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class KonigsbergModel: ObservableObject {
    @Published var graph = Graph()
    @Published var currentVertex: Vertex?
    var start: Bool = true
    var width: CGFloat
    var height: CGFloat
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var edgeAB1: Edge
    var edgeAB2: Edge
    var edgeAC1: Edge
    var edgeAC2: Edge
    var edgeAD: Edge
    var edgeBD: Edge
    var edgeCD: Edge
    var vertexAID: UUID
    var vertexBID: UUID
    var vertexCID: UUID
    var vertexDID: UUID
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (1 / 2) * height))
        vertexB = Vertex(position: CGPoint(x: (2 / 5) * width, y: (1 / 5) * height))
        vertexC = Vertex(position: CGPoint(x: (2 / 5) * width, y: (4 / 5) * height))
        vertexD = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 2) * height))
        edgeAB1 = Edge(vertexA, vertexB)
        edgeAB1.isCurved = true
        edgeAB1.controlPoint = CGPoint(x: (1 / 5) * width, y: (3 / 10) * height)
        edgeAB2 = Edge(vertexA, vertexB)
        edgeAB2.isCurved = true
        edgeAB2.controlPoint = CGPoint(x: (2 / 5) * width, y: (4 / 10) * height)
        edgeAC1 = Edge(vertexA, vertexC)
        edgeAC1.isCurved = true
        edgeAC1.controlPoint = CGPoint(x: (1 / 5) * width, y: (7 / 10) * height)
        edgeAC2 = Edge(vertexA, vertexC)
        edgeAC2.isCurved = true
        edgeAC2.controlPoint = CGPoint(x: (2 / 5) * width, y: (6 / 10) * height)
        edgeAD = Edge(vertexA, vertexD)
        edgeBD = Edge(vertexB, vertexD)
        edgeCD = Edge(vertexC, vertexD)
        vertexAID = vertexA.id
        vertexBID = vertexB.id
        vertexCID = vertexC.id
        vertexDID = vertexD.id
        graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD])
        graph.edges.append(contentsOf: [edgeAB1, edgeAB2, edgeAC1, edgeAC2, edgeAD, edgeBD, edgeCD])
        graph.changesLocked = true
        graph.algorithm = Graph.Algorithm.euler
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        self.graph.isMoving = true
        self.width = width
        self.height = height
        // Optional checking for vertex indices in case an edge or vertex has been deleted.
        let a: Int? = graph.vertices.firstIndex(where: { $0.id == vertexAID })
        let b: Int? = graph.vertices.firstIndex(where: { $0.id == vertexBID })
        let c: Int? = graph.vertices.firstIndex(where: { $0.id == vertexCID })
        let d: Int? = graph.vertices.firstIndex(where: { $0.id == vertexDID })
        let w: Int? = graph.edges.firstIndex(where: { $0.id == edgeAB1.id })
        let x: Int? = graph.edges.firstIndex(where: { $0.id == edgeAB2.id })
        let y: Int? = graph.edges.firstIndex(where: { $0.id == edgeAC1.id })
        let z: Int? = graph.edges.firstIndex(where: { $0.id == edgeAC2.id })
        if a != nil {
            graph.vertices[a!].position = CGPoint(x: (1 / 5) * width, y: (1 / 2) * height)
        }
        if b != nil {
            graph.vertices[b!].position = CGPoint(x: (2 / 5) * width, y: (1 / 5) * height)
        }
        if c != nil {
            graph.vertices[c!].position = CGPoint(x: (2 / 5) * width, y: (4 / 5) * height)
        }
        if d != nil {
            graph.vertices[d!].position = CGPoint(x: (4 / 5) * width, y: (1 / 2) * height)
        }
        if w != nil {
            graph.edges[w!].controlPoint = CGPoint(x: (1 / 5) * width, y: (3 / 10) * height)
        }
        if x != nil {
            graph.edges[x!].controlPoint = CGPoint(x: (2 / 5) * width, y: (4 / 10) * height)
        }
        if y != nil {
            graph.edges[y!].controlPoint = CGPoint(x: (1 / 5) * width, y: (7 / 10) * height)
        }
        if z != nil {
            graph.edges[z!].controlPoint = CGPoint(x: (2 / 5) * width, y: (6 / 10) * height)
        }
        graph.isMoving = false
    }
    
    func reset(width: CGFloat, height: CGFloat) {
        start = true
        currentVertex = nil
        graph.highlightedVertex = nil
        graph.edges.removeAll()
        graph.vertices.removeAll()
        vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (1 / 2) * height))
        vertexB = Vertex(position: CGPoint(x: (2 / 5) * width, y: (1 / 5) * height))
        vertexC = Vertex(position: CGPoint(x: (2 / 5) * width, y: (4 / 5) * height))
        vertexD = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 2) * height))
        edgeAB1 = Edge(vertexA, vertexB)
        edgeAB1.isCurved = true
        edgeAB1.controlPoint = CGPoint(x: (1 / 5) * width, y: (3 / 10) * height)
        edgeAB2 = Edge(vertexA, vertexB)
        edgeAB2.isCurved = true
        edgeAB2.controlPoint = CGPoint(x: (2 / 5) * width, y: (4 / 10) * height)
        edgeAC1 = Edge(vertexA, vertexC)
        edgeAC1.isCurved = true
        edgeAC1.controlPoint = CGPoint(x: (1 / 5) * width, y: (7 / 10) * height)
        edgeAC2 = Edge(vertexA, vertexC)
        edgeAC2.isCurved = true
        edgeAC2.controlPoint = CGPoint(x: (2 / 5) * width, y: (6 / 10) * height)
        edgeAD = Edge(vertexA, vertexD)
        edgeBD = Edge(vertexB, vertexD)
        edgeCD = Edge(vertexC, vertexD)
        vertexAID = vertexA.id
        vertexBID = vertexB.id
        vertexCID = vertexC.id
        vertexDID = vertexD.id
        graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD])
        graph.edges.append(contentsOf: [edgeAB1, edgeAB2, edgeAC1, edgeAC2, edgeAD, edgeBD, edgeCD])
        graph.changesLocked = true
        graph.algorithm = .euler
    }

}

struct Konigsberg: View {
    @StateObject var konigsbergModel: KonigsbergModel = KonigsbergModel(width: 500, height: 500)
    
    var body: some View {
        GeometryReader {geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack(alignment: .top) {
                
                HStack{
                    Spacer()
                    Button("Clear") {
                        konigsbergModel.reset(width: width, height: height)
                    }
                    .padding()
                }
                
                ForEach(konigsbergModel.graph.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), graph: konigsbergModel.graph)
                        .onTapGesture(count: 1) {
                            if !konigsbergModel.start {
                                if konigsbergModel.currentVertex!.edgeIsConnected(edge: edge) {
                                    if edge.endVertex == konigsbergModel.currentVertex! {
                                        edge.swapVertices()
                                    }
                                    edge.isSelected.toggle()
                                    konigsbergModel.currentVertex = edge.endVertex
                                    konigsbergModel.graph.highlightedVertex = edge.endVertex
                                }
                            }
                        }
                }
                ForEach(konigsbergModel.graph.vertices) { vertex in
                    VertexView(vertex: vertex, graph: konigsbergModel.graph)
                        .onTapGesture(count: 1) {
                            if konigsbergModel.start {
                                konigsbergModel.graph.highlightedVertex = vertex
                                konigsbergModel.currentVertex = vertex
                                konigsbergModel.start = false
                            }
                        }
                }
                
            }
            .onAppear{
                konigsbergModel.resize(width: width, height: height)
            }
            .onChange(of: geometry.size) { size in
                let width = size.width
                let height = size.height
                konigsbergModel.resize(width: width, height: height)
            }
        }
    }
}

struct Konigsberg_Previews: PreviewProvider {
    static var previews: some View {
        Konigsberg()
    }
}
