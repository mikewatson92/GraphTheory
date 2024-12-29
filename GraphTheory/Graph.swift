//
//  Graph.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct Graph: Identifiable, Codable {
    let id: UUID
    var vertices: [UUID: Vertex] = [:]
    var edges: [UUID: Edge] = [:]
    // Default values saved when the graph is initially constructed.
    // Used for restoring to defaults.
    var originalVertices: [UUID: Vertex] = [:]
    var originalEdges: [UUID: Edge] = [:]
    //
    var resetMethod: ResetFunction = .resetToZero
    var mode: Mode = .edit
    var algorithm: Algorithm = .none
    
    init() {
        id = UUID()
    }
    
    init(vertices: [Vertex] = [], edges: [Edge] = []) {
        id = UUID()
        
        for vertex in vertices {
            self.vertices[vertex.id] = vertex
        }
        
        for edge in edges {
            self.edges[edge.id] = edge
            setControlPoints(for: edge)
            setControlPoint1Offset(for: edge, translation: .zero)
            setControlPoint2Offset(for: edge, translation: .zero)
        }
        
        originalVertices = self.vertices
        originalEdges = self.edges
    }
    
    enum Algorithm: String, Codable, CaseIterable, Identifiable {
        case none = "No Algorithm"
        case kruskal = "Kruskal"
        var id: String { self.rawValue }
    }
    
    enum ResetFunction: Codable {
        case resetToZero, restoreToOriginal
    }
    
    enum Mode: String, Codable {
        case edit = "Edit"
        case explore = "Explore"
        case icosian = "Icosian"
        case algorithm = "Algorithm"
    }
    
    mutating func clear() {
        switch resetMethod {
        case .resetToZero:
            resetToZero()
        case .restoreToOriginal:
            restoreToOriginal()
        }
    }
    
    mutating func resetToZero() {
        vertices = [:]
        edges = [:]
    }
    
    mutating func restoreToOriginal() {
        vertices = originalVertices
        edges = originalEdges
    }
    
    mutating func addVertex(_ vertex: Vertex) {
        vertices[vertex.id] = vertex
    }
    
    mutating func removeVertex(_ vertex: Vertex) {
        for edge in getConnectedEdges(to: vertex.id) {
            removeEdge(edge)
        }
        vertices.removeValue(forKey: vertex.id)
    }
    
    mutating func addEdge(_ edge: Edge) {
        edges[edge.id] = edge
        setControlPoints(for: edge)
        setControlPoint1Offset(for: edge, translation: .zero)
        setControlPoint2Offset(for: edge, translation: .zero)
    }
    
    mutating func removeEdge(_ edge: Edge) {
        edges.removeValue(forKey: edge.id)
    }
    
    mutating func removeEdgesConnected(to vertexID: UUID) {
        for edge in edges.values {
            if edge.startVertexID == vertexID || edge.endVertexID == vertexID {
                removeEdge(edge)
            }
        }
    }
    
    func degree(_ vertex: Vertex) -> Int {
        return getConnectedEdges(to: vertex.id).count
    }
    
    func edgeDescription(_ edge: Edge) -> String {
        return "Edge\(vertices[edge.startVertexID]!.label)\(vertices[edge.endVertexID]!.label)"
    }
    
    func getAllTrailsBetween(_ startVertex: Vertex, _ endVertex: Vertex) -> [[Edge]] {
        var allTrails: [[Edge]] = []
        var currentTrail: [Edge] = []
        
        func dfs(currentVertex: Vertex) {
            if currentVertex.id == endVertex.id {
                allTrails.append(currentTrail)
            } else {
                var newConnectedEdges = getConnectedEdges(to: currentVertex.id)
                // Remove any edges already traversed
                for edge in currentTrail {
                    newConnectedEdges.removeAll(where: { $0.id == edge.id })
                }
                for edge in newConnectedEdges {
                    currentTrail.append(edge)
                    let nextVertexID = edge.traverse(from: currentVertex.id)!
                    let nextVertex = vertices[nextVertexID]!
                    // Recursion
                    dfs(currentVertex: nextVertex)
                    // Backtrack
                    currentTrail.removeLast()
                }
            }
        }
        dfs(currentVertex: startVertex)
        return allTrails
    }
    
    func smallestDistance(from startVertex: Vertex, to endVertex: Vertex) -> Double? {
        guard areVerticesConnected(startVertex.id, endVertex.id) else { return nil }
        let trails = getAllTrailsBetween(startVertex, endVertex)
        print("There are \(trails.count) trails from \(startVertex.label) to \(endVertex.label)")
        for trail in trails {
            print("Trail:")
            for edge in trail {
                print(edgeDescription(edge))
            }
        }
        var trailWeights: [Double] = []
        for trail in trails {
            var trailWeight = 0.0
            for edge in trail {
                trailWeight += edge.weight
            }
            trailWeights.append(trailWeight)
        }
        return trailWeights.min()
    }
    
    func shortestTrails(from startVertex: Vertex, to endVertex: Vertex) -> [[Edge]] {
        let trails = getAllTrailsBetween(startVertex, endVertex)
        guard !trails.isEmpty else { return [] }
        let smallestDistance = smallestDistance(from: startVertex, to: endVertex)
        var shortestTrails: [[Edge]] = []
        
        for trail in trails {
            if walkWeight(trail) == smallestDistance {
                shortestTrails.append(trail)
            }
        }
        for trail in shortestTrails {
            print("Getting shortest paths between vertices.")
            for edge in trail {
                print("Edge\(vertices[edge.startVertexID]!.label)\(vertices[edge.endVertexID]!.label)")
            }
        }
        return shortestTrails
    }
    
    func walkWeight(_ edges: [Edge]) -> Double? {
        guard !edges.isEmpty else { return nil }
        var weight = 0.0
        for edge in edges {
            weight += edge.weight
        }
        return weight
    }
    
    func getVertexByID(_ id: UUID) -> Vertex? {
        return vertices[id]
    }
    
    func getEdgeByID(_ id: UUID) -> Edge? {
        edges[id]
    }
    
    func getOffsetByID(_ id: UUID) -> CGSize? {
        return getVertexByID(id)?.offset
    }
    
    func getEdgeWeightOffsetByID(_ id: UUID) -> CGSize? {
        if let edge = edges[id] {
            return edge.weightPositionOffset
        }
        return nil
    }
    
    mutating func setEdgeWeightOffsetByID(id: UUID, offset: CGSize) {
        edges[id]?.weightPositionOffset = offset
    }
    
    mutating func setVertexPosition(forID id: UUID, position: CGPoint) {
        if var vertex = vertices[id] {
            vertex.position = position
            vertices[id] = vertex
        }
    }
    
    mutating func setVertexOffset(forID id: UUID, size: CGSize) {
        if var vertex = vertices[id] {
            vertex.offset = size
            vertices[id] = vertex
        }
    }
    
    mutating func setVertexColor(forID id: UUID, color: Color?) {
        vertices[id]?.color = color
    }
    
    mutating func setEdgeColor(edgeID: UUID, color: Color) {
        edges[edgeID]?.color = color
    }
    
    // Return true if the graph contains an edge connecting v1 and v2.
    func doesEdgeExist(_ v1ID: UUID, _ v2ID: UUID) -> Bool {
        for edge in edges.values {
            if (edge.startVertexID == v1ID && edge.endVertexID == v2ID) ||
                (edge.startVertexID == v2ID && edge.endVertexID == v1ID) {
                return true
            }
        }
        return false
    }
    
    // Returns true if there is a path from vertex1ID to vertex2ID
    // following the edges of the graph.
    func areVerticesConnected(_ vertex1ID: UUID, _ vertex2ID: UUID) -> Bool {
        let connectedEdges = getConnectedEdges(to: vertex1ID)
        // If there are no edges connected to vertex1ID, then return false.
        guard connectedEdges.count > 0 else { return false }
        // Return true if there is a single edge connecting vertex1ID and vertex2ID
        for connectedEdge in connectedEdges {
            if connectedEdge.traverse(from: vertex1ID) == vertex2ID { return true }
        }
        
        // Traverse each edge, and see if we can connect to vertex2ID.
        for edge in connectedEdges {
            if let nextVertex = edge.traverse(from: vertex1ID) {
                var remainingEdges = edges
                remainingEdges.removeValue(forKey: edge.id)
                var subGraph = Graph()
                subGraph.vertices = vertices
                subGraph.edges = remainingEdges
                if subGraph.areVerticesConnected(nextVertex, vertex2ID) {
                    return true
                }
            }
        }
        return false
    }
    
    // Returns true if there is a single edge connecting
    // the two vertices.
    func areVerticesAdjacent(_ vertex1ID: UUID, _ vertex2ID: UUID) -> Bool {
        let connectedEdges = getConnectedEdges(to: vertex1ID)
        for edge in connectedEdges {
            if let adjacentVertex = edge.traverse(from: vertex1ID) {
                if adjacentVertex == vertex2ID {
                    return true
                }
            }
        }
        return false
    }
    
    func areEdgesAdjacent(_ edge1ID: UUID, edge2ID: UUID) -> Bool {
        return edges[edge1ID]?.startVertexID == edges[edge2ID]?.startVertexID ||
        edges[edge1ID]?.startVertexID == edges[edge2ID]?.endVertexID ||
        edges[edge1ID]?.endVertexID == edges[edge2ID]?.startVertexID ||
        edges[edge1ID]?.endVertexID == edges[edge2ID]?.endVertexID
    }
    
    func isConnected() -> Bool {
        if let permutations = Permutation.permute(Array(vertices.values), r: 2) {
            for permutation in permutations {
                if !areVerticesConnected(permutation[0].id, permutation[1].id) {
                    return false
                }
            }
        }
        return true
    }
    
    func isCycle() -> Bool {
        // In a cycle, every vertex should appear on exactly 2 edges.
        for vertex in Array(vertices.values) {
            guard getConnectedEdges(to: vertex.id).count == 2 else { return false }
        }
        // Choose a starting vertex. Any random vertex will do.
        let startVertex = vertices.randomElement()!.value
        // Get all edges connected to this vertex.
        let connectedEdges = getConnectedEdges(to: startVertex.id)
        // In a cycle, there should be exactly 2 connected edges.
        guard connectedEdges.count == 2 else { return false }
        // Choose one of the 2 edges to travel along.
        let firstEdge = connectedEdges[0]
        // Get the ID of the connecting vertex.
        let secondVertexID = firstEdge.traverse(from: startVertex.id)!
        // Construct a subgraph consisting of all the same vertices,
        // and all the same edges, minus firstEdge.
        var remainingEdges = edges
        remainingEdges.removeValue(forKey: firstEdge.id)
        let subGraph = Graph(vertices: Array(vertices.values), edges: Array(remainingEdges.values))
        // If the graph is a cycle
        return subGraph.areVerticesConnected(startVertex.id, secondVertexID)
    }
    
    func isHamiltonianCycle() -> Bool {
        // Check if the graph is a cycle and includes all vertices (Hamiltonian condition)
        return isCycle() && vertices.count == edges.count
    }
    
    func isHamiltonion() -> Bool {
        guard vertices.count > 0 else { return false }
        let cycles = getAllTrailsBetween(vertices.first!.value, vertices.first!.value)
        for cycle in cycles {
            let newGraph = Graph(vertices: Array(vertices.values), edges: cycle)
            if newGraph.isHamiltonianCycle() {
                return true
            }
        }
        return false
    }
    
    func hasCycle() -> Bool {
        for vertexID in vertices.keys {
            var newVertices: [UUID] = []
            newVertices.append(vertexID)
            for edge in getConnectedEdges(to: vertexID) {
                if let nextVertexID = edge.traverse(from: vertexID){
                    var newEdges = edges
                    newEdges.removeValue(forKey: edge.id)
                    let subGraph = Graph(vertices: Array(vertices.values), edges: Array(newEdges.values))
                    if subGraph.areVerticesConnected(vertexID, nextVertexID) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isEulerian(subGraph: Graph = Graph()) -> Bool {
        for vertex in Array(vertices.values) {
            let connectedEdges = getConnectedEdges(to: vertex.id)
            for edge in connectedEdges {
                if !subGraph.edges.values.contains(where: { $0.id == edge.id }) {
                    var newEdges = Array(subGraph.edges.values)
                    newEdges.append(edge)
                    let newSubGraph = Graph(vertices: Array(vertices.values), edges: newEdges)
                    if isEulerian(subGraph: newSubGraph) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // Determines if the graph has the Euclidean property:
    // the direct edge between any two vertices is the shortest distance.
    func isEuclidean() -> Bool {
        for edge in Array(edges.values) {
            let startVertexID = edge.startVertexID
            let startVertex = vertices[startVertexID]!
            let endVertexID = edge.endVertexID
            let endVertex = vertices[endVertexID]!
            let shortestTrails = shortestTrails(from: startVertex, to: endVertex)
            var shortestTrailWeight = 0.0
            for edge in shortestTrails[0] {
                shortestTrailWeight += edge.weight
            }
            if edge.weight > shortestTrailWeight {
                return false
            }
        }
        return true
    }
    
    func isComplete() -> Bool {
        for vertex in vertices.values {
            var otherVertices = Array(vertices.values)
            otherVertices.removeAll(where: { $0.id == vertex.id})
            for otherVertex in otherVertices {
                if !doesEdgeExist(vertex.id, otherVertex.id) {
                    return false
                }
            }
        }
        return true
    }
    
    func getEdgesBetween(_ vertex1ID: UUID, _ vertex2ID: UUID) -> [Edge] {
        var result: [Edge] = []
        if doesEdgeExist(vertex1ID, vertex2ID) {
            let connectedEdges = getConnectedEdges(to: vertex1ID)
            for edge in connectedEdges {
                if edge.startVertexID == vertex2ID || edge.endVertexID == vertex2ID {
                    result.append(edge)
                }
            }
        }
        return result
    }
    
    // Return an array of edges that are connect to vertex v
    func getConnectedEdges(to v: UUID) -> [Edge] {
        var connectedEdges: [Edge] = []
        for edge in edges.values {
            if edge.startVertexID == v || edge.endVertexID == v {
                connectedEdges.append(edge)
            }
        }
        return connectedEdges
    }
    
    func getEdgeControlPoints(for edge: Edge) -> (CGPoint, CGPoint) {
        let controlPoint1 = edges[edge.id]!.controlPoint1
        let controlPoint2 = edges[edge.id]!.controlPoint2
        return (controlPoint1, controlPoint2)
    }
    
    func getEdgeControlPointOffsets(for edge: Edge) -> (CGSize, CGSize) {
        let controlPoint1Offset = edges[edge.id]!.controlPoint1Offset
        let controlPoint2Offset = edges[edge.id]!.controlPoint2Offset
        return (controlPoint1Offset, controlPoint2Offset)
    }
    
    mutating func setControlPoints(for edge: Edge) {
        let controlPoint1 = calculateControlPoint(for: edge, distance: 0.3)
        let controlPoint2 = calculateControlPoint(for: edge, distance: 0.7)
        edges[edge.id]?.controlPoint1 = controlPoint1
        edges[edge.id]?.controlPoint2 = controlPoint2
    }
    
    mutating func setControlPoint1(for edge: Edge, at point: CGPoint) {
        edges[edge.id]?.controlPoint1 = point
    }
    
    mutating func setControlPoint2(for edge: Edge, at point: CGPoint) {
        edges[edge.id]?.controlPoint2 = point
    }
    
    mutating func setControlPoint1Offset(for edge: Edge, translation: CGSize) {
        edges[edge.id]?.controlPoint1Offset = translation
    }
    
    mutating func setControlPoint2Offset(for edge: Edge, translation: CGSize) {
        edges[edge.id]?.controlPoint2Offset = translation
    }
    
    func calculateControlPoint(for edge: Edge, distance: CGFloat) -> CGPoint {
        let startPoint = getVertexByID(edge.startVertexID)!.position
        let endPoint = getVertexByID(edge.endVertexID)!.position
        
        // If the edge is not a vertical line, calculate the control point.
        if let yIntercept = yIntercept(of: edge), let gradient = gradient(of: edge) {
            let newX = startPoint.x + distance * (endPoint.x - startPoint.x)
            let newY = gradient * newX + yIntercept
            return CGPoint(x: newX, y: newY)
        }
        // If the edge is a vertical line, calculate the control point.
        let newX = startPoint.x
        let newY = startPoint.y + distance * (endPoint.y - startPoint.y)
        return CGPoint(x: newX, y: newY)
    }
    
    mutating func updateControlPoint1(for edge: Edge, translation: CGSize) {
        if let originalControlPoint1 = edges[edge.id]?.controlPoint1 {
            edges[edge.id]?.controlPoint1 = CGPoint(x: originalControlPoint1.x + translation.width,
                                                    y: originalControlPoint1.y + translation.height)
        }
    }
    
    mutating func updateControlPoint2(for edge: Edge, translation: CGSize) {
        if let originalControlPoint2 = edges[edge.id]?.controlPoint2 {
            edges[edge.id]?.controlPoint2 = CGPoint(x: originalControlPoint2.x + translation.width,
                                                    y: originalControlPoint2.y + translation.height)
        }
    }
    
    func yIntercept(of edge: Edge) -> CGFloat? {
        let startPoint = getVertexByID(edge.startVertexID)?.position
        let y = startPoint!.y
        let x = startPoint!.x
        if let m = gradient(of: edge) {
            return y - m * x
        }
        return nil
    }
    
    func gradient(of edge: Edge) -> CGFloat? {
        let endVertex = getVertexByID(edge.endVertexID)
        let startVertex = getVertexByID(edge.startVertexID)
        let y2 = endVertex!.position.y
        let y1 = startVertex!.position.y
        let x2 = endVertex!.position.x
        let x1 = startVertex!.position.x
        let dy = y2 - y1
        let dx = x2 - x1
        
        if dx == 0 { return nil }
        
        return dy / dx
    }
    
    mutating func resetControlPointsAndOffsets(for edge: Edge) {
        setControlPoints(for: edge)
        setControlPoint1Offset(for: edge, translation: .zero)
        setControlPoint2Offset(for: edge, translation: .zero)
    }
}

class GraphViewModel: ObservableObject {
    @Published private(set) var graph: Graph
    @Published var timesEdgeSelected: [UUID: Int]
    @Published var showWeights: Bool
    @Published var selectedVertex: Vertex?
    @Published var selectedEdge: Edge?
    var movingVertex: Vertex?
    // A copy of the edges before any changes occur
    var edgesWillMove: [Edge] = []
    // A copy of the edges after changes occur
    var edgesDidMove: [Edge] = []
    var vertexWillMove: [UUID: Vertex] = [:]
    var vertexDidMove: [UUID: Vertex] = [:]
    var showModeMenu: Bool
    var showAlgorithms: Bool
    
    init(graph: Graph, showWeights: Bool = false, showModeMenu: Bool = true, showAlgorithms: Bool = false) {
        self.graph = graph
        self.showWeights = showWeights
        self.showModeMenu = showModeMenu
        self.showAlgorithms = showAlgorithms
        timesEdgeSelected = [:]
        for id in graph.edges.keys {
            timesEdgeSelected[id] = 0
        }
    }
    
    func addVertex(_ vertex: Vertex) {
        graph.addVertex(vertex)
    }
    
    func removeVertex(_ vertex: Vertex) {
        graph.removeVertex(vertex)
    }
    
    func getVertices() -> [Vertex] {
        return Array(graph.vertices.values)
    }
    
    func addEdge(_ edge: Edge) {
        graph.addEdge(edge)
        timesEdgeSelected[edge.id] = 0
    }
    
    func removeEdge(_ edge: Edge) {
        graph.removeEdge(edge)
    }
    
    func removeEdgesConnected(to vertexID: UUID) {
        graph.removeEdgesConnected(to: vertexID)
    }
    
    func getEdges() -> [Edge] {
        return Array(graph.edges.values)
    }
    
    func getConnectedEdges(to v: UUID) -> [Edge] {
        return graph.getConnectedEdges(to: v)
    }
    
    func setColorForEdge(edge: Edge, color: Color) {
        graph.edges[edge.id]?.color = color
    }
    
    func setEdgeStrokeStyle(edge: Edge, strokeStyle: Edge.StrokeStyle) {
        graph.edges[edge.id]?.strokeStyle = strokeStyle
    }
    
    func setVertexOpacity(vertex: Vertex, opacity: Double) {
        graph.vertices[vertex.id]?.opacity = max(0, min(1, opacity))
    }
    
    func getEdgeDirection(_ edge: Edge) -> Edge.Directed {
        graph.edges[edge.id]?.directed ?? .none
    }
    
    func setEdgeDirection(edge: Edge, direction: Edge.Directed) {
        graph.edges[edge.id]?.directed = direction
    }
    
    func getEdgeForwardArrowParameter(edge: Edge) -> CGFloat? {
        graph.edges[edge.id]?.forwardArrowParameter
    }
    
    func getEdgeReverseArrowParameter(edge: Edge) -> CGFloat? {
        graph.edges[edge.id]?.reverseArrowParameter
    }
    
    func setEdgeForwardArrowParameter(id: UUID, parameter: CGFloat) {
        graph.edges[id]?.forwardArrowParameter = parameter
    }
    
    func setEdgeReverseArrowParameter(id: UUID, parameter: CGFloat) {
        graph.edges[id]?.reverseArrowParameter = parameter
    }
    
    func setEdgeWeightPositionParameterT(id: UUID, t: CGFloat) {
        graph.edges[id]?.weightPositionParameterT = t
    }
    
    func setEdgeWeightPositionDistance(id: UUID, distance: CGFloat) {
        graph.edges[id]?.weightPositionDistance = distance
    }
    
    // Used for storing an initial copy of a vertex before
    // changes occur.
    func vertexWillMove(_ vertex: Vertex, size: CGSize) {
        if !vertexWillMove.keys.contains(where: { $0 == vertex.id }) {
            vertexWillMove[vertex.id] = vertex
            let connectedEdges = getConnectedEdges(to: vertex.id)
            for edge in connectedEdges {
                // Used for storing an initial copy of an edge before
                // changes occur.
                if !edgesWillMove.contains(where: {$0.id == edge.id}) {
                    edgesWillMove.append(edge)
                }
                // Calculate the relative positions of the weights
                if let startVertex = graph.getVertexByID(edge.startVertexID), let endVertex = graph.getVertexByID(edge.endVertexID) {
                    let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: .zero, endOffset: .zero, controlPoint1: getControlPoints(for: edge).0, controlPoint2: getControlPoints(for: edge).1, controlPoint1Offset: getControlPointOffsets(for: edge).0, controlPoint2Offset: getControlPointOffsets(for: edge).1, size: size)
                    let edgeViewModel = EdgeViewModel(edge: edge, size: size, graphViewModel: self)
                    let weightPosition = edgeViewModel.weightPosition
                    let (t, distance) = edgePath.closestParameterAndDistance(externalPoint: weightPosition)
                    if let index = edgesWillMove.firstIndex(where: {$0.id == edge.id}) {
                        edgesWillMove[index].weightPositionParameterT = t
                        edgesWillMove[index].weightPositionDistance = distance
                    }
                    graph.edges[edge.id]?.weightPositionParameterT = t
                    graph.edges[edge.id]?.weightPositionDistance = distance
                }
            }
        }
    }
    
    // Used for storing copies of a vertex after a change occurs.
    func vertexDidMove(_ vertex: Vertex) {
        vertexWillMove[vertex.id] = vertex
        let connectedEdges = getConnectedEdges(to: vertex.id)
        for edge in connectedEdges {
            edgesDidMove.removeAll { $0.id == edge.id }
            edgesDidMove.append(edge)
        }
    }
    
    // After a vertex and edge change occurs, refresh the four arrays
    // storing the vertices and edges.
    func resetVertexEdgeChanges() {
        edgesWillMove = []
        edgesDidMove = []
        vertexWillMove = [:]
        vertexDidMove = [:]
    }
    
    // Returns a tuple containing the relative control point positions
    // of an edge before changes occured.
    // The relative control point position is a point
    // that represents how far between startVertex.position and
    // endVertex.position a control point is located.
    func getEdgeOriginalRelativeControlPoints(_ edge: Edge) -> (CGPoint, CGPoint)? {
        let startVertexID = edge.startVertexID
        let endVertexID = edge.endVertexID
        if let startVertexPosition = vertexWillMove[startVertexID]?.position,
           let endVertexPosition = vertexWillMove[endVertexID]?.position {
            let (controlPoint1, controlPoint2) = getControlPoints(for: edge)
            let x1 = (controlPoint1.x - startVertexPosition.x) / (endVertexPosition.x - startVertexPosition.x)
            let y1 = (controlPoint1.y - startVertexPosition.y) / (endVertexPosition.y - startVertexPosition.y)
            let relativePosition1 = CGPoint(x: x1, y: y1)
            let x2 = (controlPoint2.x - startVertexPosition.x) / (endVertexPosition.x - startVertexPosition.x)
            let y2 = (controlPoint2.y - startVertexPosition.y) / (endVertexPosition.y - startVertexPosition.y)
            let relativePosition2 = CGPoint(x: x2, y: y2)
            return (relativePosition1, relativePosition2)
        }
        return nil
    }
    
    // Set the positions of the control points of an edge
    // after a move has occurred, based on the original
    // relative positions of the control points.
    func setEdgeRelativeControlPoints(edge: Edge, geometrySize: CGSize) {
        let (originalControlPoint1, originalControlPoint2) = getControlPoints(for: edge)
        let (controlPoint1Offset, controlPoint2Offset) = getControlPointOffsets(for: edge)
        let x1 = originalControlPoint1.x + controlPoint1Offset.width / geometrySize.width
        let y1 = originalControlPoint1.y + controlPoint1Offset.height / geometrySize.height
        let x2 = originalControlPoint2.x + controlPoint2Offset.width / geometrySize.width
        let y2 = originalControlPoint2.y + controlPoint2Offset.height / geometrySize.height
        setControlPoint1(for: edge, at: CGPoint(x: x1, y: y1))
        setControlPoint2(for: edge, at: CGPoint(x: x2, y: y2))
    }
    
    // When a vertex starts being dragged by translation,
    // update the offsets for the control points of the edge.
    func setEdgeControlPointOffsets(edge: Edge, translation: CGSize, geometrySize: CGSize) {
        if let (relativeControlPoint1, relativeControlPoint2) = getEdgeOriginalRelativeControlPoints(edge), let movingVertex = movingVertex {
            var dx1 = CGFloat.zero
            var dy1 = CGFloat.zero
            var dx2 = CGFloat.zero
            var dy2 = CGFloat.zero
            if relativeControlPoint1.x > 0 {
                if translation.width >= 0 {
                    dx1 = min(relativeControlPoint1.x * translation.width, translation.width)
                } else {
                    dx1 = max(relativeControlPoint1.x * translation.width, translation.width)
                }
            } else if relativeControlPoint1.x < 0 {
                if translation.width >= 0 {
                    dx1 = max(relativeControlPoint1.x * translation.width, -translation.width)
                } else {
                    dx1 = min(relativeControlPoint1.x * translation.width, -translation.width)
                }
            } else { // if relativeControlPoint1.x == 0
                dx1 = 0.3 * translation.width
            }
            
            if relativeControlPoint2.x > 0 {
                if translation.width >= 0 {
                    dx2 = min(relativeControlPoint2.x * translation.width, translation.width)
                } else {
                    dx2 = max(relativeControlPoint2.x * translation.width, translation.width)
                }
            } else if relativeControlPoint2.x < 0{
                if translation.width >= 0 {
                    dx2 = max(relativeControlPoint2.x * translation.width, -translation.width)
                } else {
                    dx2 = min(relativeControlPoint2.x * translation.width, -translation.width)
                }
            } else {
                dx2 = 0.7 * translation.width
            }
            
            if relativeControlPoint1.y > 0 {
                if translation.height > 0 {
                    dy1 = min(relativeControlPoint1.y * translation.height, translation.height)
                } else {
                    dy1 = max(relativeControlPoint1.y * translation.height, translation.height)
                }
            } else if relativeControlPoint1.y < 0{
                if translation.height >= 0 {
                    dy1 = max(relativeControlPoint1.y * translation.height, -translation.height)
                } else {
                    dy1 = min(relativeControlPoint1.y * translation.height, -translation.height)
                }
            } else {
                dy1 = 0.3 * translation.height
            }
            
            if relativeControlPoint2.y > 0 {
                if translation.height >= 0 {
                    dy2 = min(relativeControlPoint2.y * translation.height, translation.height)
                } else {
                    dy2 = max(relativeControlPoint2.y * translation.height, translation.height)
                }
            } else if relativeControlPoint2.y < 0 {
                if translation.height >= 0 {
                    dy2 = max(relativeControlPoint2.y * translation.height, -translation.height)
                } else {
                    dy2 = min(relativeControlPoint2.y * translation.height, -translation.height)
                }
            } else {
                dy2 = 0.7 * translation.height
            }
            
            if movingVertex.id == edge.endVertexID {
                setControlPoint1Offset(for: edge, translation: CGSize(width: dx1, height: dy1))
                setControlPoint2Offset(for: edge, translation: CGSize(width: dx2, height: dy2))
            } else {
                setControlPoint1Offset(for: edge, translation: CGSize(width: dx2, height: dy2))
                setControlPoint2Offset(for: edge, translation: CGSize(width: dx1, height: dy1))
            }
        }
    }
    
    func getGraph() -> Graph {
        return graph
    }
    
    func setGraph(graph: Graph) {
        self.graph = graph
    }
    
    func getVertexByID(_ id: UUID) -> Vertex? {
        return graph.getVertexByID(id)
    }
    
    func getEdge(_ edge: Edge) -> Edge? {
        return graph.getEdgeByID(edge.id)
    }
    
    func setVertexLabel(id: UUID, label: String) {
        graph.vertices[id]?.label = label
    }
    
    func setVertexLabelColor(id: UUID, labelColor: Vertex.LabelColor) {
        graph.vertices[id]?.labelColor = labelColor
    }
    
    func setVertexPosition(vertex: Vertex, position: CGPoint) {
        graph.setVertexPosition(forID: vertex.id, position: position)
        objectWillChange.send()
    }
    
    func setVertexOffset(vertex: Vertex, size: CGSize) {
        graph.setVertexOffset(forID: vertex.id, size: size)
    }
    
    func setColor(vertex: Vertex, color: Color?) {
        graph.setVertexColor(forID: vertex.id, color: color)
    }
    
    func setGraph(_ newGraph: Graph) {
        self.graph = newGraph
        objectWillChange.send() // Notify the view of changes
    }
    
    func setControlPoints(for edge: Edge) {
        graph.setControlPoints(for: edge)
        graph.setControlPoint1Offset(for: edge, translation: .zero)
        graph.setControlPoint2Offset(for: edge, translation: .zero)
    }
    
    func setControlPoint1(for edge: Edge, at point: CGPoint) {
        graph.setControlPoint1(for: edge, at: point)
    }
    
    func setControlPoint2(for edge: Edge, at point: CGPoint) {
        graph.setControlPoint2(for: edge, at: point)
    }
    
    func getWeight(edge: Edge) -> Double? {
        graph.edges[edge.id]?.weight
    }
    
    func setWeight(edge: Edge, weight: Double) {
        graph.edges[edge.id]?.weight = weight
    }
    
    func getWeightPositionOffset(for edge: Edge) -> CGSize? {
        return graph.getEdgeWeightOffsetByID(edge.id)
    }
    
    func setWeightPosition(for edge: Edge, position: CGPoint, size: CGSize) {
        let edgeViewModel = EdgeViewModel(edge: edge, size: size, graphViewModel: self)
        let (t, distance) = edgeViewModel.edgePath.closestParameterAndDistance(externalPoint: position)
        graph.edges[edge.id]?.weightPositionParameterT = t
        graph.edges[edge.id]?.weightPositionDistance = distance
    }
        
    func setWeightPositionOffset(for edge: Edge, offset: CGSize) {
        graph.setEdgeWeightOffsetByID(id: edge.id, offset: offset)
    }
    
    func updateControlPoint1(for edge: Edge, translation: CGSize) {
        graph.updateControlPoint1(for: edge, translation: translation)
    }
    
    func updateControlPoint2(for edge: Edge, translation: CGSize) {
        graph.updateControlPoint2(for: edge, translation: translation)
    }
    
    func getControlPoints(for edge: Edge) -> (CGPoint, CGPoint) {
        let controlPoint1 = graph.edges[edge.id]?.controlPoint1 ?? CGPoint.zero
        let controlPoint2 = graph.edges[edge.id]?.controlPoint2 ?? CGPoint.zero
        return (controlPoint1, controlPoint2)
    }
    
    func getControlPointOffsets(for edge: Edge) -> (CGSize, CGSize) {
        if let controlPoint1Offset = graph.edges[edge.id]?.controlPoint1Offset,
           let controlPoint2Offset = graph.edges[edge.id]?.controlPoint2Offset {
            return (controlPoint1Offset, controlPoint2Offset)
        } else {
            return (CGSize.zero, CGSize.zero)
        }
    }
    
    func setControlPoint1Offset(for edge: Edge, translation: CGSize) {
        graph.edges[edge.id]?.controlPoint1Offset = translation
    }
    
    func setControlPoint2Offset(for edge: Edge, translation: CGSize) {
        graph.edges[edge.id]?.controlPoint2Offset = translation
    }
    
    func getMode() -> Graph.Mode {
        graph.mode
    }
    
    func setMode(_ mode: Graph.Mode) {
        graph.mode = mode
    }
    
    func getAlgorithm() -> Graph.Algorithm {
        graph.algorithm
    }
    
    func setAlgorithm(_ alg: Graph.Algorithm) {
        graph.algorithm = alg
    }
    
    func resetControlPointsAndOffsets(for edge: Edge) {
        graph.resetControlPointsAndOffsets(for: edge)
    }
    
    func clear() {
        graph.clear()
    }
    
}

struct GraphView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var vertexEdgeColor: Color = .white
    @State private var edgeDirection = Edge.Directed.none
    
    init(graphViewModel: GraphViewModel) {
        self.graphViewModel = graphViewModel
    }
    
    let edgeColors: [Color] = [Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.9, green: 0, blue: 0.9, alpha: 1))]
    
    func clear() {
        graphViewModel.clear()
    }
    
    func convertToColor(from cgColor: CGColor) -> Color {
#if os(macOS)
        if let nsColor = NSColor(cgColor: cgColor) {
            return Color(nsColor)
        }
        return Color.clear // Fallback for invalid `CGColor`
#elseif os(iOS)
        return Color(UIColor(cgColor: cgColor))
#endif
    }
    
    func handleVertexOnDragGesture(for vertex: Vertex, drag: DragGesture.Value, geometrySize: CGSize) {
        
    }
    
    func handleVertexEndDragGesture(for vertex: Vertex, drag: DragGesture.Value, geometrySize: CGSize) {
        
    }
    
    func handleVertexSingleClickGesture(for vertex: Vertex) {
        
    }
    
    func handleVertexDoubleClickGesture(for vertex: Vertex) {
        
    }
    
    func handleEdgeSingleClickGesture(for edge: Edge) {
        graphViewModel.selectedVertex = nil
        switch graphViewModel.getMode() {
            // Allows the user to select an edge to display the control points
        case .edit:
            if graphViewModel.selectedEdge?.id != edge.id {
                graphViewModel.selectedEdge = edge
                edgeDirection = graphViewModel.selectedEdge!.directed
                
            } else {
                graphViewModel.selectedEdge = nil
            }
            // Change the colors of the edges to simulate a path through the graph
        case .explore:
            graphViewModel.timesEdgeSelected[edge.id]! += 1
            let timesSelected = graphViewModel.timesEdgeSelected[edge.id]!
            graphViewModel.setColorForEdge(edge: edge, color: edgeColors[(timesSelected - 1) % edgeColors.count])
        case .icosian:
            graphViewModel.selectedEdge = edge
        case .algorithm:
            break
        }
    }
    
    func handleEdgeDoubleClickGesture(for edge: Edge) {
        if graphViewModel.getMode() == .edit {
            graphViewModel.selectedEdge = nil
        }
    }
    
    func handleEdgeLongPressGesture(for edge: Edge) {
        if graphViewModel.getMode() == .edit {
            graphViewModel.resetControlPointsAndOffsets(for: edge)
        } else if graphViewModel.getMode() == .explore {
            graphViewModel.timesEdgeSelected[edge.id] = 0
            graphViewModel.setColorForEdge(edge: edge, color: .white)
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                EdgeView(edgeViewModel: edgeViewModel)
                    .onTapGesture(count: 2) {
                        handleEdgeDoubleClickGesture(for: edge)
                    }
                    .onTapGesture(count: 1) {
                        handleEdgeSingleClickGesture(for: edge)
                    }
                    .onLongPressGesture {
                        handleEdgeLongPressGesture(for: edge)
                    }
            }
            
            // The vertices
            ForEach(graphViewModel.getVertices()) { vertex in
                let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                
                VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                    .shadow(color: vertexViewModel.getVertexID() == graphViewModel.selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                    .onAppear {
                        if vertexViewModel.color == nil {
                            vertexViewModel.setColor(vertexID: vertex.id, color: vertexEdgeColor)
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            if graphViewModel.getMode() == .edit {
                                graphViewModel.movingVertex = vertex
                                vertexViewModel.setOffset(size: drag.translation)
                                // Notify the model to store copies of
                                // the vertex and connected edges in
                                // their original states.
                                graphViewModel.vertexWillMove(vertex, size: geometry.size)
                                //Update the control points and control point offsets for every edge connected to a moving vertex
                                let connectedEdges = graphViewModel.getConnectedEdges(to: vertex.id)
                                for edge in connectedEdges {
                                    // Keep original copies of all
                                    // vertices connected by edge.
                                    let otherVertexID = edge.traverse(from: vertex.id)!
                                    let otherVertex = graphViewModel.getVertexByID(otherVertexID)!
                                    graphViewModel.vertexWillMove(otherVertex, size: geometry.size)
                                    // Update the control point
                                    // offsets for edge
                                    graphViewModel.setEdgeControlPointOffsets(edge: edge, translation: drag.translation, geometrySize: geometry.size)
                                }
                            }
                        }).onEnded { _ in
                            if graphViewModel.getMode() == .edit {
                                graphViewModel.movingVertex = nil
                                graphViewModel.vertexDidMove(vertex)
                                // Set the vertex position
                                vertexViewModel.setPosition(CGPoint(x: vertexViewModel.getPosition()!.x + vertexViewModel.getOffset()!.width / geometry.size.width, y: vertexViewModel.getPosition()!.y + vertexViewModel.getOffset()!.height / geometry.size.height))
                                vertexViewModel.setOffset(size: .zero)
                                
                                for edge in graphViewModel.getConnectedEdges(to: vertex.id) {
                                    //Update the control points and control point offsets for every edge connected to a moving vertex
                                    graphViewModel.setEdgeRelativeControlPoints(edge: edge, geometrySize: geometry.size)
                                    graphViewModel.setControlPoint1Offset(for: edge, translation: .zero)
                                    graphViewModel.setControlPoint2Offset(for: edge, translation: .zero)
                                    // Reposition the weight
                                    if let t = graphViewModel.getEdges().first(where: {$0.id == edge.id})?.weightPositionParameterT, let distance = graphViewModel.getEdges().first(where: {$0.id == edge.id})?.weightPositionDistance, let startVertex = graphViewModel.getVertexByID(edge.startVertexID), let endVertex = graphViewModel.getVertexByID(edge.endVertexID) {
                                        let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: startVertex.offset, endOffset: endVertex.offset, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1, size: geometry.size)
                                        let pointOnBezierCurve = edgePath.pointOnBezierCurve(t: t)
                                        var newWeightPosition: CGPoint
                                        if let bezierGradient = edgePath.bezierTangentGradient(t: t) {
                                            if bezierGradient != 0 {
                                                newWeightPosition = edgePath.pointOnPerpendicular(point: pointOnBezierCurve, perpendicularGradient: 1 / bezierGradient, distance: distance).0
                                            } else {
                                                newWeightPosition = CGPoint(x: pointOnBezierCurve.x, y: pointOnBezierCurve.y + distance)
                                            }
                                        } else {
                                            let y = pointOnBezierCurve.y
                                            let x = pointOnBezierCurve.x + distance
                                            newWeightPosition = CGPoint(x: x, y: y)
                                        }
                                        graphViewModel.setWeightPosition(for: edge, position: newWeightPosition, size: geometry.size)
                                        
                                    }
                                    graphViewModel.resetVertexEdgeChanges()
                                    
                                }
                            }
                        })
                    .onTapGesture(count: 2) {
                        if graphViewModel.getMode() == .edit {
                            if graphViewModel.getConnectedEdges(to: vertex.id).contains(where: { $0.id == graphViewModel.selectedEdge?.id }) {
                                graphViewModel.selectedEdge = nil
                            }
                            graphViewModel.removeEdgesConnected(to: vertexViewModel.getVertexID())
                            graphViewModel.removeVertex(vertex)
                            
                            graphViewModel.selectedVertex = nil
                        }
                    }
                    .onTapGesture(count: 1) {
                        if graphViewModel.getMode() == .edit || graphViewModel.getMode() == .explore {
                            graphViewModel.selectedEdge = nil
                            if graphViewModel.selectedVertex == nil {
                                graphViewModel.selectedVertex = graphViewModel.getVertexByID(vertexViewModel.getVertexID())
                            } else if graphViewModel.selectedVertex!.id == vertexViewModel.getVertexID() {
                                graphViewModel.selectedVertex = nil
                            } else if graphViewModel.getMode() == .edit {
                                let newEdge = Edge(startVertexID: graphViewModel.selectedVertex!.id, endVertexID: vertexViewModel.getVertexID())
                                graphViewModel.addEdge(newEdge)
                                graphViewModel.setEdgeDirection(edge: newEdge, direction: edgeDirection)
                                graphViewModel.selectedVertex = nil
                            } else {
                                graphViewModel.selectedVertex = nil
                            }
                        }
                    }
            }
        }
        .onAppear {
            vertexEdgeColor = colorScheme == .light ? .black : .white
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ColorPicker(
                    "",
                    selection: Binding(
                        get: {
                            if let selectedEdge = graphViewModel.selectedEdge {
                                return selectedEdge.color
                            } else if let selectedVertexColor = graphViewModel.selectedVertex?.color {
                                return selectedVertexColor
                            } else {
                                return vertexEdgeColor
                            }
                        },
                        set: { newColor in
                            if let selectedEdge = graphViewModel.selectedEdge {
                                graphViewModel.setColorForEdge(edge: selectedEdge, color: newColor)
                                graphViewModel.selectedEdge =  graphViewModel.getGraph().edges[selectedEdge.id]
                            } else if let selectedVertex = graphViewModel.selectedVertex {
                                graphViewModel.setColor(vertex: selectedVertex, color: newColor)
                                graphViewModel.selectedVertex = graphViewModel.getVertexByID(selectedVertex.id) // Sync selected vertex
                            } else {
                                vertexEdgeColor = newColor
                            }
                        }
                    )
                )
                .labelsHidden()
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    graphViewModel.selectedVertex = nil
                    graphViewModel.selectedEdge = nil
                    vertexEdgeColor = colorScheme == .light ? .black : .white
                    clear()
                }) {
                    Image(systemName: "arrow.uturn.left.circle")
                        .tint(themeViewModel.theme!.accentColor)
                }
            }
            ToolbarItem(placement: .automatic) {
                Menu {
                    Text("Algorithm:")
                    NavigationLink(destination: KruskalView(kruskalViewModel: KruskalViewModel(graph: graphViewModel.getGraph()), completion: .constant(false))) {
                        Text("Kruskal")
                    }
                    NavigationLink(destination: PrimView(graph: graphViewModel.getGraph())) {
                        Text("Prim")
                    }
                    NavigationLink(destination: ChinesePostmanView(graph: graphViewModel.getGraph())) {
                        Text("Chinese Postman Problem")
                    }
                    NavigationLink(destination: ClassicalTSPView(classicalTSPViewModel: ClassicalTSPViewModel(graph: graphViewModel.graph))) {
                        Text("Classical TSP")
                    }
                    NavigationLink(destination: PracticalTSPView(practicalTSPViewModel: PracticalTSPViewModel(graph: graphViewModel.graph), graphViewModel: graphViewModel)) {
                        Text("Practical TSP")
                    }
                } label: {
                    Image(systemName: "flask")
                        .tint(themeViewModel.theme!.accentColor)
                }
            }
            ToolbarItem(placement: .automatic) {
                if graphViewModel.getAlgorithm() == .none {
                    Menu {
                        Toggle(isOn: $graphViewModel.showWeights) {
                            Label("Weights", systemImage: "number.square").tint(themeViewModel.theme!.accentColor)
                        }
                        Picker("Direction", systemImage: "arrow.left.and.right", selection: Binding(get: {
                            if let selectedEdge = graphViewModel.selectedEdge {
                                return graphViewModel.getEdgeDirection(selectedEdge)
                            } else {
                                return edgeDirection
                            }}, set: { newValue in
                                edgeDirection = newValue
                                if let selectedEdge = graphViewModel.selectedEdge {
                                    graphViewModel.setEdgeDirection(edge: selectedEdge, direction: newValue)
                                }
                            })) {
                            ForEach(Edge.Directed.allCases, id: \.self) { direction in
                                Text(direction.rawValue).tag(direction)
                            }
                        }
                        .tint(themeViewModel.theme!.accentColor)
                    } label: {
                        Image(systemName: "arrow.left.arrow.right.square")
                            .tint(themeViewModel.theme!.accentColor)
                    }
                }
            }
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Mode", selection: Binding(get: { graphViewModel.getMode() }, set: { newValue in graphViewModel.setMode(newValue)})) {
                        Text("Mode:")
                        Text("Edit").tag(Graph.Mode.edit)
                        Text("Explore").tag(Graph.Mode.explore)
                    }
                    .foregroundStyle(themeViewModel.theme!.accentColor)
                    
                    Picker("Label Color", selection: Binding(
                        get: {
                            if let selectedVertex = graphViewModel.selectedVertex {
                                return selectedVertex.labelColor ?? .white
                            }
                            return Vertex.LabelColor.white
                        },
                        set: { newColor in
                            if let selectedVertex = graphViewModel.selectedVertex {
                                graphViewModel.setVertexLabelColor(id: selectedVertex.id, labelColor: newColor)
                            }
                        }
                    )) {
                        Text("Label Color:")
                        ForEach(Vertex.LabelColor.allCases) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }
                label: {
                    Image(systemName: "gear")
                        .tint(themeViewModel.theme!.accentColor)
                }
                
            }
        }
        
    }
}

struct PreviewGraph {
    let a: Vertex
    let b: Vertex
    let c: Vertex
    let d: Vertex
    let e: Vertex
    let f: Vertex
    let edgeAB: Edge
    let edgeBC: Edge
    let edgeCD: Edge
    let edgeDE: Edge
    let edgeEF: Edge
    let edgeFA: Edge
    let edgeCF: Edge
    let edgeAD: Edge
    let edgeBE: Edge
    var graph: Graph
    
    init() {
        a = Vertex(position: CGPoint(x: 0.35, y: 0.2))
        b = Vertex(position: CGPoint(x: 0.65, y: 0.2))
        c = Vertex(position: CGPoint(x: 0.8, y: 0.5))
        d = Vertex(position: CGPoint(x: 0.65, y: 0.8))
        e = Vertex(position: CGPoint(x: 0.35, y: 0.8))
        f = Vertex(position: CGPoint(x: 0.2, y: 0.5))
        edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        edgeEF = Edge(startVertexID: e.id, endVertexID: f.id)
        edgeFA = Edge(startVertexID: f.id, endVertexID: a.id)
        edgeCF = Edge(startVertexID: c.id, endVertexID: f.id)
        edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        let vertices: [Vertex] = [a, b, c, d, e, f]
        let edges: [Edge] = [edgeAB, edgeBC, edgeCD, edgeDE, edgeEF, edgeFA, edgeCF, edgeAD, edgeBE]
        graph = Graph(vertices: vertices, edges: edges)
        graph.resetMethod = .restoreToOriginal
    }
}

#Preview {
    let preview = PreviewGraph()
    GraphView(graphViewModel: GraphViewModel(graph: preview.graph))
        .environmentObject(ThemeViewModel())
}
