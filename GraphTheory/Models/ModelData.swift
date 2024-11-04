//
//  ModelData.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class ModelData: ObservableObject {
    @Published var edges: [Edge]
    @Published var vertices: [Vertex]
    @Published var highlightedVertex: Vertex?
    @Published var isMoving: Bool
    @Published var algorithm: GraphAlgorithm
    @Published var changesLocked: Bool
    @Published var weightChangeLocked: Bool
    @Published var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                             "T", "U", "V", "W", "X", "Y", "Z"]
    
    init(edges: [Edge] = [], vertices: [Vertex] = [], highlightedVertex: Vertex? = nil, isMoving: Bool = false, algorithm: GraphAlgorithm = .none, changesLocked: Bool = false, weightChangeLocked: Bool = false) {
        self.edges = edges
        self.vertices = vertices
        self.highlightedVertex = highlightedVertex
        self.isMoving = isMoving
        self.algorithm = algorithm
        self.changesLocked = changesLocked
        self.weightChangeLocked = weightChangeLocked
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
