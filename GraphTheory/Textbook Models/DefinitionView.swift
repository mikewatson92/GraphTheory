//
//  DefinitionView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class DefinitionViewModel: ObservableObject {
    @Published var graph = Graph()
    var vertexA: Vertex
    var vertexB: Vertex
    var vertexC: Vertex
    var vertexD: Vertex
    var vertexE: Vertex
    var edgeAB: Edge
    var edgeAD: Edge
    var edgeAE: Edge
    var edgeBC: Edge
    var edgeCD: Edge
    var edgeDE: Edge
    var edgeEE: Edge
    
    init(width: CGFloat, height: CGFloat) {
        vertexA = Vertex(position: CGPoint(x: (1 / 5) * width, y: (2 / 5) * height), label: "A")
        vertexB = Vertex(position: CGPoint(x: (4 / 5) * width, y: (1 / 5) * height), label: "B")
        vertexC = Vertex(position: CGPoint(x: (4 / 5) * width, y: (3.5 / 5) * height), label: "C")
        vertexD = Vertex(position: CGPoint(x: (1 / 2) * width, y: (1 / 2) * height), label: "D")
        vertexE = Vertex(position: CGPoint(x: (2 / 5) * width, y: (4 / 5) * height), label: "E")
        edgeAB = Edge(vertexA, vertexB)
        edgeAD = Edge(vertexA, vertexD)
        edgeAE = Edge(vertexA, vertexE)
        edgeBC = Edge(vertexB, vertexC)
        edgeCD = Edge(vertexC, vertexD)
        edgeDE = Edge(vertexD, vertexE)
        edgeEE = Edge(vertexE, vertexE)
        graph.vertices.append(contentsOf: [vertexA, vertexB, vertexC, vertexD, vertexE])
        graph.edges.append(contentsOf: [edgeAB, edgeAD, edgeAE, edgeBC, edgeCD, edgeDE, edgeEE])
        graph.changesLocked = true
    }
}

struct DefinitionView: View {
    @StateObject var definitionModel = DefinitionViewModel(width: 500, height: 500)
    
    var body: some View {
        ZStack {
            ForEach(definitionModel.graph.edges) { edge in
                EdgeView(edge: edge, showWeights: .constant(false), graph: definitionModel.graph)
            }
            ForEach(definitionModel.graph.vertices) { vertex in
                VertexView(vertex: vertex, graph: definitionModel.graph)
            }
            Text("Loop")
                .position(x: 200.0, y: 475)
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Edge")
                .position(x: 450.0, y: 225.0)
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Vertex")
                .position(x: 50.0, y: 200.0)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

struct DefinitionView_Previews: PreviewProvider {
    static var previews: some View {
        DefinitionView()
    }
}
