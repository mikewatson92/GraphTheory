//
//  Loops.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class LoopModel: ObservableObject {
    @Published var graph: Graph = Graph()
    var vertex = Vertex(position: CGPoint(x: 250, y: 250))
    var edge: Edge
    
    init() {
        edge = Edge(vertex, vertex)
        graph.vertices.append(vertex)
        graph.edges.append(edge)
    }
}

struct Loop: View {
    
    @StateObject private var loopModel = LoopModel()
    
    var body: some View {
        ZStack{
            EdgeView(edge: loopModel.edge, showWeights: .constant(false), graph: loopModel.graph)
            VertexView(vertex: loopModel.vertex, graph: loopModel.graph)
        }
    }
}

struct Loop_Previews: PreviewProvider {
    static var previews: some View {
        Loop()
    }
}
