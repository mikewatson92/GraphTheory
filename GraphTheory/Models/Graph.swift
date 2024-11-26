//
//  Graph.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class Graph: ObservableObject {
    @Published var edges: [Edge]
    @Published var vertices: [Vertex]
    @Published var highlightedVertex: Vertex?
    @Published var isMoving: Bool
    @Published var algorithm: Graph.Algorithm
    @Published var changesLocked: Bool
    @Published var weightChangeLocked: Bool
    @Published var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                             "T", "U", "V", "W", "X", "Y", "Z"]
    
    init(edges: [Edge] = [], vertices: [Vertex] = [], highlightedVertex: Vertex? = nil, isMoving: Bool = false, algorithm: Graph.Algorithm = .none, changesLocked: Bool = false, weightChangeLocked: Bool = false) {
        self.edges = edges
        self.vertices = vertices
        self.highlightedVertex = highlightedVertex
        self.isMoving = isMoving
        self.algorithm = algorithm
        self.changesLocked = changesLocked
        self.weightChangeLocked = weightChangeLocked
    }
    
    enum Algorithm: String, Identifiable, CaseIterable {
        case none = "none"
        case kruskal = "Kruskal's Algorithm"
        case prim = "Prim's Algorithm"
        case primTable = "Prim's Table Algorithm"
        case tsp = "Travelling Salesman Problem"
        case chinesePostman = "Chinese Postman Problem"
        case euler = "Eulerian Circuit"
        
        var id: Self { self }
    }
    
    func hasCycle() -> Bool {
        func cycleFromVertex(path pathInput: [UUID], availableEdges available: [Edge]) -> Bool {
            var path = pathInput
            var availableEdges = available
            for edge in availableEdges {
                if edge.startVertex.id == path.last {
                    if path.contains(edge.endVertex.id) { return true }
                    path.append(edge.endVertex.id)
                    availableEdges.removeAll(where: {$0.id == edge.id} )
                    return cycleFromVertex(path: path, availableEdges: availableEdges)
                } else if edge.endVertex.id == path.last {
                    if path.contains(edge.startVertex.id) { return true }
                    path.append(edge.startVertex.id)
                    availableEdges.removeAll(where: {$0.id == edge.id} )
                    return cycleFromVertex(path: path, availableEdges: availableEdges)
                }
            }
            
            if path.count > 1 {
                path.removeLast()
                return cycleFromVertex(path: path, availableEdges: availableEdges)
            }
            return false
        } // End of func cycleFromVertex
        
        for vertex in vertices {
            let result = cycleFromVertex(path: [vertex.id], availableEdges: edges)
            if result == true {
                return true
            }
        }
        return false
    }
    
    func degree(_ vertex: Vertex) -> Int {
        var counter = 0
        for edge in edges {
            if vertex.edgeIsConnected(edge: edge) { counter += 1 }
        }
        return counter
    }
    
    func verticesConnected(_ vertex1: Vertex, _ vertex2: Vertex) -> Bool {
        for edge in edges {
            if vertex1.edgeIsConnected(edge: edge) && vertex2.edgeIsConnected(edge: edge) {
                return true
            }
        }
        return false
    }
}
