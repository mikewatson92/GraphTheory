//
//  Edge.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
import simd

struct Edge: Identifiable, Codable, Hashable {
    let id: UUID
    var startVertexID: UUID
    var endVertexID: UUID
    var color: Color = Color.primary
    var weight: Double = 0.0
    var weightPositionParameterT: CGFloat = 0.5
    var weightPositionDistance: CGFloat = 0.025
    var weightPositionOffset: CGSize = .zero
    
    init(startVertexID: UUID, endVertexID: UUID) {
        self.id = UUID()
        self.startVertexID = startVertexID
        self.endVertexID = endVertexID
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
    lazy var edgePath: EdgePath = EdgePath(startVertexPosition: getVertexPositionByID(edge.startVertexID)!, endVertexPosition: getVertexPositionByID(edge.endVertexID)!, startOffset: getOffsetForID(edge.startVertexID)!, endOffset: getOffsetForID(edge.endVertexID)!, controlPoint1: getEdgeControlPoints(edge).0, controlPoint2: getEdgeControlPoints(edge).1, controlPoint1Offset: getEdgeControlPointOffsets(edge).0, controlPoint2Offset: getEdgeControlPointOffsets(edge).1)
    var getShowingWeights: (UUID) -> Bool
    var setShowingWeights: (UUID, Bool) -> Void
    private var removeEdge: (Edge) -> Void
    private var getVertexPositionByID: (UUID) -> CGPoint?
    private var getOffsetForID: (UUID) -> CGSize? // the vertex offset
    var getSelectedEdge: () -> Edge?
    var setSelectedEdge: (UUID?) -> Void
    private var getEdgeControlPoints: (Edge) -> (CGPoint, CGPoint)
    private var setEdgeControlPoint1: (Edge, CGPoint) -> Void
    private var setEdgeControlPoint2: (Edge, CGPoint) -> Void
    private var getEdgeControlPointOffsets: (Edge) -> (CGSize, CGSize)
    private var setEdgeControlPoint1Offset: (Edge, CGSize) -> Void
    private var setEdgeControlPoint2Offset: (Edge, CGSize) -> Void
    private var getWeightPosition: (Edge) -> CGPoint
    private var setWeightPosition: (Edge, CGPoint) -> Void
    private var getWeightPositionOffset: (Edge) -> CGSize
    private var setWeightPositionOffset: (Edge, CGSize) -> Void
    private var getWeight: (Edge) -> Double
    private var setWeight: (Edge, Double) -> Void
    private var getMode: () -> Graph.Mode
    
    init(edge: Edge, size: CGSize,
         removeEdge: @escaping (Edge) -> Void,
         getVertexPositionByID: @escaping (UUID) -> CGPoint?,
         getShowingWeights: @escaping (UUID) -> Bool,
         setShowingWeights: @escaping (UUID, Bool) -> Void,
         getOffset: @escaping (UUID) -> CGSize?,
         getSelectedEdge: @escaping () -> Edge?,
         setSelectedEdge: @escaping (UUID?) -> Void,
         getEdgeControlPoints: @escaping (Edge) -> (CGPoint, CGPoint),
         setEdgeControlPoint1: @escaping (Edge, CGPoint) -> Void,
         setEdgeControlPoint2: @escaping (Edge, CGPoint) -> Void,
         getEdgeControlPointOffsets: @escaping (Edge) -> (CGSize, CGSize),
         setEdgeControlPoint1Offset: @escaping (Edge, CGSize) -> Void,
         setEdgeControlPoint2Offset: @escaping (Edge, CGSize) -> Void,
         getWeightPosition: @escaping (Edge) -> CGPoint,
         setWeightPosition: @escaping (Edge, CGPoint) -> Void,
         getWeightPositionOffset: @escaping (Edge) -> CGSize,
         setWeightPositionOffset: @escaping (Edge, CGSize) -> Void,
         getWeight: @escaping (Edge) -> Double,
         setWeight: @escaping (Edge, Double) -> Void,
         getMode: @escaping () -> Graph.Mode
    ) {
        self.edge = edge
        self.size = size
        self.removeEdge = removeEdge
        self.getShowingWeights = getShowingWeights
        self.setShowingWeights = setShowingWeights
        self.getVertexPositionByID = getVertexPositionByID
        self.getOffsetForID = getOffset
        self.getSelectedEdge = getSelectedEdge
        self.setSelectedEdge = setSelectedEdge
        self.getEdgeControlPoints = getEdgeControlPoints
        self.setEdgeControlPoint1 = setEdgeControlPoint1
        self.setEdgeControlPoint2 = setEdgeControlPoint2
        self.getEdgeControlPointOffsets = getEdgeControlPointOffsets
        self.setEdgeControlPoint1Offset = setEdgeControlPoint1Offset
        self.setEdgeControlPoint2Offset = setEdgeControlPoint2Offset
        self.getWeightPosition = getWeightPosition
        self.setWeightPosition = setWeightPosition
        self.getWeightPositionOffset = getWeightPositionOffset
        self.setWeightPositionOffset = setWeightPositionOffset
        self.getWeight = getWeight
        self.setWeight = setWeight
        self.getMode = getMode
    }
    
    func removeEdgeFromGraph() {
        removeEdge(edge)
    }
    
    func initWeightPosition() -> CGPoint {
        let midPoint = edgePath.midpoint()
        let offset = getEdgeWeightOffset()
        
        if let perpendicularGradient = edgePath.perpendicularGradient() {
            let (pointOnPerpendicular, _) = edgePath.pointOnPerpendicular(point: midPoint, perpendicularGradient: perpendicularGradient, distance: 0.025)
            return CGPoint(
                x: pointOnPerpendicular.x,
                y: pointOnPerpendicular.y
            )
        }
        
        return CGPoint(
            x: midPoint.x * size.width + offset.width,
            y: (midPoint.y + 0.025) * size.height + offset.height
        )
    }
    
    func getID() -> UUID {
        return edge.id
    }
    
    func getGraphMode() -> Graph.Mode {
        getMode()
    }
    
    func getColor() -> Color {
        return edge.color
    }
    
    func getEdgeWeight() -> Double {
        getWeight(edge)
    }
    
    func setEdgeWeight(_ weight: Double) {
        setWeight(edge, weight)
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
    
    func setControlPoint1(_ point: CGPoint) {
        setEdgeControlPoint1(edge, point)
    }
    
    func setControlPoint2(_ point: CGPoint) {
        setEdgeControlPoint2(edge, point)
    }
    
    func setControlPoint1Offset(_ size: CGSize) {
        setEdgeControlPoint1Offset(edge, size)
    }
    
    func setControlPoint2Offset(_ size: CGSize) {
        setEdgeControlPoint2Offset(edge, size)
    }
}

struct EdgeView: View {
    @ObservedObject var edgeViewModel: EdgeViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var edittingWeight = false
    @State private var tempWeightPosition: CGPoint {
        willSet {
            edgeViewModel.setEdgeWeightPosition(position: newValue)
        }
    }
    @State private var tempWeightPositionOffset: CGSize = .zero {
        willSet {
            edgeViewModel.setEdgeWeightOffset(newValue)
        }
    }
    var size: CGSize
    
    init(edgeViewModel: EdgeViewModel, size: CGSize) {
        self.edgeViewModel = edgeViewModel
        self.tempWeightPosition = edgeViewModel.getEdgeWeightPosition() ?? edgeViewModel.initWeightPosition()
        self.size = size
    }
    
    var body: some View {
            edgeViewModel.edgePath.makePath(size: size)
            #if os(macOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 5)
            #elseif os(iOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 15)
            #endif
                .onTapGesture(count: 2) {
                    if edgeViewModel.getGraphMode() == .edit {
                        if edgeViewModel.getSelectedEdge()?.id == edgeViewModel.getID() {
                            edgeViewModel.setSelectedEdge(nil)
                        }
                        edgeViewModel.removeEdgeFromGraph()
                    }
                }
                .onTapGesture(count: 1) {
                    if edgeViewModel.getSelectedEdge()?.id == edgeViewModel.getID() {
                        edgeViewModel.setSelectedEdge(nil)
                    } else {
                        edgeViewModel.setSelectedEdge(edgeViewModel.getID())
                    }
                }
        
        // Control points for selected edge
        if edgeViewModel.getGraphMode() == .edit {
            if edgeViewModel.getSelectedEdge()?.id == edgeViewModel.getID() {
                let (controlPoint1, controlPoint2) = edgeViewModel.getControlPoints()
                let (controlPoint1Offset, controlPoint2Offset) = edgeViewModel.getControlPointOffsets()
                let adjustedControlPoint1 = CGPoint(x: controlPoint1.x * size.width + controlPoint1Offset.width,
                                                    y: controlPoint1.y * size.height + controlPoint1Offset.height)
                let adjustedControlPoint2 = CGPoint(x: controlPoint2.x * size.width + controlPoint2Offset.width,
                                                    y: controlPoint2.y * size.height + controlPoint2Offset.height)
                Group {
                    Circle()
                        .position(adjustedControlPoint1)
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.red)
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .position(adjustedControlPoint1)
                        .frame(width: 10, height: 10)
                    #if os(iOS)
                    Color.clear
                        .contentShape(Circle())
                        .position(adjustedControlPoint1)
                        .frame(width: 50, height: 50)
                    #endif
                }
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        edgeViewModel.setControlPoint1Offset(drag.translation)
                    }).onEnded { _ in
                        let (point, _) = edgeViewModel.getControlPoints()
                        let (offset, _) = edgeViewModel.getControlPointOffsets()
                        let newX = point.x + offset.width / size.width
                        let newY = point.y + offset.height / size.height
                        let newPoint = CGPoint(x: newX, y: newY)
                        edgeViewModel.setControlPoint1(newPoint)
                        edgeViewModel.setControlPoint1Offset(.zero)
                    })
                
                Group {
                    Circle()
                        .position(adjustedControlPoint2)
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.red)
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .position(adjustedControlPoint2)
                        .frame(width: 10, height: 10)
                    #if os(iOS)
                    Color.clear
                        .contentShape(Circle())
                        .position(adjustedControlPoint2)
                        .frame(width: 50, height: 50)
                    #endif
                }
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        edgeViewModel.setControlPoint2Offset(drag.translation)
                    }).onEnded { _ in
                        let (_, point) = edgeViewModel.getControlPoints()
                        let (_, offset) = edgeViewModel.getControlPointOffsets()
                        let newX = point.x + offset.width / size.width
                        let newY = point.y + offset.height / size.height
                        let newPoint = CGPoint(x: newX, y: newY)
                        edgeViewModel.setControlPoint2(newPoint)
                        edgeViewModel.setControlPoint2Offset(.zero)
                    })
            }
        }
        
        
        if edgeViewModel.getShowingWeights(edgeViewModel.getID()) {
            // TextField for editing the weight
            
            if edittingWeight {
                ZStack {
                    TextField("Enter weight", value: Binding(get: { edgeViewModel.getEdgeWeight() }, set: { newValue in edgeViewModel.setEdgeWeight(newValue)}), format: .number)
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
                        }
                    #if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
                    #endif
                }
                .position(CGPoint(x: (edgeViewModel.getEdgeWeightPosition()!.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.getEdgeWeightPosition()!.y) * size.height + tempWeightPositionOffset.height))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                tempWeightPositionOffset = drag.translation
                            }
                            .onEnded { _ in
                                edgeViewModel.setEdgeWeightPosition(position: CGPoint(x: edgeViewModel.getEdgeWeightPosition()!.x + tempWeightPositionOffset.width / size.width, y: edgeViewModel.getEdgeWeightPosition()!.y + tempWeightPositionOffset.height / size.height))
                                tempWeightPositionOffset = .zero
                            })
            } else {
                ZStack {
                    Text("\(edgeViewModel.getEdgeWeight().formatted())")
                    #if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
                    #endif

                }
                .position(CGPoint(x: (edgeViewModel.getEdgeWeightPosition()!.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.getEdgeWeightPosition()!.y) * size.height + tempWeightPositionOffset.height))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                tempWeightPositionOffset = drag.translation
                            }
                            .onEnded { _ in
                                edgeViewModel.setEdgeWeightPosition(position: CGPoint(x: edgeViewModel.getEdgeWeightPosition()!.x + tempWeightPositionOffset.width / size.width, y: edgeViewModel.getEdgeWeightPosition()!.y + tempWeightPositionOffset.height / size.height))
                                tempWeightPositionOffset = .zero
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
        var graphViewModel = GraphViewModel(graph: graph)
        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size,
                                          removeEdge: { edge in
            graph.removeEdge(edge)
        },
                                          getVertexPositionByID: {id in
            graph.getVertexByID(id)?.position},
                                          
                                          getShowingWeights: { id in
            false },
                                          setShowingWeights: { id, show in},
                                          getOffset: {id in graph.getOffsetByID(id)},
                                          getSelectedEdge: { graphViewModel.selectedEdge },
                                          setSelectedEdge: { id in
            if id != nil {
                graphViewModel.selectedEdge = graphViewModel.getEdges().first(where: {$0.id == id})
            } else {
                graphViewModel.selectedEdge = nil
            }
        },
                                          getEdgeControlPoints: { edge in
            graph.getEdgeControlPoints(for: edge)},
                                          setEdgeControlPoint1: { edge, point in
            graph.setControlPoint1(for: edge, at: point)
        },
                                          setEdgeControlPoint2: { edge, point in
            graph.setControlPoint2(for: edge, at: point)
        },
                                          getEdgeControlPointOffsets: {edge in
            graph.getEdgeControlPointOffsets(for: edge)},
                                          setEdgeControlPoint1Offset: { edge, size in
            graph.setControlPoint1Offset(for: edge, translation: size)
        },
                                          setEdgeControlPoint2Offset: { edge, size in
            graph.setControlPoint2Offset(for: edge, translation: size)
        },
                                          getWeightPosition: { edge in
            
            graph.getEdgeWeightPositionByID(edge.id)!},
                                          setWeightPosition: { edge, position in
            
            graph.setEdgeWeightPositionByID(id: edge.id, position: position)},
                                          getWeightPositionOffset: { edge in
            graph.getEdgeWeightOffsetByID(edge.id)!
        },
                                          setWeightPositionOffset: { edge, offset in
            graph.setEdgeWeightOffsetByID(id: edge.id, offset: offset)
        },
                                          getWeight: { edge in
            graph.edges[edge.id]!.weight
        }, setWeight: { edge, weight in
            graph.edges[edge.id]?.weight = weight
        }, getMode: { graph.mode })
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
            
            let newControlPoint1 = CGPoint(x: controlPoint1.x * size.width + controlPoint1Offset.width,
                                           y: controlPoint1.y * size.height + controlPoint1Offset.height)
            let newControlPoint2 = CGPoint(x: controlPoint2.x * size.width + controlPoint2Offset.width,
                                           y: controlPoint2.y * size.height + controlPoint2Offset.height)
            path.addCurve(to: endPoint, control1: newControlPoint1, control2: newControlPoint2)
        }
        return path
    }
    
    // Helper function to calculate the squared distance between two points
    func squaredDistance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return dx * dx + dy * dy
    }

    // Function to calculate the squared distance between a point and a Bézier point
    func distanceSquared(t: CGFloat, externalPoint: CGPoint, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let bezierPoint = pointOnBezierCurve(t: t, p0: p0, p1: p1, p2: p2, p3: p3)
        return squaredDistance(bezierPoint, externalPoint)
    }

    // Find the parameter t for the closest point on the Bézier curve using numerical optimization
    func closestParameterToPoint(externalPoint: CGPoint, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let tolerance: CGFloat = 1e-6
        var lowerBound: CGFloat = 0.0
        var upperBound: CGFloat = 1.0
        var mid: CGFloat

        while upperBound - lowerBound > tolerance {
            let t1 = lowerBound + (upperBound - lowerBound) / 3
            let t2 = upperBound - (upperBound - lowerBound) / 3

            let d1 = distanceSquared(t: t1, externalPoint: externalPoint, p0: p0, p1: p1, p2: p2, p3: p3)
            let d2 = distanceSquared(t: t2, externalPoint: externalPoint, p0: p0, p1: p1, p2: p2, p3: p3)

            if d1 < d2 {
                upperBound = t2
            } else {
                lowerBound = t1
            }
        }

        mid = (lowerBound + upperBound) / 2
        return mid
    }

    // Calculate the closest point on the Bézier curve and the distance to the external point
    func closestParameterAndDistance(externalPoint: CGPoint, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> (CGFloat, CGFloat) {
        // Find the parameter t for the closest point
        let tClosest = closestParameterToPoint(externalPoint: externalPoint, p0: p0, p1: p1, p2: p2, p3: p3)
        
        // Compute the closest point on the curve using tClosest
        let closestPoint = pointOnBezierCurve(t: tClosest, p0: p0, p1: p1, p2: p2, p3: p3)
        
        // Compute the distance from the external point to the closest point on the curve
        let distance = sqrt(squaredDistance(closestPoint, externalPoint))
        
        // Return the parameter t and the distance
        return (tClosest, distance)
    }
    
    func midpoint() -> CGPoint {
        bezierMidpoint(p0: startVertexPosition, p1: controlPoint1, p2: controlPoint2, p3: endVertexPosition)
    }
    
    func midpointGradient() -> CGFloat? {
        bezierTangentGradient(t: 0.5, p0: startVertexPosition, p1: controlPoint1, p2: controlPoint2, p3: endVertexPosition)
    }
    
    func perpendicularGradient() -> CGFloat? {
        if let midpointGradient = midpointGradient() {
            if midpointGradient == 0 { return nil }
            return 1 / midpointGradient
        }
        return 0
    }
    
    func pointOnPerpendicular(point: CGPoint, perpendicularGradient: CGFloat, distance: CGFloat) -> (CGPoint, CGPoint) {
        // Normalize the direction vector
        let magnitude = sqrt(1 + perpendicularGradient * perpendicularGradient)
        let dx = distance / magnitude
        let dy = (distance * perpendicularGradient) / magnitude
        
        // Calculate the two points
        let point1 = CGPoint(x: point.x + dx, y: point.y - dy)
        let point2 = CGPoint(x: point.x - dx, y: point.y + dy)
        
        return (point1, point2)
    }
    
    func pointOnBezierCurve(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
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
    
    func bezierMidpoint(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        pointOnBezierCurve(t: 0.5, p0: p0, p1: p1, p2: p2, p3: p3)
    }
    
    func bezierTangentGradient(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat? {
        
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
