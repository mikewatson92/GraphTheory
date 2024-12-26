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
        getAllPerfectMatchingsInT()
    }
    
    func getAllNonAdjacentEdgesInT(to edges: [Edge]) -> [Edge] {
        var nonAdjacentEdges: [Edge] = Array(tJoinCompleteGraph.edges.values)
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
        guard tJoinCompleteGraph.edges.count != 0 else { return }
        // If we have found all of the perfect matchings
        if perfectMatchings.count == DoubleFactorial().doubleFactorial(n: oddVertices.count - 1) {
            print("Here are all perfect matchings:")
            for matching in perfectMatchings {
                print("Matching #\(perfectMatchings.firstIndex(of: matching)!):")
                for edge in matching {
                    print(graph.edgeDescription(edge))
                }
            }
            return
        } else if currentMatching.count == oddVertices.count / 2 {
            // If the current matching is a perfect matching
            // If the current matching is not currently in currentPerfectMatchings
            var isUnique = true
            for perfectMatching in perfectMatchings {
                if areMatchingsEqual(perfectMatching, currentMatching) {
                    isUnique = false
                    break
                }
            }
            if isUnique {
                print("Found a unique perfect matching:")
                for edge in currentMatching {
                    print(graph.edgeDescription(edge))
                }
                perfectMatchings.append(currentMatching)
                for perfectMatching in perfectMatchings {
                    for edge in perfectMatching {
                        if numberOfTimesEdgeAppearsInMatchings(edge, matchings: perfectMatchings) == DoubleFactorial().doubleFactorial(n: oddVertices.count - 2 - 1) {
                            maxedOutEdges.append(edge)
                        }
                    }
                }
                getAllPerfectMatchingsInT()
            } else { // If the matching is not unique
                for perfectMatching in perfectMatchings {
                    for edge in perfectMatching {
                        if numberOfTimesEdgeAppearsInMatchings(edge, matchings: perfectMatchings) == DoubleFactorial().doubleFactorial(n: oddVertices.count - 2 - 1) {
                            maxedOutEdges.append(edge)
                        }
                    }
                }
                getAllPerfectMatchingsInT()
            }
        } else { // If we get here, the currentMatching is not yet a perfect matching
            var availableAdjacentEdges = getAllNonAdjacentEdgesInT(to: currentMatching)
            for edge in maxedOutEdges {
                availableAdjacentEdges.removeAll(where: { $0.id == edge.id })
            }
            for perfectMatching in perfectMatchings {
                for edge in perfectMatching {
                    if numberOfTimesEdgeAppearsInMatchings(edge, matchings: perfectMatchings) == DoubleFactorial().doubleFactorial(n: oddVertices.count - 2 - 1) {
                        maxedOutEdges.append(edge)
                        availableAdjacentEdges.removeAll(where: { $0.id == edge.id })
                    }
                }
            }
            var newMatching = currentMatching
            if availableAdjacentEdges.count == 0 {
                return
            }
            newMatching.append(availableAdjacentEdges[0])
            print("Still working on building a perfect matching for:")
            for edge in newMatching {
                print(graph.edgeDescription(edge))
            }
            
            if perfectMatchings.count == DoubleFactorial().doubleFactorial(n: oddVertices.count - 1) {
                print("Here are all perfect matchings:")
                for matching in perfectMatchings {
                    print("Matching #\(perfectMatchings.firstIndex(of: matching)!):")
                    for edge in matching {
                        print(graph.edgeDescription(edge))
                    }
                }
                return
            }
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
    @Published var graphViewModel: GraphViewModel
    @Published var currentVertex: Vertex?
    var possibleTJoins: [[Edge]] = []
    
    init(graph: Graph) {
        self.chinesePostman = ChinesePostman(graph: graph)
        self.graphViewModel = GraphViewModel(graph: graph, showWeights: true)
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
                    let shortestPaths = chinesePostman.graph.shortestPaths(from: chinesePostman.graph.vertices[tJoinEdge.startVertexID]!, to: chinesePostman.graph.vertices[tJoinEdge.endVertexID]!)
                    print("There " + (shortestPaths.count == 1 ? "is " : "are ") + "\(shortestPaths.count) " + (shortestPaths.count == 1 ? "edge " : "edges ") + "for \(chinesePostman.graph.edgeDescription(tJoinEdge))")
                    for path in shortestPaths {
                        print("Path #\(shortestPaths.firstIndex(of: path)!):")
                        for edge in path {
                            print(chinesePostman.graph.edgeDescription(edge))
                        }
                    }
                    for path in shortestPaths {
                        if path.contains(where: {$0.id == edge.id}) {
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
        var tJoinEdgeToGraphPath: [UUID: [Edge]] = [:]
        for tJoinEdge in tJoin {
            let shortestPaths = chinesePostman.graph.shortestPaths(from: chinesePostman.graph.vertices[tJoinEdge.startVertexID]!, to: chinesePostman.graph.vertices[tJoinEdge.endVertexID]!)
            var tJoinTravelledTwice = false
            for path in shortestPaths {
                for edge in path {
                    if chosenEdges.count(where: {$0.id == edge.id}) != 2 {
                        break
                    } else if edge.id == path.last?.id {
                        tJoinTravelledTwice = true
                        tJoinEdgeToGraphPath[tJoinEdge.id] = path
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
                if tJoinEdgeToGraphPath[tJoinEdge.id]!.contains(where: { $0.id == edge.id }) {
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
    @ObservedObject var chinesePostmanViewModel: ChinesePostmanViewModel
    @ObservedObject var graphViewModel = GraphViewModel(graph: Graph())
    @State private var edgeError: Edge?
    @State private var edgeColors: [Color] = [Color(#colorLiteral(red: 0, green: 1, blue: 0.3673055172, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1))]
    
    init(graph: Graph) {
        self.chinesePostmanViewModel = ChinesePostmanViewModel(graph: graph)
        self.graphViewModel = chinesePostmanViewModel.graphViewModel
    }
    
    var body: some View {
        if !chinesePostmanViewModel.graphViewModel.getGraph().isConnected() {
            Text("This graph is not connected, so the Chinese Postman problem has no solution.")
        } else {
            ZStack {
                GeometryReader{ geometry in
                    ForEach(chinesePostmanViewModel.graphViewModel.getEdges()) { edge in
                        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: chinesePostmanViewModel.graphViewModel)
                        EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
                            .highPriorityGesture(TapGesture(count: 1)
                                .onEnded {
                                    if chinesePostmanViewModel.step == .selectEdges {
                                        if let error = edgeError {
                                            if edge.id == error.id {
                                                chinesePostmanViewModel.errorStatus = .none
                                                edgeError = nil
                                                edgeViewModel.setColor(edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                                chinesePostmanViewModel.graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                            }
                                        } else {
                                            withAnimation {
                                                chinesePostmanViewModel.chooseEdge(edge)
                                            }
                                            if chinesePostmanViewModel.errorStatus != .none {
                                                edgeError = edge
                                                edgeViewModel.setColor(.red)
                                                chinesePostmanViewModel.graphViewModel.setColorForEdge(edge: edge, color: .red)
                                            } else {
                                                edgeViewModel.setColor(edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                                chinesePostmanViewModel.graphViewModel.setColorForEdge(edge: edge, color: edgeColors[chinesePostmanViewModel.chosenEdges.count(where: { $0.id == edge.id })])
                                            }
                                        }
                                    }
                                })
                    }
                    ForEach(chinesePostmanViewModel.graphViewModel.getVertices()) { vertex in
                        let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: chinesePostmanViewModel.graphViewModel)
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
