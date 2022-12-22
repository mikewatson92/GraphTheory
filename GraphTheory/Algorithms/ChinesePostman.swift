//
//  ChinesePostman.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class ChinesePostmanModel: ObservableObject {
    var model: ModelData
    @Published var startingVertex: Vertex?
    @Published var currentVertex: Vertex?
    @Published var path: [Vertex] = []
    @Published var usedEdges: [Edge] = []
    @Published var isStart: Bool = true
    @Published var weight: Double = 0
    @Published var overWeight: Bool = false
    @Published var status: Status = .inProgress
    var visitedEdges: [Edge] = []
    public static var colors: [Color] = [.white, Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1))]
    var oddVertices: [Vertex] {
        return model.vertices.filter { model.degree($0) % 2 == 1 }
    }
    var oddVertexPairings: [[Vertex]] {
        if !oddVertices.isEmpty{
            return Permutation.permuteVertices(oddVertices)
        } else {
            return [[]]
        }
    }
    var leastOddVertexPairing: [Vertex] {
        var leastWeightPairing: [Vertex] = oddVertexPairings[0]
        var leastWeight: Double = leastPathWeight(leastWeightPairing)
        for pairing in oddVertexPairings {
            let newWeight = leastPathWeight(pairing)
            if newWeight < leastWeight {
                leastWeight = newWeight
                leastWeightPairing = pairing
            }
        }
        return leastWeightPairing
    }
    var leastWeight: Double {
        var weight: Double = 0
        for edge in model.edges {
            weight += edge.weight
        }
        weight += leastPathWeight(leastOddVertexPairing)
        
        return weight
    }

    init(model: ModelData) {
        self.model = model
    }
    
    enum Status {
        case inProgress
        case win
        case lose
    }
    
    func timesEdgeUsed(_ edge: Edge) -> Int {
        let filteredEdges = usedEdges.filter { $0.id == edge.id }
        return filteredEdges.count
    }
    
    func isConnected(_ edge: Edge) -> Bool {
        
        if currentVertex != nil {
            return edge.startVertex.id == currentVertex!.id || edge.endVertex.id == currentVertex!.id
        } else {
            return edge.startVertex.id == startingVertex!.id || edge.endVertex.id == startingVertex!.id
        }
    }
    
    func setCurrentVertex(_ edge: Edge) {
        if isConnected(edge) {
            if edge.startVertex.id == currentVertex!.id {
                currentVertex = edge.endVertex
                path.append(edge.endVertex)
            } else {
                currentVertex = edge.startVertex
                path.append(edge.startVertex)
            }
        }
    }
    
    func findAllPaths(from: Vertex, to: Vertex, start: Bool = true, currentPath: [Edge] = [],
                      successfulPaths: [[Edge]] = [[]], usedPaths: [[Edge]] = [[]]) -> [[Edge]]{
        
        // Check all edges, determine which ones are connected to the "to" vertex, and append
        // the currentPath to succesfulPaths
        var currentPath = currentPath
        var usedPaths = usedPaths
        var successfulPaths = successfulPaths
        // currentVertex is the last vertex in currentPath. If currentPath is empty,
        // then currentVertex is set to the starting vertex "from".
        
        let currentVertex: Vertex = currentPath.last?.endVertex ?? from
        
        for edge in model.edges {
            var tempPath = currentPath
            tempPath.append(edge)
            if !usedPaths.contains(tempPath) {
                // If the edge connects the currentVertex to the target "to" vertex
                if currentVertex.edgeIsConnected(edge: edge) && to.edgeIsConnected(edge: edge) {
                    // Make sure the end vertex matches the "to vertex"
                    if edge.startVertex.id == to.id {
                        edge.swapVertices()
                    }
                    // Append succesful edge to currentPath, and then append currentPath to successfulPaths.
                    currentPath.append(edge)
                    if !successfulPaths.contains(currentPath) {
                        successfulPaths.append(currentPath)
                        
                        // Add current path to array "usedPaths", then
                        // backtrack one edge from currentPath to search for new edges
                        usedPaths.append(currentPath)
                        currentPath.remove(at: currentPath.count - 1)
                        return findAllPaths(from: from, to: to, start: false, currentPath: currentPath,
                                            successfulPaths: successfulPaths, usedPaths: usedPaths)
                    }
                    // If edge is connected to "currentVertex" and the edge is not already in "currentPath"
                    // but it still isn't connected to the final "to" vertex
                } else if currentVertex.edgeIsConnected(edge: edge) && !currentPath.contains(where: { $0.id == edge.id }) {
                    // Make sure the start vertex matches the currentVertex
                    if edge.endVertex.id == currentVertex.id {
                        edge.swapVertices()
                    }
                    // Append edge to "currentPath" then make recursive function call on updated parameters
                    currentPath.append(edge)
                    return findAllPaths(from: from, to: to, start: false, currentPath: currentPath,
                                        successfulPaths: successfulPaths, usedPaths: usedPaths)
                }
            } else { // If adding the new edge to the currentPath results in a path in usedPaths
                usedPaths.append(currentPath)
            }
        }
        if currentPath.count > 0 {
            if !usedPaths.contains(currentPath) {
                usedPaths.append(currentPath)
            }
            currentPath.remove(at: currentPath.count - 1)
            return findAllPaths(from: from, to: to, start: false, currentPath: currentPath,
                         successfulPaths: successfulPaths, usedPaths: usedPaths)
        }
        successfulPaths.removeAll(where: { $0.count == 0 })
        return successfulPaths
    }
    
    func lowestWeightPath(from: Vertex, to: Vertex) -> [Edge] {
        let allPaths = findAllPaths(from: from, to: to)
        var leastPath: [Edge]?
        var leastWeight: Double?
                
        for path in 0..<allPaths.count {
            var weight = 0.0
            for edge in 0..<allPaths[path].count {
                weight += allPaths[path][edge].weight
            }
            if leastWeight == nil {
                leastWeight = weight
                leastPath = allPaths[path]
            } else if weight < leastWeight! {
                leastWeight = weight
                leastPath = allPaths[path]
            }
        }
        return leastPath!
    }
    
    func leastWeight(from: Vertex, to: Vertex) -> Double {
        let path: [Edge] = lowestWeightPath(from: from, to: to)
        var weight = 0.0
        for edge in 0..<path.count {
            weight += path[edge].weight
        }
        return weight
    }
    
    // This function determines the least weight of all pairs of vertices
    // in a path specified by "vertices". Vertices in positions 2i and 2i + 1
    // are considered to be a pair of odd vertices.
    func leastPathWeight(_ vertices: [Vertex]) -> Double {
        var weight: Double = 0
        if vertices.count > 0 {
            for i in 0...vertices.count / 2 - 1 {
                weight += leastWeight(from: vertices[2*i], to: vertices[2*i + 1])
            }
        }
        return weight
    }
    
    func reset() {
        for edge in model.edges {
            edge.timesSelectedCPP = 0
        }
        model.highlightedVertex = nil
        weight = 0
        status = .inProgress
        isStart = true
    }
    
    func allEdgesUsed() -> Bool {
        for edge in model.edges {
            if !usedEdges.contains(edge) {
                return false
            }
        }
        return true
    }
    
    func checkStatus() {
        if weight > leastWeight {
            status = .lose
        } else if allEdgesUsed() && weight == leastWeight {
            status = .win
        } else {
            status = .inProgress
        }
    }
    
}

struct ChinesePostman: View {
    @StateObject var chinesePostmanModel: ChinesePostmanModel
    @ObservedObject var model: ModelData
    var style: LinearGradient {
        switch chinesePostmanModel.status {
        case .inProgress:
            return LinearGradient(colors: [darkGray], startPoint: .top, endPoint: .bottom)
        case .win:
            return blueGradient
        case .lose:
            return redGradient
        }
    }
    
    
    init(model: ModelData) {
        self.model = model
        _chinesePostmanModel = .init(wrappedValue: ChinesePostmanModel(model: model))
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundStyle(style)
            
            HStack{
                Spacer()
                Button("Clear") {
                    chinesePostmanModel.reset()
                }
                .padding()
            }
            
            ForEach(model.edges) { edge in
                EdgeView(edge: edge, showWeights: .constant(true), model: model)
                    .onAppear {
                        model.algorithm = .chinesePostman
                        model.changesLocked = true
                        model.weightChangeLocked = true
                    }
                    .onTapGesture(count: 1) {
                        if chinesePostmanModel.status == .inProgress {
                            if !chinesePostmanModel.isStart && chinesePostmanModel.isConnected(edge) {
                                edge.timesSelectedCPP += 1
                                chinesePostmanModel.weight += edge.weight
                                if !chinesePostmanModel.usedEdges.contains(edge) {
                                    chinesePostmanModel.usedEdges.append(edge)
                                }
                                if chinesePostmanModel.currentVertex == edge.startVertex {
                                    model.highlightedVertex = edge.endVertex
                                    chinesePostmanModel.currentVertex = edge.endVertex
                                } else {
                                    model.highlightedVertex = edge.startVertex
                                    chinesePostmanModel.currentVertex = edge.startVertex
                                }
                                chinesePostmanModel.checkStatus()
                            }
                        }
                    }
            }
                
            ForEach(model.vertices) { vertex in
                VertexView(vertex: vertex, model: model)
                    .onAppear{
                        model.algorithm = .chinesePostman
                        model.changesLocked = true
                        model.weightChangeLocked = true
                    }
                    .onTapGesture(count: 1) {
                        if chinesePostmanModel.isStart {
                            model.highlightedVertex = vertex
                            chinesePostmanModel.startingVertex = vertex
                            chinesePostmanModel.currentVertex = vertex
                            chinesePostmanModel.isStart = false
                        }
                    }
            }
        }
        .onDisappear {
            model.algorithm = .none
            model.changesLocked = false
            model.weightChangeLocked = false
            model.highlightedVertex = nil
            for edge in model.edges {
                edge.status = .none
                edge.isSelected = false
            }
        }
        .navigationTitle("Chinese Postman Problem")
    }
}

struct ChinesePostman_Previews: PreviewProvider {
    static var previews: some View {
        ChinesePostman(model: ModelData())
    }
}
