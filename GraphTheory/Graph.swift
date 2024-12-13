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
    var edgeWeightPositions: [UUID: CGPoint] = [:]
    var edgeControlPoints1: [UUID: CGPoint] = [:]
    var edgeControlPoints2: [UUID: CGPoint] = [:]
    var edgeControlPoint1Offsets: [UUID: CGSize] = [:]
    var edgeControlPoint2Offsets: [UUID: CGSize] = [:]
    // Default values saved when the graph is initially constructed.
    // Used for restoring to defaults.
    var originalVertices: [UUID: Vertex] = [:]
    var originalEdges: [UUID: Edge] = [:]
    var originalEdgeControlPoints1: [UUID: CGPoint] = [:]
    var originalEdgeControlPoints2: [UUID: CGPoint] = [:]
    var originalEdgeControlPoint1Offsets: [UUID: CGSize] = [:]
    var originalEdgeControlPoint2Offsets: [UUID: CGSize] = [:]
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
            setControlPoints(for: edge)
            setControlPoint1Offset(for: edge, translation: .zero)
            setControlPoint2Offset(for: edge, translation: .zero)
            initWeightPosition(for: edge)
        }
        
        originalVertices = self.vertices
        originalEdges = self.edges
        originalEdgeControlPoints1 = self.edgeControlPoints1
        originalEdgeControlPoints2 = self.edgeControlPoints2
        originalEdgeControlPoint1Offsets = self.edgeControlPoint1Offsets
        originalEdgeControlPoint2Offsets = self.edgeControlPoint2Offsets
    }
    
    enum ResetFunction: Codable {
        case resetToZero, restoreToOriginal
    }
    
    enum Mode: Codable {
        case edit, explore, icosian, algorithm
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
        edgeControlPoints1.removeAll()
        edgeControlPoints2.removeAll()
        edgeControlPoint1Offsets.removeAll()
        edgeControlPoint2Offsets.removeAll()
    }
    
    mutating func restoreToOriginal() {
        vertices = originalVertices
        edges = originalEdges
        edgeControlPoints1 = originalEdgeControlPoints1
        edgeControlPoints2 = originalEdgeControlPoints2
        edgeControlPoint1Offsets = originalEdgeControlPoint1Offsets
        edgeControlPoint2Offsets = originalEdgeControlPoint2Offsets
    }
    
    mutating func addVertex(_ vertex: Vertex) {
        vertices[vertex.id] = vertex
    }
    
    mutating func removeVertex(_ vertex: Vertex) {
        vertices.removeValue(forKey: vertex.id)
    }
    
    mutating func addEdge(_ edge: Edge) {
        edges[edge.id] = edge
        setControlPoints(for: edge)
        setControlPoint1Offset(for: edge, translation: .zero)
        setControlPoint2Offset(for: edge, translation: .zero)
        initWeightPosition(for: edge)
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
    
    func getVertexByID(_ id: UUID) -> Vertex? {
        return vertices[id]
    }
    
    func getEdgeByID(_ id: UUID) -> Edge? {
        edges[id]
    }
    
    func getOffsetByID(_ id: UUID) -> CGSize? {
        return getVertexByID(id)?.offset
    }
    
    func getEdgeWeightPositionByID(_ id: UUID) -> CGPoint? {
        edgeWeightPositions[id]
    }
    
    mutating func setEdgeWeightPositionByID(id: UUID, position: CGPoint) {
        edgeWeightPositions[id] = position
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
    
    mutating func setVertexColor(forID id: UUID, color: Color) {
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
    
    func isConnected() -> Bool {
        let permutations = Permutation.permute(Array(vertices.values), r: 2)!
        for permutation in permutations {
            if !areVerticesConnected(permutation[0].id, permutation[1].id) {
                return false
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
        let controlPoint1 = edgeControlPoints1[edge.id]!
        let controlPoint2 = edgeControlPoints2[edge.id]!
        return (controlPoint1, controlPoint2)
    }
    
    func getEdgeControlPointOffsets(for edge: Edge) -> (CGSize, CGSize) {
        let controlPoint1Offset = edgeControlPoint1Offsets[edge.id]!
        let controlPoint2Offset = edgeControlPoint2Offsets[edge.id]!
        return (controlPoint1Offset, controlPoint2Offset)
    }
    
    mutating func initWeightPosition(for edge: Edge) {
        let edgePath = EdgePath(startVertexPosition: getVertexByID(edge.startVertexID)!.position, endVertexPosition: getVertexByID(edge.endVertexID)!.position, startOffset: CGSize.zero, endOffset: CGSize.zero, controlPoint1: getEdgeControlPoints(for: edge).0, controlPoint2: getEdgeControlPoints(for: edge).1, controlPoint1Offset: getEdgeControlPointOffsets(for: edge).0, controlPoint2Offset: getEdgeControlPointOffsets(for: edge).1)
        let midPoint = edgePath.midpoint()
        
        if let perpendicularGradient = edgePath.perpendicularGradient() {
            let (pointOnPerpendicular, _) = edgePath.pointOnPerpendicular(point: midPoint, perpendicularGradient: perpendicularGradient, distance: 0.05)
            edgeWeightPositions[edge.id] = CGPoint(
                x: pointOnPerpendicular.x,
                y: pointOnPerpendicular.y
            )
        } else {
            edgeWeightPositions[edge.id] = CGPoint(
                x: midPoint.x,
                y: midPoint.y + 0.05
            )
        }
    }
    
    mutating func setControlPoints(for edge: Edge) {
        let controlPoint1 = calculateControlPoint(for: edge, distance: 0.3)
        let controlPoint2 = calculateControlPoint(for: edge, distance: 0.7)
        edgeControlPoints1[edge.id] = controlPoint1
        edgeControlPoints2[edge.id] = controlPoint2
    }
    
    mutating func setControlPoint1(for edge: Edge, at point: CGPoint) {
        edgeControlPoints1[edge.id] = point
    }
    
    mutating func setControlPoint2(for edge: Edge, at point: CGPoint) {
        edgeControlPoints2[edge.id] = point
    }
    
    mutating func setControlPoint1Offset(for edge: Edge, translation: CGSize) {
        edgeControlPoint1Offsets[edge.id] = translation
    }
    
    mutating func setControlPoint2Offset(for edge: Edge, translation: CGSize) {
        edgeControlPoint2Offsets[edge.id] = translation
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
        edgeControlPoints1[edge.id] = CGPoint(x: edgeControlPoints1[edge.id]!.x + translation.width,
                                              y: edgeControlPoints1[edge.id]!.y + translation.height)
    }
    
    mutating func updateControlPoint2(for edge: Edge, translation: CGSize) {
        edgeControlPoints2[edge.id] = CGPoint(x: edgeControlPoints2[edge.id]!.x + translation.width,
                                              y: edgeControlPoints2[edge.id]!.y + translation.height)
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
    @Published private var graph: Graph
    @Published var timesEdgeSelected: [UUID: Int]
    @Published var mode: Graph.Mode
    @Published var showWeights: Bool
    var movingVertex: Vertex?
    // A copy of the edges before any changes occur
    var edgesWillMove: [Edge] = []
    // A copy of the edges after changes occur
    var edgesDidMove: [Edge] = []
    var vertexWillMove: [UUID: Vertex] = [:]
    var vertexDidMove: [UUID: Vertex] = [:]
    var showModeMenu: Bool
    
    init(graph: Graph, showWeights: Bool = false, showModeMenu: Bool = true) {
        self.graph = graph
        self.showWeights = showWeights
        self.mode = graph.mode
        self.showModeMenu = showModeMenu
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
        print("Vertex ID's:")
        for vertex in graph.vertices.values {
            print(vertex.id)
        }
        print("Edge Vertex ID's:")
        for edge in graph.edges.values {
            print("Start Vertex ID: \(edge.startVertexID)")
            print("End Vertex ID: \(edge.endVertexID)")
        }
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
    
    // Used for storing an initial copy of a vertex before
    // changes occur.
    func vertexWillMove(_ vertex: Vertex) {
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
                    let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: .zero, endOffset: .zero, controlPoint1: getControlPoints(for: edge).0, controlPoint2: getControlPoints(for: edge).1, controlPoint1Offset: getControlPointOffsets(for: edge).0, controlPoint2Offset: getControlPointOffsets(for: edge).1)
                    let (t, distance) = edgePath.closestParameterAndDistance(externalPoint: getWeightPosition(for: edge) ?? CGPoint.zero, p0: startVertex.position, p1: getControlPoints(for: edge).0, p2: getControlPoints(for: edge).1, p3: endVertex.position)
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
    
    func setColor(vertex: Vertex, color: Color) {
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
    
    func getWeight(edge: Edge) -> Double {
        graph.edges[edge.id]!.weight
    }
    
    func setWeight(edge: Edge, weight: Double) {
        graph.edges[edge.id]?.weight = weight
    }
    
    func getWeightPosition(for edge: Edge) -> CGPoint? {
        return graph.getEdgeWeightPositionByID(edge.id)
    }
    
    func setWeightPosition(for edge: Edge, position: CGPoint) {
        graph.setEdgeWeightPositionByID(id: edge.id, position: position)
    }
    
    func getWeightPositionOffset(for edge: Edge) -> CGSize? {
        return graph.getEdgeWeightOffsetByID(edge.id)
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
        let controlPoint1 = graph.edgeControlPoints1[edge.id]!
        let controlPoint2 = graph.edgeControlPoints2[edge.id]!
        return (controlPoint1, controlPoint2)
    }
    
    func getControlPointOffsets(for edge: Edge) -> (CGSize, CGSize) {
        let controlPoint1Offsets = graph.edgeControlPoint1Offsets[edge.id]!
        let controlPoint2Offsets = graph.edgeControlPoint2Offsets[edge.id]!
        return (controlPoint1Offsets, controlPoint2Offsets)
    }
    
    func setControlPoint1Offset(for edge: Edge, translation: CGSize) {
        graph.edgeControlPoint1Offsets[edge.id] = translation
    }
    
    func setControlPoint2Offset(for edge: Edge, translation: CGSize) {
        graph.edgeControlPoint2Offsets[edge.id] = translation
    }
    
    func setMode(_ mode: Graph.Mode) {
        graph.mode = mode
        self.mode = mode
    }
    
    func resetControlPointsAndOffsets(for edge: Edge) {
        graph.resetControlPointsAndOffsets(for: edge)
    }
    
    func clear() {
        graph.clear()
    }
    
}

struct GraphView: View {
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var selectedVertex: Vertex?
    @State private var selectedEdge: Edge?
    @State private var mode: Graph.Mode
    
    init(graphViewModel: GraphViewModel) {
        self.graphViewModel = graphViewModel
        self.mode = graphViewModel.mode
    }
    
    let edgeColors: [Color] = [Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.9, green: 0, blue: 0.9, alpha: 1))]
    
    func clear() {
        graphViewModel.clear()
    }
    
    func edgePath(edgeViewModel: EdgeViewModel) -> EdgePath {
        EdgePath(startVertexPosition: edgeViewModel.getStartVertexPosition()!, endVertexPosition: edgeViewModel.getEndVertexPosition()!, startOffset: edgeViewModel.getStartOffset()!, endOffset: edgeViewModel.getEndOffset()!, controlPoint1: edgeViewModel.getControlPoints().0, controlPoint2: edgeViewModel.getControlPoints().1, controlPoint1Offset: edgeViewModel.getControlPointOffsets().0, controlPoint2Offset: edgeViewModel.getControlPointOffsets().1)
    }
    
    func convertToColor(from cgColor: CGColor) -> Color {
#if os(macOS)
        if let nsColor = NSColor(cgColor: cgColor) {
            return Color(nsColor)
        }
#elseif os(iOS)
        return Color(UIColor(cgColor: cgColor))
#endif
        return Color.clear // Fallback for invalid `CGColor`
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
        selectedVertex = nil
        switch mode {
            // Allows the user to select an edge to display the control points
        case .edit:
            if selectedEdge?.id != edge.id {
                selectedEdge = edge
            } else {
                selectedEdge = nil
            }
            // Change the colors of the edges to simulate a path through the graph
        case .explore:
            graphViewModel.timesEdgeSelected[edge.id]! += 1
            let timesSelected = graphViewModel.timesEdgeSelected[edge.id]!
            graphViewModel.setColorForEdge(edge: edge, color: edgeColors[(timesSelected - 1) % edgeColors.count])
        case .icosian:
            selectedEdge = edge
        case .algorithm:
            break
        }
    }
    
    func handleEdgeDoubleClickGesture(for edge: Edge) {
        if mode == .edit {
            selectedEdge = nil
        }
    }
    
    func handleEdgeLongPressGesture(for edge: Edge) {
        if mode == .edit {
            graphViewModel.resetControlPointsAndOffsets(for: edge)
        } else if mode == .explore {
            graphViewModel.timesEdgeSelected[edge.id] = 0
            graphViewModel.setColorForEdge(edge: edge, color: .white)
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                let edgeViewModel = EdgeViewModel(
                    edge: edge,
                    size: geometry.size,
                    removeEdge: { edge in
                        graphViewModel.removeEdge(edge)
                    },
                    getVertexPositionByID: { id in graphViewModel.getGraph().getVertexByID(id)?.position },
                    getShowingWeights: { id in
                        graphViewModel.showWeights
                    },
                    setShowingWeights: { id, show in
                        graphViewModel.showWeights = show
                    },
                    getOffset: { id in graphViewModel.getGraph().getOffsetByID(id) },
                    getEdgeControlPoints: { edge in graphViewModel.getGraph().getEdgeControlPoints(for: edge) },
                    setEdgeControlPoint1: { edge, point in
                        graphViewModel.setControlPoint1(for: edge, at: point)
                    },
                    setEdgeControlPoint2: { edge, point in
                        graphViewModel.setControlPoint2(for: edge, at: point)
                    },
                    getEdgeControlPointOffsets: { edge in graphViewModel.getGraph().getEdgeControlPointOffsets(for: edge) },
                    setEdgeControlPoint1Offset: { edge, size in
                        graphViewModel.setControlPoint1Offset(for: edge, translation: size)
                    },
                    setEdgeControlPoint2Offset: { edge, size in
                        graphViewModel.setControlPoint2Offset(for: edge, translation: size)
                    },
                    getWeightPosition: { edge in graphViewModel.getGraph().getEdgeWeightPositionByID(edge.id) ?? .zero},
                    setWeightPosition: { edge, position in graphViewModel.setWeightPosition(for: edge, position: position) },
                    getWeightPositionOffset: { edge in graphViewModel.getGraph().getEdgeWeightOffsetByID(edge.id) ?? .zero },
                    setWeightPositionOffset: { edge, offset in graphViewModel.setWeightPositionOffset(for: edge, offset: offset)},
                    getWeight: { edge in
                        graphViewModel.getWeight(edge: edge)
                    },
                    setWeight: { edge, weight in
                        graphViewModel.setWeight(edge: edge, weight: weight)
                    },
                    getMode: { graphViewModel.mode }
                )
                EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
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
                let vertexViewModel = VertexViewModel(
                    vertex: vertex,
                    getVertexPosition: { id in graphViewModel.getGraph().getVertexByID(id)?.position },
                    setVertexPosition: { id, position in graphViewModel.setVertexPosition(vertex: vertex, position: position) },
                    getVertexOffset: { id in graphViewModel.getGraph().getVertexByID(id)?.offset},
                    setVertexOffset: { id, size in graphViewModel.setVertexOffset(vertex: vertex, size: size)},
                    setVertexColor: { id, color in graphViewModel.setColor(vertex: graphViewModel.getGraph().getVertexByID(vertex.id)!, color: color)})
                
                VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                    .shadow(color: vertexViewModel.getVertexID() == selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            if mode == .edit {
                                graphViewModel.movingVertex = vertex
                                vertexViewModel.setOffset(size: drag.translation)
                                // Notify the model to store copies of
                                // the vertex and connected edges in
                                // their original states.
                                graphViewModel.vertexWillMove(vertex)
                                //Update the control points and control point offsets for every edge connected to a moving vertex
                                let connectedEdges = graphViewModel.getConnectedEdges(to: vertex.id)
                                for edge in connectedEdges {
                                    // Keep original copies of all
                                    // vertices connected by edge.
                                    let otherVertexID = edge.traverse(from: vertex.id)!
                                    let otherVertex = graphViewModel.getVertexByID(otherVertexID)!
                                    graphViewModel.vertexWillMove(otherVertex)
                                    // Update the control point
                                    // offsets for edge
                                    graphViewModel.setEdgeControlPointOffsets(edge: edge, translation: drag.translation, geometrySize: geometry.size)
                                }
                            }
                        }).onEnded { _ in
                            if mode == .edit {
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
                                        let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: startVertex.offset, endOffset: endVertex.offset, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1)
                                        let pointOnBezierCurve = edgePath.pointOnBezierCurve(t: t, p0: startVertex.position, p1: graphViewModel.getControlPoints(for: edge).0, p2: graphViewModel.getControlPoints(for: edge).1, p3: endVertex.position)
                                        var newWeightPosition: CGPoint
                                        if let bezierGradient = edgePath.bezierTangentGradient(t: t, p0: startVertex.position, p1: graphViewModel.getControlPoints(for: edge).0, p2: graphViewModel.getControlPoints(for: edge).1, p3: endVertex.position) {
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
                                        graphViewModel.setWeightPosition(for: edge, position: newWeightPosition)
                                        
                                    }
                                    graphViewModel.resetVertexEdgeChanges()
                                    
                                }
                            }
                        })
                    .onTapGesture(count: 2) {
                        if mode == .edit {
                            if graphViewModel.getConnectedEdges(to: vertex.id).contains(where: { $0.id == selectedEdge?.id }) {
                                selectedEdge = nil
                            }
                            graphViewModel.removeEdgesConnected(to: vertexViewModel.getVertexID())
                            graphViewModel.removeVertex(vertex)
                            
                            selectedVertex = nil
                        }
                    }
                    .onTapGesture(count: 1) {
                        if mode == .edit || mode == .explore {
                            selectedEdge = nil
                            if selectedVertex == nil {
                                selectedVertex = graphViewModel.getVertexByID(vertexViewModel.getVertexID())
                            } else if selectedVertex!.id == vertexViewModel.getVertexID() {
                                selectedVertex = nil
                            } else if graphViewModel.mode == .edit {
                                graphViewModel.addEdge(Edge(startVertexID: selectedVertex!.id, endVertexID: vertexViewModel.getVertexID()))
                                selectedVertex = nil
                            } else {
                                selectedVertex = nil
                            }
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Clear") {
                    selectedEdge = nil
                    clear()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                ColorPicker(
                    "",
                    selection: Binding(
                        get: {
                            if let selectedEdge = selectedEdge {
                                return selectedEdge.color
                            } else if let selectedVertex = selectedVertex {
                                return selectedVertex.color
                            } else {
                                return Color.white
                            }
                        },
                        set: { newColor in
                            if let selectedVertex = selectedVertex {
                                graphViewModel.setColor(vertex: selectedVertex, color: newColor)
                                self.selectedVertex = graphViewModel.getVertexByID(selectedVertex.id) // Sync selected vertex
                            } else if let selectedEdge = selectedEdge {
                                graphViewModel.setColorForEdge(edge: selectedEdge, color: newColor)
                                self.selectedEdge = graphViewModel.getEdge(selectedEdge)
                            }
                        }
                    )
                )
                .labelsHidden()
            }
            if graphViewModel.showModeMenu {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Picker("Label Color", selection: Binding(
                            get: {
                                if let selectedVertex = selectedVertex {
                                    return selectedVertex.labelColor
                                }
                                return Vertex.LabelColor.white
                            },
                            set: { newColor in
                                if let selectedVertex = selectedVertex {
                                    graphViewModel.setVertexLabelColor(id: selectedVertex.id, labelColor: newColor)
                                }
                            }
                        )) {
                            Text("Label Color:")
                            ForEach(Vertex.LabelColor.allCases) { color in
                                Text(color.rawValue).tag(color)
                            }
                        }
                        Button("Edit Mode") {
                            graphViewModel.setMode(.edit)
                            mode = .edit
                        }
                        Button("Explore Mode") {
                            selectedVertex = nil
                            selectedEdge = nil
                            graphViewModel.setMode(.explore)
                            mode = .explore
                        }
                    } label: {
                        Label("Mode", systemImage: "ellipsis.circle") // Replace with your preferred icon
                    }
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
}
