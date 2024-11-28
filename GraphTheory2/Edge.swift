//
//  Edge.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/27/24.
//

import SwiftUI

struct Edge: Identifiable, Codable, Hashable {
    let id: UUID
    var startVertexID: UUID
    var endVertexID: UUID
    var curved = false
    var color: Color
    
    init(startVertexID: UUID, endVertexID: UUID) {
        self.id = UUID()
        self.startVertexID = startVertexID
        self.endVertexID = endVertexID
        self.color = .white
    }
    
    mutating func setColor(_ color: Color) {
        self.color = color
    }
    
    // If v1 is a valid starting point for the edge, then return
    // the other corresponding vertex id
    func traverse(from v1: UUID) -> UUID? {
        if startVertexID == v1 { return endVertexID }
        if endVertexID == v1 { return startVertexID }
        return nil
    }
}

class EdgeViewModel: ObservableObject {
    @Published private var edge: Edge
    private var getVertexPositionByID: (UUID) -> CGPoint?
    private var getOffsetForID: (UUID) -> CGSize? // the vertex offset
    private var getEdgeControlPoints: (Edge) -> (CGPoint, CGPoint)
    private var getEdgeControlPointOffsets: (Edge) -> (CGSize, CGSize)
    
    init(edge: Edge, getVertexPositionByID: @escaping (UUID) -> CGPoint?, getOffset: @escaping (UUID) -> CGSize?,
         getEdgeControlPoints: @escaping (Edge) -> (CGPoint, CGPoint),
         getEdgeControlPointOffsets: @escaping (Edge) -> (CGSize, CGSize)) {
        self.edge = edge
        self.getVertexPositionByID = getVertexPositionByID
        self.getOffsetForID = getOffset
        self.getEdgeControlPoints = getEdgeControlPoints
        self.getEdgeControlPointOffsets = getEdgeControlPointOffsets
    }
    
    func getColor() -> Color {
        return edge.color
    }
    
    func setColor(_ color: Color) {
        edge.color = color
    }
    
    func getStartVertexPosition() -> CGPoint? {
        return getVertexPositionByID(edge.startVertexID)
    }
    
    func getEndVertexPosition() -> CGPoint? {
        return getVertexPositionByID(edge.endVertexID)
    }
    
    func getStartOffset() -> CGSize? {
        return getOffsetForID(edge.startVertexID)
    }
    
    func getEndOffset() -> CGSize? {
        return getOffsetForID(edge.endVertexID)
    }
    
    func getControlPoints() -> (CGPoint, CGPoint) {
        return getEdgeControlPoints(edge)
    }
    
    func getControlPointOffsets() -> (CGSize, CGSize) {
        return getEdgeControlPointOffsets(edge)
    }
    
    func isCurved() -> Bool {
        return edge.curved
    }
}

struct EdgeView: View {
    @ObservedObject var edgeViewModel: EdgeViewModel
    let size: CGSize
    
    init(edgeViewModel: EdgeViewModel, size: CGSize) {
        self.edgeViewModel = edgeViewModel
        self.size = size
    }
    
    var body: some View {
        if let start = edgeViewModel.getStartVertexPosition(),
           let end = edgeViewModel.getEndVertexPosition(), let startOffset = edgeViewModel.getStartOffset(), let endOffset = edgeViewModel.getEndOffset() {
            let (controlPoint1, controlPoint2) = edgeViewModel.getControlPoints()
            let (controlPoint1Offset, controlPoint2Offset) = edgeViewModel.getControlPointOffsets()
            Path { path in
                let startPoint = CGPoint(x: start.x * size.width + startOffset.width, y: start.y * size.height + startOffset.height)
                let endPoint = CGPoint(x: end.x * size.width + endOffset.width, y: end.y * size.height + endOffset.height)
                path.move(to: startPoint)

                if edgeViewModel.isCurved() {
                    let newControlPoint1 = CGPoint(x: controlPoint1.x * size.width + controlPoint1Offset.width,
                                                   y: controlPoint1.y * size.height + controlPoint1Offset.height)
                    let newControlPoint2 = CGPoint(x: controlPoint2.x * size.width + controlPoint2Offset.width,
                                                   y: controlPoint2.y * size.height + controlPoint2Offset.height)
                    path.addCurve(to: endPoint, control1: newControlPoint1, control2: newControlPoint2)
                } else {
                    path.addLine(to: endPoint)
                }
            }
            .stroke(edgeViewModel.getColor(), lineWidth: 5)
        }
        
    }
}

#Preview {
    let vertex1 = Vertex(position: CGPoint(x: 0.2, y: 0.5))
    let vertex2 = Vertex(position: CGPoint(x: 0.8, y: 0.5))
    let edge = Edge(startVertexID: vertex1.id, endVertexID: vertex2.id)
    let graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
    let edgeViewModel = EdgeViewModel(edge: edge, getVertexPositionByID: {id in graph.getVertexByID(id)?.position}, getOffset: {id in graph.getOffsetByID(id)}, getEdgeControlPoints: {edge in graph.getEdgeControlPoints(for: edge)}, getEdgeControlPointOffsets: {edge in graph.getEdgeControlPointOffsets(for: edge)})
    GeometryReader { geometry in
        EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)

    }
}
