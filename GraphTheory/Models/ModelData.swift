//
//  ModelData.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class ModelData: ObservableObject {
    @Published var edges: [Edge] = []
    @Published var vertices: [Vertex] = []
    @Published var highlightedVertex: Vertex?
    @Published var isMoving: Bool = false
    @Published var algorithm: GraphAlgorithm = .none
    @Published var changesLocked: Bool = false
    @Published var weightChangeLocked: Bool = false
    @Published var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                             "T", "U", "V", "W", "X", "Y", "Z"]
    
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
