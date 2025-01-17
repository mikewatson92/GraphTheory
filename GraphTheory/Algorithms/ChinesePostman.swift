//
//  ChinesePostman.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/24/24.
//

import SwiftUI

struct ChinesePostman {
    let graph: Graph
    var oddVertices: [Vertex] {
        var oddVertices: [Vertex] = []
        for vertex in Array(graph.vertices.values) {
            if graph.degree(vertex) % 2 == 1 {
                oddVertices.append(vertex)
            }
        }
        return oddVertices
    }
    // A complete graph whose vertices are all the odd vertices in graph
    // and the weights of the edges represent the smallest weight path
    // between two vertices in the base graph.
    var tJoinCompleteGraph = Graph()
    var perfectMatchings: [[Edge]] = []
    var maxedOutEdges: [Edge] = []
    
    init(graph: Graph) {
        self.graph = graph
        self.tJoinCompleteGraph = Graph(vertices: oddVertices)
        if !oddVertices.isEmpty {
            for vertex in oddVertices {
                var otherVertices = oddVertices
                otherVertices.removeAll(where: { $0.id == vertex.id })
                for otherVertex in otherVertices {
                    var edge = Edge(startVertexID: vertex.id, endVertexID: otherVertex.id)
                    edge.weight = graph.smallestDistance(from: vertex, to: otherVertex) ?? 0
                    if !Array(tJoinCompleteGraph.edges.values).contains(where: { ($0.startVertexID == edge.startVertexID && $0.endVertexID == edge.endVertexID) || ($0.startVertexID == edge.endVertexID && $0.endVertexID == edge.startVertexID) }) {
                        tJoinCompleteGraph.edges[edge.id] = edge
                    }
                }
            }
        }
        if graph.isConnected() {
            getAllPerfectMatchingsInT()
        }
    }
    
    func getAllNonAdjacentEdgesInT(to edges: [Edge]) -> [Edge] {
        var nonAdjacentEdges: [Edge] = Array(tJoinCompleteGraph.edges.values)
        guard nonAdjacentEdges.count > 0 else { return [] }

        // Remove any adjacent edges
        for tJoinEdge in Array(tJoinCompleteGraph.edges.values) {
            for givenEdge in edges {
                if givenEdge.startVertexID == tJoinEdge.startVertexID || givenEdge.startVertexID == tJoinEdge.endVertexID || givenEdge.endVertexID == tJoinEdge.startVertexID || givenEdge.endVertexID == tJoinEdge.endVertexID {

                    nonAdjacentEdges.removeAll(where: { $0.id == tJoinEdge.id })
                }
            }
        }
        return nonAdjacentEdges
    }
    
    func areMatchingsEqual(_ matching1: [Edge], _ matching2: [Edge]) -> Bool {
        var remainingMatching1 = matching1
        var remainingMatching2 = matching2
        
        for edge in matching1 {
            remainingMatching2.removeAll(where: { $0.id == edge.id })
        }
        
        for edge in matching2 {
            remainingMatching1.removeAll(where: { $0.id == edge.id })
        }
        
        return remainingMatching1.count == 0 && remainingMatching2.count == 0
    }
    
    func getUniqueMatchings(_ matchings: [[Edge]]) -> [[Edge]] {
        var uniqueMatchings: [[Edge]] = []
        for matching in matchings {
            if !uniqueMatchings.contains(where: { areMatchingsEqual($0, matching) }) {
                uniqueMatchings.append(matching)
            }
        }
        return uniqueMatchings
    }
    
    func numberOfTimesEdgeAppearsInMatchings(_ edge: Edge, matchings: [[Edge]]) -> Int {
        var result = 0
        for matching in matchings {
            for matchingEdge in matching {
                if matchingEdge.id == edge.id {
                    result += 1
                }
            }
        }
        return result
    }
    
    mutating func getAllPerfectMatchingsInT(currentMatching: [Edge] = []) {
        guard tJoinCompleteGraph.edges.count > 0 else { return }
        guard tJoinCompleteGraph.vertices.count % 2 == 0 else { return }
        guard graph.isConnected() else { return }

        // Check if all perfect matchings are found
        let expectedMatchings = DoubleFactorial.doubleFactorial(n: oddVertices.count - 1)
        if perfectMatchings.count == expectedMatchings {
            return
        }

        // Check if current matching is complete
        if currentMatching.count == oddVertices.count / 2 {
            // Check if the current matching is unique
            if !perfectMatchings.contains(where: { areMatchingsEqual($0, currentMatching) }) {
                perfectMatchings.append(currentMatching)
            }
            return
        }

        // Get available edges
        var availableEdges = getAllNonAdjacentEdgesInT(to: currentMatching)
        availableEdges.removeAll(where: { edge in maxedOutEdges.contains(where: { $0.id == edge.id }) })

        if availableEdges.isEmpty {
            return // No valid edges left
        }

        // Iterate through available edges
        for edge in availableEdges {
            var newMatching = currentMatching
            newMatching.append(edge)

            // Recursive call
            getAllPerfectMatchingsInT(currentMatching: newMatching)
        }
    }
    
    func getMinimumWeightPerfectMatchings() -> [[Edge]] {
        var result: [[Edge]] = []
        var minimumMatchingWeight: Double? = nil
        for matching in perfectMatchings {
            let weight = getMatchingWeight(matching)
            if minimumMatchingWeight == nil {
                minimumMatchingWeight = weight
            }
            if weight < minimumMatchingWeight! {
                minimumMatchingWeight = weight
            }
        }
        for matching in perfectMatchings {
            if getMatchingWeight(matching) == minimumMatchingWeight {
                result.append(matching)
            }
        }
        return result
    }
    
    func getMatchingWeight(_ matching: [Edge]) -> Double {
        var weight = 0.0
        for edge in matching {
            weight += edge.weight
        }
        return weight
    }
}

class ChinesePostmanViewModel: ObservableObject {
    @Published var chinesePostman: ChinesePostman
    @Published var chosenEdges: [Edge] = []
    @Published var errorStatus: ErrorStatus = .none
    @Published var step: Step = .chooseVertex
    @Published var currentVertex: Vertex?
    var possibleTJoins: [[Edge]] = []
    
    init(graph: Graph) {
        self.chinesePostman = ChinesePostman(graph: graph)
        for tJoin in chinesePostman.getMinimumWeightPerfectMatchings() {
            possibleTJoins.append(tJoin)
        }
    }
    
    enum ErrorStatus: String {
        case none
        case nonTJoinDuplicate = "You should only repeat edges if they are part of the shortest path between two odd vertices."
        case tJoinEdgeRepeat = "You've already crossed this edge twice."
        case notAdjacentEdge = "That edge doesn't connect to your current vertex."
    }
    
    enum Step {
        case chooseVertex
        case selectEdges
        case finished
    }
    
    func chooseEdge(_ edge: Edge) {
        guard step == .selectEdges else { return }
        guard edge.startVertexID == currentVertex?.id || edge.endVertexID == currentVertex?.id else {
            errorStatus = .notAdjacentEdge
            return
        }
        
        if !chosenEdges.contains(where: { $0.id == edge.id }) {
            chosenEdges.append(edge)
            currentVertex = chinesePostman.graph.vertices[edge.traverse(from: currentVertex!.id)!]
            checkForCompletion()
        } else if chosenEdges.count(where: { $0.id == edge.id }) == 1 {
            // Check to see if the chosen edge is part of a T-Join.
            for tJoin in possibleTJoins {
                for tJoinEdge in tJoin {
                    let shortestTrails = chinesePostman.graph.shortestTrails(from: chinesePostman.graph.vertices[tJoinEdge.startVertexID]!, to: chinesePostman.graph.vertices[tJoinEdge.endVertexID]!)
                    for trail in shortestTrails {
                        if trail.contains(where: {$0.id == edge.id}) {
                            chosenEdges.append(edge)
                            currentVertex = chinesePostman.graph.vertices[edge.traverse(from: currentVertex!.id)!]
                            checkForCompletion()
                            return
                        }
                    }
                }
            }
            // If we get to this point, the edge is not a T-Join edge
            errorStatus = .nonTJoinDuplicate
            return
        } else {
            errorStatus = .tJoinEdgeRepeat
            return
        }
    }
    
    func checkForCompletion() {
        guard possibleTJoins.count == 1 else { return }
        let tJoin = possibleTJoins[0]
        var tJoinEdgeToGraphTrail: [UUID: [Edge]] = [:]
        for tJoinEdge in tJoin {
            let shortestTrails = chinesePostman.graph.shortestTrails(from: chinesePostman.graph.vertices[tJoinEdge.startVertexID]!, to: chinesePostman.graph.vertices[tJoinEdge.endVertexID]!)
            var tJoinTravelledTwice = false
            for trail in shortestTrails {
                for edge in trail {
                    if chosenEdges.count(where: {$0.id == edge.id}) != 2 {
                        break
                    } else if edge.id == trail.last?.id {
                        tJoinTravelledTwice = true
                        tJoinEdgeToGraphTrail[tJoinEdge.id] = trail
                    }
                }
            }
            if !tJoinTravelledTwice {
                return
            }
        }
        // If we get to this point, then every edge in the T-Join
        // has been travelled twice.
        var nonTJoinEdges: [Edge] = Array(chinesePostman.graph.edges.values)
        // Remove all edges that are part of a path represented by a T-Join edge
        for edge in Array(chinesePostman.graph.edges.values) {
            for tJoinEdge in tJoin {
                if tJoinEdgeToGraphTrail[tJoinEdge.id]!.contains(where: { $0.id == edge.id }) {
                    nonTJoinEdges.removeAll(where: { $0.id == edge.id })
                    break
                }
            }
        }
        // Check if all non-T-join edges have been traversed exactly once
        for edge in nonTJoinEdges {
            if chosenEdges.count(where: { $0.id == edge.id }) != 1 {
                return
            }
        }
        // If we get here, the algorithm is finished
        step = .finished
        return
    }
    
    func getSolutionTotalWeight() -> Double {
        var totalWeight = 0.0
        for edge in chosenEdges {
            totalWeight += edge.weight
        }
        return totalWeight
    }
    
    func getAllVertices() -> [Vertex] {
        return Array(chinesePostman.graph.vertices.values)
    }
    
    func getAllEdges() -> [Edge] {
        return Array(chinesePostman.graph.edges.values)
    }
}

struct ChinesePostmanView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject var chinesePostmanViewModel: ChinesePostmanViewModel
    @StateObject var graphViewModel = GraphViewModel(graph: Graph())
    @State private var edgeError: Edge?
    @State private var edgeColors: [Color] = []
    @State private var showBanner = true {
        willSet {
            showInstructions = false
        }
    }
    @State private var showInstructions = true
    
    init(graph: Graph) {
        self._chinesePostmanViewModel = StateObject(wrappedValue: ChinesePostmanViewModel(graph: graph))
        self._graphViewModel = StateObject(wrappedValue: GraphViewModel(graph: graph, showWeights: true))
    }
    
    var body: some View {
        if !graphViewModel.graph.isConnected() {
            Text("This graph is not connected, so the Chinese Postman problem has no solution.")
        } else {
            VStack {
                if showBanner {
                    if showInstructions {
                        Instructions(showBanner: $showBanner, text: "Choose a starting vertex. Then select edges to design the optimal walk that traverses all of the edges.")
                    } else if chinesePostmanViewModel.errorStatus != .none {
                        Instructions(showBanner: $showBanner, text: chinesePostmanViewModel.errorStatus.rawValue)
                    } else if chinesePostmanViewModel.step == .finished {
                        Instructions(showBanner: $showBanner, text: "The solution has a total weight of: \(chinesePostmanViewModel.getSolutionTotalWeight().formatted())")
                    }
                }
                GeometryReader{ geometry in
                    ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                        EdgeView(edgeViewModel: edgeViewModel)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    showInstructions = false
                                    if chinesePostmanViewModel.step == .selectEdges {
                                        if let error = edgeError {
                                            if edge.id == error.id {
                                                showBanner = false
                                                chinesePostmanViewModel.errorStatus = .none
                                                edgeError = nil
                                                edgeViewModel.color = edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })]
                                                graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                            }
                                        } else {
                                            withAnimation {
                                                chinesePostmanViewModel.chooseEdge(edge)
                                            }
                                            if chinesePostmanViewModel.errorStatus != .none {
                                                edgeError = edge
                                                edgeViewModel.color = .red
                                                graphViewModel.setColorForEdge(edge: edge, color: .red)
                                                showBanner = true
                                            } else {
                                                edgeViewModel.color = edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })]
                                                graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                                if chinesePostmanViewModel.step == .finished {
                                                    showBanner = true
                                                }
                                            }
                                        }
                                    }
                                })
                    }
                    ForEach(graphViewModel.getVertices()) { vertex in
                        let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                            .shadow(color: (chinesePostmanViewModel.currentVertex?.id == vertex.id ? themeViewModel.theme!.accent : .clear), radius: 10)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    showInstructions = false
                                    if chinesePostmanViewModel.currentVertex == nil {
                                        chinesePostmanViewModel.currentVertex = vertex
                                        chinesePostmanViewModel.step = .selectEdges
                                    }
                                })
                    }
                }
                .onAppear {
                    edgeColors = [themeViewModel.theme!.secondary, themeViewModel.theme!.accent, themeViewModel.theme!.primary]
                }
            }
        }
    }
}

#Preview {
    //ChinesePostmanView()
}
