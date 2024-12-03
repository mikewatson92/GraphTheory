//
//  Graph.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/27/24.
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
    var edges: [Edge] = []
    var edgeControlPoints1: [UUID: CGPoint] = [:]
    var edgeControlPoints2: [UUID: CGPoint] = [:]
    var edgeControlPoint1Offsets: [UUID: CGSize] = [:]
    var edgeControlPoint2Offsets: [UUID: CGSize] = [:]
    // Default values saved when the graph is initially constructed.
    // Used for restoring to defaults.
    var originalVertices: [UUID: Vertex] = [:]
    var originalEdges: [Edge] = []
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
        
        self.edges = edges
        
        for edge in edges {
            setControlPoints(for: edge)
            edgeControlPoint1Offsets[edge.id] = .zero
            edgeControlPoint2Offsets[edge.id] = .zero
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
        case edit, explore, icosian
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
        edges = []
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
        edges.append(edge)
        setControlPoints(for: edge)
        setControlPoint1Offset(for: edge, translation: .zero)
        setControlPoint2Offset(for: edge, translation: .zero)
    }
    
    mutating func removeEdge(_ edge: Edge) {
        edges.removeAll { $0.id == edge.id }
    }
    
    mutating func removeEdgesConnected(to vertexID: UUID) {
        for edge in edges {
            if edge.startVertexID == vertexID || edge.endVertexID == vertexID {
                removeEdge(edge)
            }
        }
    }
    
    func getVertexByID(_ id: UUID) -> Vertex? {
        return vertices[id]
    }
    
    func getEdgeByID(_ id: UUID) -> Edge? {
        return edges.first { $0.id == id }
    }
    
    func getOffsetByID(_ id: UUID) -> CGSize? {
        return getVertexByID(id)?.offset
    }
    
    func getEdgeWeightPositionByID(_ id: UUID) -> CGPoint? {
        if let edge = edges.first(where: { $0.id == id }) {
            return edge.weightPosition
        }
        return nil
    }
    
    mutating func setEdgeWeightPositionByID(id: UUID, position: CGPoint) {
        if let index = edges.firstIndex(where: { $0.id == id }) {
            edges[index].weightPosition = position
        }
    }
    
    func getEdgeWeightOffsetByID(_ id: UUID) -> CGSize? {
        if let edge = edges.first(where: { $0.id == id }) {
            return edge.weightPositionOffset
        }
        return nil
    }
    
    mutating func setEdgeWeightOffsetByID(id: UUID, offset: CGSize) {
        if let index = edges.firstIndex(where: { $0.id == id }) {
            edges[index].weightPositionOffset = offset
        }
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
        if let index = edges.firstIndex(where: { $0.id == edgeID }) {
            edges[index].setColor(color)
        }
    }
    
    // Return true if the graph contains an edge connecting v1 and v2.
    func doesEdgeExist(_ v1ID: UUID, _ v2ID: UUID) -> Bool {
        for edge in edges {
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
                remainingEdges.removeAll { $0.id == edge.id }
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
        remainingEdges.removeAll { $0.id == firstEdge.id }
        let subGraph = Graph(vertices: Array(vertices.values), edges: remainingEdges)
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
                    newEdges.removeAll { $0.id == edge.id }
                    let subGraph = Graph(vertices: Array(vertices.values), edges: newEdges)
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
        for edge in edges {
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
    
    mutating func curveEdge(edge: Edge) {
        if let index = edges.firstIndex(where: { $0.id == edge.id }) {
            edges[index].curved = true
        }
    }
    
    mutating func straightenEdge(edge: Edge) {
        if let index = edges.firstIndex(where: { $0.id == edge.id }) {
            edges[index].curved = false
        }
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
    var showModeMenu: Bool
    
    init(graph: Graph, showWeights: Bool = false, showModeMenu: Bool = true) {
        self.graph = graph
        self.showWeights = showWeights
        self.mode = graph.mode
        self.showModeMenu = showModeMenu
        timesEdgeSelected = [:]
        for edge in graph.edges {
            let id = edge.id
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
        return graph.edges
    }
    
    func getConnectedEdges(to v: UUID) -> [Edge] {
        return graph.getConnectedEdges(to: v)
    }
    
    func setColorForEdge(edge: Edge, color: Color) {
        let index = graph.edges.firstIndex(of: edge)!
        graph.edges[index].setColor(color)
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
    
    func getWeightPosition(for edge: Edge) -> CGPoint? {
        return graph.getEdgeWeightPositionByID(edge.id)
    }
    
    func setWeightPosition(for edge: Edge, position: CGPoint) {
        DispatchQueue.main.async {
            self.graph.setEdgeWeightPositionByID(id: edge.id, position: position)
        }
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
    
    func createDocument() -> GraphDocument {
        return GraphDocument(graph: graph)
    }
    
    func curveEdge(_ edge: Edge) {
        graph.curveEdge(edge: edge)
    }
    
    func straightenEdge(_ edge: Edge) {
        graph.straightenEdge(edge: edge)
    }
    
    func resetControlPointsAndOffsets(for edge: Edge) {
        graph.resetControlPointsAndOffsets(for: edge)
    }
    
    func clear() {
        graph.clear()
    }
    
    func saveGraphToSandbox(graph: Graph) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent("Graph.json")
        
        do {
            let data = try JSONEncoder().encode(graph)
            try data.write(to: fileURL)
            print("Graph saved to: \(fileURL)")
        } catch {
            print("Failed to save graph: \(error)")
        }
    }
    
    func loadGraphFromSandbox() -> Graph? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate Documents directory")
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent("Graph.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let graph = try JSONDecoder().decode(Graph.self, from: data)
            print("Graph loaded from: \(fileURL)")
            return graph
        } catch {
            print("Failed to load graph: \(error)")
            return nil
        }
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
        }
    }
    
    func handleEdgeDoubleClickGesture(for edge: Edge) {
        if mode == .edit {
            selectedEdge = nil
            graphViewModel.removeEdge(edge)
        }
    }
    
    func handleEdgeLongPressGesture(for edge: Edge) {
        if mode == .edit {
            graphViewModel.straightenEdge(edge)
            graphViewModel.resetControlPointsAndOffsets(for: edge)
        } else if mode == .explore {
            graphViewModel.timesEdgeSelected[edge.id] = 0
            graphViewModel.setColorForEdge(edge: edge, color: .white)
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(graphViewModel.getEdges()) { edge in
                let edgeViewModel = EdgeViewModel(
                    edge: edge,
                    size: geometry.size,
                    getVertexPositionByID: { id in graphViewModel.getGraph().getVertexByID(id)?.position },
                    getShowingWeights: { id in
                        graphViewModel.showWeights
                    },
                    setShowingWeights: { id, show in
                        graphViewModel.showWeights = show
                    },
                    getOffset: { id in graphViewModel.getGraph().getOffsetByID(id) },
                    getEdgeControlPoints: { edge in graphViewModel.getGraph().getEdgeControlPoints(for: edge) },
                    getEdgeControlPointOffsets: { edge in graphViewModel.getGraph().getEdgeControlPointOffsets(for: edge) },
                    getWeightPosition: { edge in graphViewModel.getGraph().getEdgeWeightPositionByID(edge.id)},
                    setWeightPosition: { edge, position in graphViewModel.setWeightPosition(for: edge, position: position) },
                    getWeightPositionOffset: { edge in graphViewModel.getGraph().getEdgeWeightOffsetByID(edge.id) ?? .zero },
                    setWeightPositionOffset: { edge, offset in graphViewModel.setWeightPositionOffset(for: edge, offset: offset)}
                )
                EdgeView(edgeViewModel: edgeViewModel, size: geometry.size, showWeights: graphViewModel.showWeights)
                    .onTapGesture(count: 2) {
                        handleEdgeDoubleClickGesture(for: edge)
                    }
                    .onTapGesture(count: 1) {
                        handleEdgeSingleClickGesture(for: edge)
                    }
                    .onLongPressGesture {
                        handleEdgeLongPressGesture(for: edge)
                    }
                    .onAppear {
                        if edgeViewModel.getEdgeWeightPosition() == nil {
                            edgeViewModel.setEdgeWeightPosition(position: edgeViewModel.weightPosition())
                        }
                    }
            }
            
            // Control points for selected edge
            if mode == .edit {
                if let selectedEdge = selectedEdge {
                    let (controlPoint1, controlPoint2) = graphViewModel.getControlPoints(for: selectedEdge)
                    let (controlPoint1Offset, controlPoint2Offset) = graphViewModel.getControlPointOffsets(for: selectedEdge)
                    let adjustedControlPoint1 = CGPoint(x: controlPoint1.x * geometry.size.width + controlPoint1Offset.width,
                                                        y: controlPoint1.y * geometry.size.height + controlPoint1Offset.height)
                    let adjustedControlPoint2 = CGPoint(x: controlPoint2.x * geometry.size.width + controlPoint2Offset.width,
                                                        y: controlPoint2.y * geometry.size.height + controlPoint2Offset.height)
                    ZStack {
                        Circle()
                            .position(adjustedControlPoint1)
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.red)
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .position(adjustedControlPoint1)
                            .frame(width: 10, height: 10)
                    }
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            graphViewModel.setControlPoint1Offset(for: selectedEdge, translation: drag.translation)
                            graphViewModel.curveEdge(selectedEdge)
                        }).onEnded { _ in
                            let (point, _) = graphViewModel.getControlPoints(for: selectedEdge)
                            let (offset, _) = graphViewModel.getControlPointOffsets(for: selectedEdge)
                            let newX = point.x + offset.width / geometry.size.width
                            let newY = point.y + offset.height / geometry.size.height
                            let newPoint = CGPoint(x: newX, y: newY)
                            graphViewModel.setControlPoint1(for: selectedEdge, at: newPoint)
                            graphViewModel.setControlPoint1Offset(for: selectedEdge, translation: .zero)
                        })
                    ZStack {
                        Circle()
                            .position(adjustedControlPoint2)
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.red)
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .position(adjustedControlPoint2)
                            .frame(width: 10, height: 10)
                    }
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            graphViewModel.setControlPoint2Offset(for: selectedEdge, translation: drag.translation)
                            graphViewModel.curveEdge(selectedEdge)
                        }).onEnded { _ in
                            let (_, point) = graphViewModel.getControlPoints(for: selectedEdge)
                            let (_, offset) = graphViewModel.getControlPointOffsets(for: selectedEdge)
                            let newX = point.x + offset.width / geometry.size.width
                            let newY = point.y + offset.height / geometry.size.height
                            let newPoint = CGPoint(x: newX, y: newY)
                            graphViewModel.setControlPoint2(for: selectedEdge, at: newPoint)
                            graphViewModel.setControlPoint2Offset(for: selectedEdge, translation: .zero)
                        })
                }
            }
            
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
                                vertexViewModel.setOffset(size: drag.translation)
                                //Update the control points and control point offsets for every edge connected to a moving vertex
                                let connectedEdges = graphViewModel.getConnectedEdges(to: vertex.id)
                                for edge in connectedEdges {
                                    graphViewModel.setControlPoint1Offset(for: edge, translation: drag.translation)
                                    graphViewModel.setControlPoint2Offset(for: edge, translation: drag.translation)
                                }
                            }
                        }).onEnded { _ in
                            if mode == .edit {
                                for edge in graphViewModel.getConnectedEdges(to: vertex.id) {
                                    graphViewModel.setWeightPosition(for: edge, position: CGPoint(x: edge.weightPosition!.x + vertexViewModel.getOffset()!.width / (2 * geometry.size.width), y: edge.weightPosition!.y + vertexViewModel.getOffset()!.height / (2 * geometry.size.height)))
                                    //Update the control points and control point offsets for every edge connected to a moving vertex
                                    let (point1, point2) = graphViewModel.getControlPoints(for: edge)
                                    let (offset1, offset2) = graphViewModel.getControlPointOffsets(for: edge)
                                    let newX1 = point1.x + offset1.width / geometry.size.width
                                    let newY1 = point1.y + offset1.height / geometry.size.height
                                    let newX2 = point2.x + offset2.width / geometry.size.width
                                    let newY2 = point2.y + offset2.height / geometry.size.height
                                    let newPoint1 = CGPoint(x: newX1, y: newY1)
                                    let newPoint2 = CGPoint(x: newX2, y: newY2)
                                    graphViewModel.setControlPoint1(for: edge, at: newPoint1)
                                    graphViewModel.setControlPoint1Offset(for: edge, translation: .zero)
                                    graphViewModel.setControlPoint2(for: edge, at: newPoint2)
                                    graphViewModel.setControlPoint2Offset(for: edge, translation: .zero)
                                }
                                // Set the vertex position
                                vertexViewModel.setPosition(CGPoint(x: vertexViewModel.getPosition()!.x + vertexViewModel.getOffset()!.width / geometry.size.width, y: vertexViewModel.getPosition()!.y + vertexViewModel.getOffset()!.height / geometry.size.height))
                                vertexViewModel.setOffset(size: .zero)
                                
                                // Reset the control points and control point offsets for straight edges
                                for edge in graphViewModel.getConnectedEdges(to: vertex.id) {
                                    if !edge.curved {
                                        graphViewModel.resetControlPointsAndOffsets(for: edge)
                                    }
                                }
                            }
                        })
                    .onTapGesture(count: 2) {
                        if mode == .edit {
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
                
                #if os(iOS)
                Color.clear
                    .contentShape(Circle())
                    .position(CGPoint(x: vertex.position.x * geometry.size.width, y: vertex.position.y * geometry.size.height))
                    .frame(width: 50, height: 50)
                    .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                        .onChanged({ drag in
                            if mode == .edit {
                                vertexViewModel.setOffset(size: drag.translation)
                                //Update the control points and control point offsets for every edge connected to a moving vertex
                                let connectedEdges = graphViewModel.getConnectedEdges(to: vertex.id)
                                for edge in connectedEdges {
                                    graphViewModel.setControlPoint1Offset(for: edge, translation: drag.translation)
                                    graphViewModel.setControlPoint2Offset(for: edge, translation: drag.translation)
                                }
                            }
                        }).onEnded { _ in
                            if mode == .edit {
                                for edge in graphViewModel.getConnectedEdges(to: vertex.id) {
                                    graphViewModel.setWeightPosition(for: edge, position: CGPoint(x: edge.weightPosition!.x + vertexViewModel.getOffset()!.width / (2 * geometry.size.width), y: edge.weightPosition!.y + vertexViewModel.getOffset()!.height / (2 * geometry.size.height)))
                                    //Update the control points and control point offsets for every edge connected to a moving vertex
                                    let (point1, point2) = graphViewModel.getControlPoints(for: edge)
                                    let (offset1, offset2) = graphViewModel.getControlPointOffsets(for: edge)
                                    let newX1 = point1.x + offset1.width / geometry.size.width
                                    let newY1 = point1.y + offset1.height / geometry.size.height
                                    let newX2 = point2.x + offset2.width / geometry.size.width
                                    let newY2 = point2.y + offset2.height / geometry.size.height
                                    let newPoint1 = CGPoint(x: newX1, y: newY1)
                                    let newPoint2 = CGPoint(x: newX2, y: newY2)
                                    graphViewModel.setControlPoint1(for: edge, at: newPoint1)
                                    graphViewModel.setControlPoint1Offset(for: edge, translation: .zero)
                                    graphViewModel.setControlPoint2(for: edge, at: newPoint2)
                                    graphViewModel.setControlPoint2Offset(for: edge, translation: .zero)
                                }
                                // Set the vertex position
                                vertexViewModel.setPosition(CGPoint(x: vertexViewModel.getPosition()!.x + vertexViewModel.getOffset()!.width / geometry.size.width, y: vertexViewModel.getPosition()!.y + vertexViewModel.getOffset()!.height / geometry.size.height))
                                vertexViewModel.setOffset(size: .zero)
                                
                                // Reset the control points and control point offsets for straight edges
                                for edge in graphViewModel.getConnectedEdges(to: vertex.id) {
                                    if !edge.curved {
                                        graphViewModel.resetControlPointsAndOffsets(for: edge)
                                    }
                                }
                            }
                        })
                    .onTapGesture(count: 2) {
                        if mode == .edit {
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
                #endif
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                ColorPicker(
                    "Vertex Color",
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
            ToolbarItem(placement: .automatic) {
                Button("Clear") {
                    selectedEdge = nil
                    clear()
                }
            }
            if graphViewModel.showModeMenu {
                ToolbarItem(placement: .automatic) {
                    Menu {
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
