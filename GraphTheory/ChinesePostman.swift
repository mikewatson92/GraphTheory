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
                    print("The shortest weight for \(graph.edgeDescription(edge)) is \(edge.weight).")
                    if !Array(tJoinCompleteGraph.edges.values).contains(where: { ($0.startVertexID == edge.startVertexID && $0.endVertexID == edge.endVertexID) || ($0.startVertexID == edge.endVertexID && $0.endVertexID == edge.startVertexID) }) {
                        tJoinCompleteGraph.edges[edge.id] = edge
                        print("Adding edge to T-join: \(graph.edgeDescription(edge))")
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
        print("The adjacent edges are:")
        for edge in nonAdjacentEdges {
            print(graph.edgeDescription(edge))
        }
        // Remove any adjacent edges
        for tJoinEdge in Array(tJoinCompleteGraph.edges.values) {
            for givenEdge in edges {
                if givenEdge.startVertexID == tJoinEdge.startVertexID || givenEdge.startVertexID == tJoinEdge.endVertexID || givenEdge.endVertexID == tJoinEdge.startVertexID || givenEdge.endVertexID == tJoinEdge.endVertexID {

                    nonAdjacentEdges.removeAll(where: { $0.id == tJoinEdge.id })
                }
            }
        }
        print("Getting non-adjacent edges to matching: ")
        for edge in edges {
            print(graph.edgeDescription(edge))
        }
        print("The non-adjacent edges are:")
        for edge in nonAdjacentEdges {
            print(graph.edgeDescription(edge))
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
            print("Here are all perfect matchings:")
            for (index, matching) in perfectMatchings.enumerated() {
                print("Matching #\(index):")
                for edge in matching {
                    print(graph.edgeDescription(edge))
                }
            }
            return
        }

        // Check if current matching is complete
        if currentMatching.count == oddVertices.count / 2 {
            // Check if the current matching is unique
            if !perfectMatchings.contains(where: { areMatchingsEqual($0, currentMatching) }) {
                print("Found a unique perfect matching:")
                for edge in currentMatching {
                    print(graph.edgeDescription(edge))
                }
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
        print("The number of T-joins is \(possibleTJoins.count)")
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
                    print("Checking T-join edge")
                    let shortestTrails = chinesePostman.graph.shortestTrails(from: chinesePostman.graph.vertices[tJoinEdge.startVertexID]!, to: chinesePostman.graph.vertices[tJoinEdge.endVertexID]!)
                    print("There " + (shortestTrails.count == 1 ? "is " : "are ") + "\(shortestTrails.count) " + (shortestTrails.count == 1 ? "edge " : "edges ") + "for \(chinesePostman.graph.edgeDescription(tJoinEdge))")
                    for trail in shortestTrails {
                        print("Trail #\(shortestTrails.firstIndex(of: trail)!):")
                        for edge in trail {
                            print(chinesePostman.graph.edgeDescription(edge))
                        }
                    }
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
    @State private var edgeColors: [Color] = [Color(#colorLiteral(red: 0, green: 1, blue: 0.3673055172, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1))]
    
    init(graph: Graph) {
        self._chinesePostmanViewModel = StateObject(wrappedValue: ChinesePostmanViewModel(graph: graph))
        self._graphViewModel = StateObject(wrappedValue: GraphViewModel(graph: graph, showWeights: true))
    }
    
    var body: some View {
        if !graphViewModel.getGraph().isConnected() {
            Text("This graph is not connected, so the Chinese Postman problem has no solution.")
        } else {
            ZStack {
                GeometryReader{ geometry in
                    ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                        EdgeView(edgeViewModel: edgeViewModel)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    if chinesePostmanViewModel.step == .selectEdges {
                                        if let error = edgeError {
                                            if edge.id == error.id {
                                                chinesePostmanViewModel.errorStatus = .none
                                                edgeError = nil
                                                edgeViewModel.setColor(edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                                graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                            }
                                        } else {
                                            withAnimation {
                                                chinesePostmanViewModel.chooseEdge(edge)
                                            }
                                            if chinesePostmanViewModel.errorStatus != .none {
                                                edgeError = edge
                                                edgeViewModel.setColor(.red)
                                                graphViewModel.setColorForEdge(edge: edge, color: .red)
                                            } else {
                                                edgeViewModel.setColor(edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                                graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                            }
                                        }
                                    }
                                })
                    }
                    ForEach(graphViewModel.getVertices()) { vertex in
                        let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                            .shadow(color: (chinesePostmanViewModel.currentVertex?.id == vertex.id ? .green : .clear), radius: 10)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    if chinesePostmanViewModel.currentVertex == nil {
                                        chinesePostmanViewModel.currentVertex = vertex
                                        chinesePostmanViewModel.step = .selectEdges
                                    }
                                })
                    }
                }
                .onAppear {
                    edgeColors.insert(colorScheme == .light ? .black : .white , at: 0)
                }
                
                if chinesePostmanViewModel.errorStatus != .none {
                    VStack {
                        Text(chinesePostmanViewModel.errorStatus.rawValue)
                            .foregroundColor(themeViewModel.theme!.primaryColor)
                            .padding()
                            .background(themeViewModel.theme!.secondaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Spacer()
                    }
                    .padding([.top], 25)
                    .zIndex(1)
                    .transition(.move(edge: .top))
                }
                if chinesePostmanViewModel.step == .finished {
                    VStack {
                        Text("The solution has a total weight of: \(chinesePostmanViewModel.getSolutionTotalWeight().formatted())")
                            .foregroundColor(themeViewModel.theme!.primaryColor)
                            .padding()
                            .background(themeViewModel.theme!.secondaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Spacer()
                    }
                    .padding([.top], 25)
                    .zIndex(1)
                    .transition(.move(edge: .top))
                }
            }
        }
    }
}

#Preview {
    //ChinesePostmanView()
}
