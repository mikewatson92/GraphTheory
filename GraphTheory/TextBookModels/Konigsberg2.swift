//
//  Konigsberg2.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct Konigsberg2: View {
    @StateObject var konigsbergModel = KonigsbergModel(width: 500, height: 500)
    @State var status: Status = .deleteEdge
    @State var visitedEdges: [Edge] = []
    @State var currentVertex: Vertex?
    
    enum Status {
        case deleteEdge
        case startVertex
        case inProgress
        case solved
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .scaledToFill()
                .foregroundStyle(blueGradient)
                .opacity(status == .solved ? 1 : 0)
            
            HStack {
                Spacer()
                
                Button("Clear") {
                    konigsbergModel.reset(width: 500, height: 500)
                    status = .deleteEdge
                    visitedEdges = []
                    currentVertex = nil
                }
                .padding()
            }
            
            ForEach(konigsbergModel.model.edges) { edge in
                EdgeView(edge: edge, showWeights: .constant(false), model: konigsbergModel.model)
                    .onTapGesture(count: 2) {
                        if status == .deleteEdge {
                            konigsbergModel.model.edges.removeAll(where: { $0.id == edge.id })
                            status = .startVertex
                        }
                    }
                    .onTapGesture(count: 1) {
                        if status == .inProgress && currentVertex!.edgeIsConnected(edge: edge) {
                            if !visitedEdges.contains(edge) {
                                if edge.endVertex == currentVertex! {
                                    edge.swapVertices()
                                }
                                visitedEdges.append(edge)
                                edge.isSelected = true
                                if visitedEdges.count == konigsbergModel.model.edges.count {
                                    status = .solved
                                }
                            } else {
                                visitedEdges.removeAll(where: { $0.id == edge.id })
                                edge.isSelected = false
                            }
                            currentVertex = edge.endVertex
                            konigsbergModel.model.highlightedVertex = edge.endVertex
                        }
                    }
            }
            ForEach(konigsbergModel.model.vertices) { vertex in
                VertexView(vertex: vertex, model: konigsbergModel.model)
                    .onTapGesture(count: 1) {
                        if status == .startVertex {
                            currentVertex = vertex
                            konigsbergModel.model.highlightedVertex = vertex
                            status = .inProgress
                        }
                    }
            }
        }
    }
}

struct Konigsberg2_Previews: PreviewProvider {
    static var previews: some View {
        Konigsberg2()
    }
}
