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
        }
        originalVertices = self.vertices
        originalEdges = self.edges
    }
    
    enum ResetFunction: Codable {
        case resetToZero, restoreToOriginal
    }
    
    enum Mode: String, Codable {
        case edit = "Edit"
        case explore = "Explore"
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
    
    // Returns an array of all direct edges between two vertices.
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
    
    func yIntercept(of edge: Edge) -> CGFloat? {
        let startPoint = vertices[edge.startVertexID]!.position
        let y = startPoint.y
        let x = startPoint.x
        if let m = gradient(of: edge) {
            return y - m * x
        }
        return nil
    }
    
    func gradient(of edge: Edge) -> CGFloat? {
        let endVertex = vertices[edge.endVertexID]!
        let startVertex = vertices[edge.startVertexID]!
        let y2 = endVertex.position.y
        let y1 = startVertex.position.y
        let x2 = endVertex.position.x
        let x1 = startVertex.position.x
        let dy = y2 - y1
        let dx = x2 - x1
        
        if dx == 0 { return nil }
        
        return dy / dx
    }
}

class GraphViewModel: ObservableObject {
    @Published private(set) var graph: Graph
    @Published var timesEdgeSelected: [UUID: Int]
    @Published var showWeights: Bool
    @Published var selectedVertex: Vertex?
    @Published var selectedEdge: Edge?
    @Published var edgeDirection = Edge.Directed.none
    var movingVertex: Vertex?
    // A copy of the edges before any changes occur
    var edgesWillMove: [Edge] = []
    // A copy of the edges after changes occur
    var edgesDidMove: [Edge] = []
    var vertexWillMove: [UUID: Vertex] = [:]
    var vertexDidMove: [UUID: Vertex] = [:]
    var mode: Graph.Mode {
        get {
            graph.mode
        } set {
            graph.mode = newValue
        }
    }
    
    init(graph: Graph, showWeights: Bool = false) {
        self.graph = graph
        self.showWeights = showWeights
        timesEdgeSelected = [:]
        for id in graph.edges.keys {
            timesEdgeSelected[id] = 0
        }
        for edge in graph.edges.values {
            let (controlPoint1, controlPoint2) = initControlPointsFor(edge: edge)
            if edge.controlPoint1 == .zero {
                setControlPoint1(for: edge, at: controlPoint1)
                self.graph.originalEdges[edge.id]?.controlPoint1 = controlPoint1
            }
            if edge.controlPoint2 == .zero {
                setControlPoint2(for: edge, at: controlPoint2)
                self.graph.originalEdges[edge.id]?.controlPoint2 = controlPoint2
            }
        }
    }
    
    func addVertex(_ vertex: Vertex) {
        graph.vertices[vertex.id] = vertex
    }
    
    func removeVertex(_ vertex: Vertex) {
        for edge in graph.getConnectedEdges(to: vertex.id) {
            graph.edges.removeValue(forKey: edge.id)
        }
        graph.vertices.removeValue(forKey: vertex.id)
    }
    
    func getVertices() -> [Vertex] {
        return Array(graph.vertices.values)
    }
    
    func addEdge(_ edge: Edge) {
        var edge = edge
        if (edge.controlPoint1 == .zero || edge.controlPoint2 == .zero) && edge.startVertexID != edge.endVertexID {
            let (controlPoint1, controlPoint2) = initControlPointsFor(edge: edge)
            edge.controlPoint1 = controlPoint1
            edge.controlPoint2 = controlPoint2
        }
        graph.edges[edge.id] = edge
        timesEdgeSelected[edge.id] = 0
    }
    
    func removeEdge(_ edge: Edge) {
        graph.edges.removeValue(forKey: edge.id)
    }
    
    func removeEdgesConnected(to vertexID: UUID) {
        for edge in graph.edges.values {
            if edge.startVertexID == vertexID || edge.endVertexID == vertexID {
                graph.edges.removeValue(forKey: edge.id)
            }
        }
    }
    
    func getEdges() -> [Edge] {
        return Array(graph.edges.values)
    }
    
    private func resetToZero() {
        graph.vertices = [:]
        graph.edges = [:]
    }
    
    private func restoreToOriginal() {
        graph.vertices = graph.originalVertices
        graph.edges = graph.originalEdges
    }
    
    func clear() {
        switch graph.resetMethod {
        case .resetToZero:
            resetToZero()
        case .restoreToOriginal:
            restoreToOriginal()
        }
    }
    
    func calculateControlPointFor(edge: Edge, distance: CGFloat) -> CGPoint {
        let startPoint = graph.vertices[edge.startVertexID]!.position
        let endPoint = graph.vertices[edge.endVertexID]!.position
        
        // If the edge is not a vertical line, calculate the control point.
        if let yIntercept = graph.yIntercept(of: edge), let gradient = graph.gradient(of: edge) {
            let newX = startPoint.x + distance * (endPoint.x - startPoint.x)
            let newY = gradient * newX + yIntercept
            return CGPoint(x: newX, y: newY)
        }
        // If the edge is a vertical line, calculate the control point.
        let newX = startPoint.x
        let newY = startPoint.y + distance * (endPoint.y - startPoint.y)
        return CGPoint(x: newX, y: newY)
    }
    
    func initControlPointsFor(edge: Edge) -> (CGPoint, CGPoint){
        let controlPoint1 = calculateControlPointFor(edge: edge, distance: 0.3)
        let controlPoint2 = calculateControlPointFor(edge: edge, distance: 0.7)
        return (controlPoint1, controlPoint2)
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
            let connectedEdges = graph.getConnectedEdges(to: vertex.id)
            for edge in connectedEdges {
                // Used for storing an initial copy of an edge before
                // changes occur.
                if !edgesWillMove.contains(where: {$0.id == edge.id}) {
                    edgesWillMove.append(edge)
                }
                // Calculate the relative positions of the weights
                if let startVertex = graph.vertices[edge.startVertexID], let endVertex = graph.vertices[edge.endVertexID] {
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
        let connectedEdges = graph.getConnectedEdges(to: vertex.id)
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
        graph.edges[edge.id]?.controlPoint1 = CGPoint(x: x1, y: y1)
        graph.edges[edge.id]?.controlPoint2 = CGPoint(x: x2, y: y2)
    }
    
    // When a vertex starts being dragged by translation,
    // update the offsets for the control points of the edge.
    func setEdgeControlPointOffsets(edge: Edge, translation: CGSize, geometrySize: CGSize) {
        if edge.startVertexID == edge.endVertexID {
            setControlPoint1Offset(for: edge, translation: translation)
            setControlPoint2Offset(for: edge, translation: translation)
            return
        }
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
    
    func setVertexLabel(id: UUID, label: String) {
        graph.vertices[id]?.label = label
    }
    
    func setVertexLabelColor(id: UUID, labelColor: Vertex.LabelColor) {
        graph.vertices[id]?.labelColor = labelColor
    }
    
    func setVertexPosition(vertex: Vertex, position: CGPoint) {
        graph.vertices[vertex.id]?.position = position
        objectWillChange.send()
    }
    
    func setVertexOffset(vertex: Vertex, size: CGSize) {
        graph.vertices[vertex.id]?.offset = size
    }
    
    func setVertexColor(vertex: Vertex, color: Color?) {
        graph.vertices[vertex.id]?.color = color
    }
    
    func setControlPoint1(for edge: Edge, at point: CGPoint) {
        graph.edges[edge.id]?.controlPoint1 = point
    }
    
    func setControlPoint2(for edge: Edge, at point: CGPoint) {
        graph.edges[edge.id]?.controlPoint2 = point
    }
    
    func getWeightPositionOffset(for edge: Edge) -> CGSize? {
        return graph.edges[edge.id]?.weightPositionOffset
    }
    
    func setWeight(edge: Edge, weight: Double) {
        graph.edges[edge.id]?.weight = weight
    }
    
    func setWeightPosition(for edge: Edge, position: CGPoint, size: CGSize) {
        let edgeViewModel = EdgeViewModel(edge: edge, size: size, graphViewModel: self)
        let (t, distance) = edgeViewModel.edgePath.closestParameterAndDistance(externalPoint: position)
        graph.edges[edge.id]?.weightPositionParameterT = t
        graph.edges[edge.id]?.weightPositionDistance = distance
    }
        
    func setWeightPositionOffset(for edge: Edge, offset: CGSize) {
        graph.edges[edge.id]?.weightPositionOffset = offset
    }
    
    func updateControlPoint1(for edge: Edge, translation: CGSize) {
        if let originalControlPoint1 = graph.edges[edge.id]?.controlPoint1 {
            graph.edges[edge.id]?.controlPoint1 = CGPoint(x: originalControlPoint1.x + translation.width,
                                                    y: originalControlPoint1.y + translation.height)
        }
    }
    
    func updateControlPoint2(for edge: Edge, translation: CGSize) {
        if let originalControlPoint2 = graph.edges[edge.id]?.controlPoint2 {
            graph.edges[edge.id]?.controlPoint2 = CGPoint(x: originalControlPoint2.x + translation.width,
                                                    y: originalControlPoint2.y + translation.height)
        }
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
}

struct GraphView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var vertexEdgeColor: Color = .white
    
    init(graphViewModel: GraphViewModel) {
        self.graphViewModel = graphViewModel
    }
    
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
    
    func handleVertexOnDragGesture(for vertexViewModel: VertexViewModel, drag: DragGesture.Value, geometrySize: CGSize) {
        if graphViewModel.mode == .edit {
            graphViewModel.movingVertex = vertexViewModel.vertex
            vertexViewModel.offset = drag.translation
            // Notify the model to store copies of
            // the vertex and connected edges in
            // their original states.
            graphViewModel.vertexWillMove(vertexViewModel.vertex, size: geometrySize)
            //Update the control points and control point offsets for every edge connected to a moving vertex
            let connectedEdges = graphViewModel.graph.getConnectedEdges(to: vertexViewModel.id)
            for edge in connectedEdges {
                // Keep original copies of all
                // vertices connected by edge.
                let otherVertexID = edge.traverse(from: vertexViewModel.id)!
                let otherVertex = graphViewModel.graph.vertices[otherVertexID]!
                graphViewModel.vertexWillMove(otherVertex, size: geometrySize)
                // Update the control point
                // offsets for edge
                graphViewModel.setEdgeControlPointOffsets(edge: edge, translation: drag.translation, geometrySize: geometrySize)
            }
        }
    }
    
    func handleVertexEndDragGesture(for vertexViewModel: VertexViewModel, geometrySize: CGSize) {
        if graphViewModel.mode == .edit {
            let vertex = vertexViewModel.vertex
            graphViewModel.movingVertex = nil
            graphViewModel.vertexDidMove(vertex)
            // Set the vertex position
            vertexViewModel.position = CGPoint(x: vertexViewModel.position.x + vertexViewModel.offset.width / geometrySize.width, y: vertexViewModel.position.y + vertexViewModel.offset.height / geometrySize.height)
            vertexViewModel.offset = .zero
            
            for edge in graphViewModel.graph.getConnectedEdges(to: vertex.id) {
                //Update the control points and control point offsets for every edge connected to a moving vertex
                if edge.startVertexID != edge.endVertexID {
                    graphViewModel.setEdgeRelativeControlPoints(edge: edge, geometrySize: geometrySize)
                } else {
                    let controlPoint1 = edge.controlPoint1
                    let controlPoint2 = edge.controlPoint2
                    let offset = edge.controlPoint1Offset
                    graphViewModel.setControlPoint1(for: edge, at: CGPoint(x: controlPoint1.x + offset.width / geometrySize.width,
                                                                           y: controlPoint1.y + offset.height / geometrySize.height))
                    graphViewModel.setControlPoint2(for: edge, at: CGPoint(x: controlPoint2.x + offset.width / geometrySize.width,
                                                                           y: controlPoint2.y + offset.height / geometrySize.height))
                }
                graphViewModel.setControlPoint1Offset(for: edge, translation: .zero)
                graphViewModel.setControlPoint2Offset(for: edge, translation: .zero)
                // Reposition the weight
                if let t = graphViewModel.getEdges().first(where: {$0.id == edge.id})?.weightPositionParameterT, let distance = graphViewModel.getEdges().first(where: {$0.id == edge.id})?.weightPositionDistance, let startVertex = graphViewModel.graph.vertices[edge.startVertexID], let endVertex = graphViewModel.graph.vertices[edge.endVertexID] {
                    let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: startVertex.offset, endOffset: endVertex.offset, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1, size: geometrySize)
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
                    graphViewModel.setWeightPosition(for: edge, position: newWeightPosition, size: geometrySize)
                    
                }
                graphViewModel.resetVertexEdgeChanges()
                
            }
        }
    }
    
    func handleVertexSingleClickGesture(for vertex: Vertex) {
        if graphViewModel.mode == .edit || graphViewModel.mode == .explore {
            graphViewModel.selectedEdge = nil
            if graphViewModel.selectedVertex == nil {
                graphViewModel.selectedVertex = graphViewModel.graph.vertices[vertex.id]!
            } else if graphViewModel.selectedVertex!.id == vertex.id {
                graphViewModel.selectedVertex = nil
            } else if graphViewModel.mode == .edit {
                let newEdge = Edge(startVertexID: graphViewModel.selectedVertex!.id, endVertexID: vertex.id)
                graphViewModel.addEdge(newEdge)
                graphViewModel.setEdgeDirection(edge: newEdge, direction: graphViewModel.edgeDirection)
                graphViewModel.selectedVertex = nil
            } else {
                graphViewModel.selectedVertex = nil
            }
        }
    }
    
    func handleVertexDoubleClickGesture(for vertex: Vertex) {
        if graphViewModel.mode == .edit {
            if graphViewModel.graph.getConnectedEdges(to: vertex.id).contains(where: { $0.id == graphViewModel.selectedEdge?.id }) {
                graphViewModel.selectedEdge = nil
            }
            graphViewModel.removeEdgesConnected(to: vertex.id)
            graphViewModel.removeVertex(vertex)
            graphViewModel.selectedVertex = nil
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(graphViewModel.getEdges()) { edge in
                let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                EdgeView(edgeViewModel: edgeViewModel)
            }
            
            // The vertices
            ForEach(graphViewModel.getVertices()) { vertex in
                let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                
                VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                    .shadow(color: vertexViewModel.id == graphViewModel.selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                    .onAppear {
                        if vertexViewModel.color == nil {
                            vertexViewModel.color = vertexEdgeColor
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            handleVertexOnDragGesture(for: vertexViewModel, drag: drag, geometrySize: geometry.size)
                        }).onEnded { _ in
                            handleVertexEndDragGesture(for: vertexViewModel, geometrySize: geometry.size)
                        })
                    .onTapGesture(count: 2) {
                        handleVertexDoubleClickGesture(for: vertex)
                    }
                    .onTapGesture(count: 1) {
                        handleVertexSingleClickGesture(for: vertex)
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
                                graphViewModel.selectedEdge =  graphViewModel.graph.edges[selectedEdge.id]
                            } else if let selectedVertex = graphViewModel.selectedVertex {
                                graphViewModel.setVertexColor(vertex: selectedVertex, color: newColor)
                                graphViewModel.selectedVertex = graphViewModel.graph.vertices[selectedVertex.id]! // Sync selected vertex
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
                    NavigationLink(destination: KruskalView(kruskalViewModel: KruskalViewModel(graphViewModel: GraphViewModel(graph: graphViewModel.graph, showWeights: true)), completion: .constant(false))) {
                        Text("Kruskal")
                    }
                    NavigationLink(destination: PrimView(graph: graphViewModel.graph)) {
                        Text("Prim")
                    }
                    NavigationLink(destination: ChinesePostmanView(graph: graphViewModel.graph)) {
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
                Button(action: {
                    if let selectedVertex = graphViewModel.selectedVertex {
                        var edge = Edge(startVertexID: selectedVertex.id, endVertexID: selectedVertex.id)
                        let x1 = selectedVertex.position.x - 0.1
                        let y1 = selectedVertex.position.y + 0.1
                        let x2 = selectedVertex.position.x + 0.1
                        let y2 = selectedVertex.position.y + 0.1
                        edge.controlPoint1 = CGPoint(x: x1, y: y1)
                        edge.controlPoint2 = CGPoint(x: x2, y: y2)
                        graphViewModel.addEdge(edge)
                    }
                }) {
                    Image(systemName: "point.forward.to.point.capsulepath.fill")
                        .tint(themeViewModel.theme!.accentColor)
                }
            }
            ToolbarItem(placement: .automatic) {
                Menu {
                    Toggle(isOn: $graphViewModel.showWeights) {
                        Label("Weights", systemImage: "number.square").tint(themeViewModel.theme!.accentColor)
                    }
                    Picker("Direction", systemImage: "arrow.left.and.right", selection: Binding(get: {
                        if let selectedEdge = graphViewModel.selectedEdge {
                            return graphViewModel.getEdgeDirection(selectedEdge)
                        } else {
                            return graphViewModel.edgeDirection
                        }}, set: { newValue in
                            graphViewModel.edgeDirection = newValue
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
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Mode", selection: Binding(get: { graphViewModel.mode }, set: { newValue in graphViewModel.mode = newValue })) {
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
