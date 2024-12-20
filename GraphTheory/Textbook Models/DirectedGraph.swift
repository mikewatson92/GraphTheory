//
//  DirectedGraph.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class DirectedGraphModel: ObservableObject {
    @Published var graph = Graph()
    var width: CGFloat
    var height: CGFloat
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var edgeAB: Edge
    var edgeBC: Edge
    var edgeBE: Edge
    var edgeCD: Edge
    var edgeDE: Edge
    var edgeEA: Edge
    var edgeEC: Edge
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self.vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (1 / 5) * height), label: "A")
        self.vertexB = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 5) * height), label: "B")
        self.vertexC = Vertex(position: CGPoint(x: (1 / 2) * width, y: (1 / 2) * height), label: "C")
        self.vertexD = Vertex(position: CGPoint(x: (2 / 5) * width, y: (4 / 5) * height), label: "D")
        self.vertexE = Vertex(position: CGPoint(x: (1.5 / 5) * width, y: (0.75 / 2) * height), label: "E")
        self.edgeAB = Edge(vertexA, vertexB, 0.5, .bidirectional)
        self.edgeBC = Edge(vertexB, vertexC, 0.5, .forward)
        self.edgeBE = Edge(vertexB, vertexE, 0.5, .forward)
        self.edgeCD = Edge(vertexC, vertexD, 0.5, .forward)
        self.edgeDE = Edge(vertexD, vertexE, 0.5, .forward)
        self.edgeEA = Edge(vertexE, vertexA, 0.5, .forward)
        self.edgeEC = Edge(vertexE, vertexC, 0.5, .forward)
        self.graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE])
        self.graph.edges.append(contentsOf: [edgeAB, edgeBC, edgeBE, edgeCD, edgeDE, edgeEA, edgeEC])
        self.graph.changesLocked = true
    }
    
    func resize(width: CGFloat, height: CGFloat) {
        graph.isMoving = true
        graph.vertices[0].position = CGPoint(x: (1 / 5) * width, y: (1 / 5) * height)
        graph.vertices[1].position = CGPoint(x: (4 / 5) * width, y: (1 / 5) * height)
        graph.vertices[2].position = CGPoint(x: (1 / 2) * width, y: (1 / 2) * height)
        graph.vertices[3].position = CGPoint(x: (2 / 5) * width, y: (4 / 5) * height)
        graph.vertices[4].position = CGPoint(x: (1.5 / 5) * width, y: (0.75 / 2) * height)
    }
}

struct DirectedGraph: View {
    @StateObject var directedGraphModel = DirectedGraphModel(width: 500, height: 500)
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                ForEach(directedGraphModel.graph.edges) { edge in
                    EdgeView(edge: edge, showWeights: .constant(false), graph: directedGraphModel.graph)
                }
                ForEach(directedGraphModel.graph.vertices) { vertex in
                    VertexView(vertex: vertex, graph: directedGraphModel.graph)
                }
            }
            .onAppear {
                directedGraphModel.resize(width: width, height: height)
            }
            .onChange(of: geometry.size) { size in
                let width = size.width
                let height = size.height
                directedGraphModel.resize(width: width, height: height)
            }
            
        }
    }
}

struct DirectedGraph_Previews: PreviewProvider {
    static var previews: some View {
        DirectedGraph()
    }
}
