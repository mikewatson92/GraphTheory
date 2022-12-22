//
//  Loops.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class LoopModel: ObservableObject {
    @Published var model: ModelData = ModelData()
    var vertex = Vertex(position: CGPoint(x: 250, y: 250))
    var edge: Edge
    
    init() {
        edge = Edge(vertex, vertex)
        model.vertices.append(vertex)
        model.edges.append(edge)
    }
}

struct Loop: View {
    
    @StateObject private var loopModel = LoopModel()
    
    var body: some View {
        ZStack{
            EdgeView(edge: loopModel.edge, showWeights: .constant(false), model: loopModel.model)
            VertexView(vertex: loopModel.vertex, model: loopModel.model)
        }
    }
}

struct Loop_Previews: PreviewProvider {
    static var previews: some View {
        Loop()
    }
}
