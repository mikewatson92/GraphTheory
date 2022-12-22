//
//  Graph.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class Graph {
    var model: ModelData
    var chosenEdges: [Edge]
    
    init(chosenEdges: [Edge], model: ModelData) {
        self.model = model
        self.chosenEdges = chosenEdges
    }
    
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
    }
    
    func hasCycle(availableEdges available: [Edge]) -> Bool {
        for vertex in model.vertices {
            let result = cycleFromVertex(path: [vertex.id], availableEdges: available)
            if result == true {
                return true
            }
        }
        return false
    }
    
}
