//
//  VertexGesture.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

class VertexGesture: ObservableObject {
    @Binding var startVertex: Vertex?
    @Binding var endVertex: Vertex?
    @ObservedObject var graph: Graph
    var vertex: Vertex
    
    init(startVertex: Binding<Vertex?>, endVertex: Binding<Vertex?>, graph: Graph, vertex: Vertex) {
        _startVertex = startVertex
        _endVertex = endVertex
        self.vertex = vertex
        self.graph = graph
    }
    
    func addEdgeGesture() {
        //Add an edge after tapping two vertices.
        //Keep track if which vertices have been selected.
        if !graph.changesLocked {
            if startVertex == nil && vertex.status != .deleted {
                startVertex = vertex
                graph.highlightedVertex = vertex
                
            } else if endVertex == nil && vertex.id != startVertex?.id {
                if startVertex!.status == .deleted {
                    startVertex = vertex
                    graph.highlightedVertex = vertex
                } else {
                    endVertex = vertex
                }
                
            } else if endVertex == nil && vertex.id == startVertex?.id {
                startVertex = nil
                graph.highlightedVertex = nil
            }
            if startVertex != nil && endVertex != nil {
                let newEdge = Edge( startVertex!,  endVertex!)
                graph.edges.append(newEdge)
                startVertex = nil
                endVertex = nil
                graph.highlightedVertex = nil
            }
        }
    }
}

#Preview {
    //VertexGesture()
}
