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
    var weight: Double = 0.0
    var weightPosition: CGPoint?
    var weightPositionOffset: CGSize = .zero
    
    init(startVertexID: UUID, endVertexID: UUID) {
        self.id = UUID()
        self.startVertexID = startVertexID
        self.endVertexID = endVertexID
        self.color = Color.primary
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
    var size: CGSize
    lazy var edgePath: EdgePath = EdgePath(startVertexPosition: getVertexPositionByID(edge.startVertexID)!, endVertexPosition: getVertexPositionByID(edge.endVertexID)!, startOffset: getOffsetForID(edge.startVertexID)!, endOffset: getOffsetForID(edge.endVertexID)!, controlPoint1: getEdgeControlPoints(edge).0, controlPoint2: getEdgeControlPoints(edge).1, controlPoint1Offset: getEdgeControlPointOffsets(edge).0, controlPoint2Offset: getEdgeControlPointOffsets(edge).1, isCurved: edge.curved)
    var getShowingWeights: (UUID) -> Bool
    var setShowingWeights: (UUID, Bool) -> Void
    private var getVertexPositionByID: (UUID) -> CGPoint?
    private var getOffsetForID: (UUID) -> CGSize? // the vertex offset
    private var getEdgeControlPoints: (Edge) -> (CGPoint, CGPoint)
    private var getEdgeControlPointOffsets: (Edge) -> (CGSize, CGSize)
    private var getWeightPosition: (Edge) -> CGPoint?
    private var setWeightPosition: (Edge, CGPoint) -> Void
    private var getWeightPositionOffset: (Edge) -> CGSize
    private var setWeightPositionOffset: (Edge, CGSize) -> Void
    
    init(edge: Edge, size: CGSize,
         getVertexPositionByID: @escaping (UUID) -> CGPoint?,
         getShowingWeights: @escaping (UUID) -> Bool,
         setShowingWeights: @escaping (UUID, Bool) -> Void,
         getOffset: @escaping (UUID) -> CGSize?,
         getEdgeControlPoints: @escaping (Edge) -> (CGPoint, CGPoint),
         getEdgeControlPointOffsets: @escaping (Edge) -> (CGSize, CGSize),
         getWeightPosition: @escaping (Edge) -> CGPoint?,
         setWeightPosition: @escaping (Edge, CGPoint) -> Void,
         getWeightPositionOffset: @escaping (Edge) -> CGSize,
         setWeightPositionOffset: @escaping (Edge, CGSize) -> Void
    ) {
        self.edge = edge
        self.size = size
        self.getShowingWeights = getShowingWeights
        self.setShowingWeights = setShowingWeights
        self.getVertexPositionByID = getVertexPositionByID
        self.getOffsetForID = getOffset
        self.getEdgeControlPoints = getEdgeControlPoints
        self.getEdgeControlPointOffsets = getEdgeControlPointOffsets
        self.getWeightPosition = getWeightPosition
        self.setWeightPosition = setWeightPosition
        self.getWeightPositionOffset = getWeightPositionOffset
        self.setWeightPositionOffset = setWeightPositionOffset
    }
    
    func weightPosition() -> CGPoint {
        let midPoint = edgePath.midpoint()
        let offset = getEdgeWeightOffset()
        
        if let perpendicularGradient = edgePath.perpendicularGradient() {
            let (pointOnPerpendicular, _) = edgePath.pointOnPerpendicular(midpoint: midPoint, perpendicularGradient: perpendicularGradient, distance: 0.05)
            return CGPoint(
                x: pointOnPerpendicular.x,
                y: pointOnPerpendicular.y
            )
        }
        
        return CGPoint(
            x: midPoint.x * size.width + offset.width,
            y: (midPoint.y + 0.05) * size.height + offset.height
        )
    }
    
    func getID() -> UUID {
        return edge.id
    }
    
    func getColor() -> Color {
        return edge.color
    }
    
    func setColor(_ color: Color) {
        edge.color = color
    }
    
    func getWeight() -> Double {
        return edge.weight
    }
    
    func setWeight(_ weight: Double) {
        edge.weight = weight
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
    
    func getEdgeWeightPosition() -> CGPoint? {
        return getWeightPosition(edge)
    }
    
    func setEdgeWeightPosition(position: CGPoint) {
        setWeightPosition(edge, position)
    }
    
    func getEdgeWeightOffset() -> CGSize {
        return getWeightPositionOffset(edge)
    }
    
    func setEdgeWeightOffset(_ size: CGSize) {
        setWeightPositionOffset(edge, size)
    }
    
    func isCurved() -> Bool {
        return edge.curved
    }
}

struct EdgeView: View {
    @ObservedObject var edgeViewModel: EdgeViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var edittingWeight = false
    @State private var weight: Double = 0.0
    @State private var tempWeightPosition: CGPoint
    @State private var tempWeightPositionOffset: CGSize = .zero
    var size: CGSize
    
    init(edgeViewModel: EdgeViewModel, size: CGSize, showWeights: Bool = false) {
        self.edgeViewModel = edgeViewModel
        self.size = size
        if edgeViewModel.getEdgeWeightPosition() == nil {
            let newX = edgeViewModel.weightPosition().x
            let newY = edgeViewModel.weightPosition().y
            edgeViewModel.setEdgeWeightPosition(position: CGPoint(x: newX, y: newY))
            self.tempWeightPosition = CGPoint(x: newX, y: newY)
        } else {
            self.tempWeightPosition = edgeViewModel.getEdgeWeightPosition()!
        }
        self.weight = edgeViewModel.getWeight() // Initialize weight
    }
    
    var body: some View {
        ZStack {
            edgeViewModel.edgePath.makePath(size: size)
            #if os(macOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 5)
            #elseif os(iOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 15)
            #endif
        }
        
        
        if edgeViewModel.getShowingWeights(edgeViewModel.getID()) {
            // TextField for editing the weight
            
            if edittingWeight {
                ZStack {
                    TextField("Enter weight", value: $weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    //.keyboardType()
                    #if os(macOS)
                        .frame(width: 50, height: 10)
                    #elseif os(iOS)
                        .focused($isTextFieldFocused)
                        .frame(width: 50, height: 20)
                        //.keyboardType(.decimalPad)
                    #endif
                        .onSubmit {
                            isTextFieldFocused = false
                            edittingWeight = false
                            edgeViewModel.setWeight(weight)
                        }
                    #if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
                    #endif
                }
                        .position(CGPoint(x: (edgeViewModel.getEdgeWeightPosition()?.x ?? tempWeightPosition.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.getEdgeWeightPosition()?.y ?? tempWeightPosition.y) * size.height + tempWeightPositionOffset.height))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                tempWeightPositionOffset = drag.translation
                            }
                            .onEnded { _ in
                                tempWeightPosition = CGPoint(x: tempWeightPosition.x + tempWeightPositionOffset.width / size.width, y: tempWeightPosition.y + tempWeightPositionOffset.height / size.height)
                                tempWeightPositionOffset = .zero
                                edgeViewModel.setEdgeWeightPosition(position: tempWeightPosition)
                                edgeViewModel.setEdgeWeightOffset(.zero)
                            })
            } else {
                ZStack {
                    Text("\(weight.formatted())")
                    #if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
                    #endif

                }
                    .position(CGPoint(x: (edgeViewModel.getEdgeWeightPosition()?.x ?? tempWeightPosition.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.getEdgeWeightPosition()?.y ?? tempWeightPosition.y) * size.height + tempWeightPositionOffset.height))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                tempWeightPositionOffset = drag.translation
                            }
                            .onEnded { _ in
                                tempWeightPosition = CGPoint(x: tempWeightPosition.x + tempWeightPositionOffset.width / size.width, y: tempWeightPosition.y + tempWeightPositionOffset.height / size.height)
                                tempWeightPositionOffset = .zero
                                edgeViewModel.setEdgeWeightPosition(position: tempWeightPosition)
                                edgeViewModel.setEdgeWeightOffset(.zero)
                            })
                    .onTapGesture(count: 1) {
                        isTextFieldFocused = true
                        edittingWeight = true
                    }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        let vertex1 = Vertex(position: CGPoint(x: 0.2, y: 0.5))
        let vertex2 = Vertex(position: CGPoint(x: 0.8, y: 0.5))
        let edge = Edge(startVertexID: vertex1.id, endVertexID: vertex2.id)
        var graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size,
                                          getVertexPositionByID: {id in
            graph.getVertexByID(id)?.position},
                                          getShowingWeights: { id in
            false },
                                          setShowingWeights: { id, show in},
                                          getOffset: {id in graph.getOffsetByID(id)},
                                          getEdgeControlPoints: { edge in
            graph.getEdgeControlPoints(for: edge)},
                                          getEdgeControlPointOffsets: {edge in
            graph.getEdgeControlPointOffsets(for: edge)},
                                          getWeightPosition: { edge in
            
            graph.getEdgeWeightPositionByID(edge.id)!},
                                          setWeightPosition: { edge, position in
            
            graph.setEdgeWeightPositionByID(id: edge.id, position: position)},
                                          getWeightPositionOffset: { edge in
            graph.getEdgeWeightOffsetByID(edge.id)!
        },
                                          setWeightPositionOffset: { edge, offset in
            graph.setEdgeWeightOffsetByID(id: edge.id, offset: offset)
        })
        EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
    }
}

struct EdgePath: Shape {
    var startVertexPosition: CGPoint
    var endVertexPosition: CGPoint
    var startOffset: CGSize
    var endOffset: CGSize
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
    var controlPoint1Offset: CGSize
    var controlPoint2Offset: CGSize
    var isCurved: Bool
    
    func path(in rect: CGRect) -> Path {
        return makePath(size: CGSize(width: rect.width, height: rect.height))
    }
    
    func makePath(size: CGSize) -> Path {
        let start = startVertexPosition
        let end = endVertexPosition
        let startOffset = startOffset
        let endOffset = endOffset
        let controlPoint1 = controlPoint1
        let controlPoint2 = controlPoint2
        let controlPoint1Offset = controlPoint1Offset
        let controlPoint2Offset = controlPoint2Offset

        let path = Path { path in
            let startPoint = CGPoint(x: start.x * size.width + startOffset.width, y: start.y * size.height + startOffset.height)
            let endPoint = CGPoint(x: end.x * size.width + endOffset.width, y: end.y * size.height + endOffset.height)
            path.move(to: startPoint)
            
            if isCurved {
                let newControlPoint1 = CGPoint(x: controlPoint1.x * size.width + controlPoint1Offset.width,
                                               y: controlPoint1.y * size.height + controlPoint1Offset.height)
                let newControlPoint2 = CGPoint(x: controlPoint2.x * size.width + controlPoint2Offset.width,
                                               y: controlPoint2.y * size.height + controlPoint2Offset.height)
                path.addCurve(to: endPoint, control1: newControlPoint1, control2: newControlPoint2)
            } else {
                path.addLine(to: endPoint)
            }
        }
        return path
    }
    
    func midpoint() -> CGPoint {
        bezierMidpoint(p0: startVertexPosition, p1: controlPoint1, p2: controlPoint2, p3: endVertexPosition)
    }
    
    func midpointGradient() -> CGFloat? {
        bezierTangentGradient(p0: startVertexPosition, p1: controlPoint1, p2: controlPoint2, p3: endVertexPosition)
    }
    
    func perpendicularGradient() -> CGFloat? {
        if let midpointGradient = midpointGradient() {
            if midpointGradient == 0 { return nil }
            return 1 / midpointGradient
        }
        return 0
    }
    
    func pointOnPerpendicular(midpoint: CGPoint, perpendicularGradient: CGFloat, distance: CGFloat) -> (CGPoint, CGPoint) {
        // Normalize the direction vector
        let magnitude = sqrt(1 + perpendicularGradient * perpendicularGradient)
        let dx = distance / magnitude
        let dy = (distance * perpendicularGradient) / magnitude
        
        // Calculate the two points
        let point1 = CGPoint(x: midpoint.x + dx, y: midpoint.y - dy)
        let point2 = CGPoint(x: midpoint.x - dx, y: midpoint.y + dy)
        
        return (point1, point2)
    }
    
    func bezierMidpoint(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let t: CGFloat = 0.5
        let x = pow(1 - t, 3) * p0.x +
        3 * pow(1 - t, 2) * t * p1.x +
        3 * (1 - t) * pow(t, 2) * p2.x +
        pow(t, 3) * p3.x
        
        let y = pow(1 - t, 3) * p0.y +
        3 * pow(1 - t, 2) * t * p1.y +
        3 * (1 - t) * pow(t, 2) * p2.y +
        pow(t, 3) * p3.y
        
        return CGPoint(x: x, y: y)
    }
    
    func bezierTangentGradient(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat? {
        let t: CGFloat = 0.5
        
        // Derivative components
        let dx = 3 * (1 - t) * (1 - t) * (p1.x - p0.x)
        + 6 * (1 - t) * t * (p2.x - p1.x)
        + 3 * t * t * (p3.x - p2.x)
        
        let dy = 3 * (1 - t) * (1 - t) * (p1.y - p0.y)
        + 6 * (1 - t) * t * (p2.y - p1.y)
        + 3 * t * t * (p3.y - p2.y)
        
        // Avoid division by zero
        guard dx != 0 else { return nil }
        
        // Gradient (dy/dx)
        return dy / dx
    }
}
