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
    var weightPositionDistance: CGFloat = 0.05
    var weightPositionOffset: CGSize = .zero
    var sign = 1 // Used for deciding which side of the edge the weight will be display on
    var directed = Directed.none
    var strokeStyle = StrokeStyle.normal
    var controlPoint1 = CGPoint.zero
    var controlPoint2 = CGPoint.zero
    var controlPoint1Offset = CGSize.zero
    var controlPoint2Offset = CGSize.zero
    var forwardArrowParameter = CGFloat(0.75)
    var reverseArrowParameter = CGFloat(0.25)
    
    init(startVertexID: UUID, endVertexID: UUID) {
        self.id = UUID()
        self.startVertexID = startVertexID
        self.endVertexID = endVertexID
    }
    
    enum Directed: String, Codable, CaseIterable, Identifiable {
        case none = "Undirected"
        case forward = "Forward Directed"
        case reverse = "Reverse Directed"
        case bidirectional = "Bidirectional"
        
        var id: String { self.rawValue }
    }
    
    enum StrokeStyle: Codable {
        case normal
        case dashed
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
    @Published private(set) var edge: Edge
    @Published var graphViewModel: GraphViewModel
    var size: CGSize
    var id: UUID {
        get {
            edge.id
        }
    }
    var sign: Int {
        edge.sign
    }
    var weight: Double {
        get {
            edge.weight
        } set {
            edge.weight = newValue
            graphViewModel.setWeight(edge: edge, weight: newValue)
        }
    }
    var color: Color {
        get {
            edge.color
        } set {
            edge.color = newValue
            graphViewModel.setColorForEdge(edge: edge, color: newValue)
        }
    }
    var weightPositionParameterT: CGFloat {
        get {
            edge.weightPositionParameterT
        } set {
            edge.weightPositionParameterT = newValue
        }
    }
    var weightPositionDistance: CGFloat {
        get {
            edge.weightPositionDistance
        } set {
            edge.weightPositionDistance = newValue
        }
    }
    var weightPosition: CGPoint {
        get {
            let pointOnBezierCurve = edgePath.pointOnBezierCurve(t: weightPositionParameterT)
            if let perpendicularGradient = edgePath.perpendicularGradient(t: weightPositionParameterT) {
                if sign == 1 {
                    return edgePath.pointOnPerpendicular(point: pointOnBezierCurve, perpendicularGradient: perpendicularGradient, distance: weightPositionDistance).0
                } else {
                    return edgePath.pointOnPerpendicular(point: pointOnBezierCurve, perpendicularGradient: perpendicularGradient, distance: weightPositionDistance).1
                }
            } else { // If the gradient is undefined
                if sign == 1 {
                    let pointOnCurve = edgePath.pointOnBezierCurve(t: weightPositionParameterT)
                    return CGPoint(x: pointOnCurve.x, y: pointOnCurve.y + weightPositionDistance)
                } else {
                    let pointOnCurve = edgePath.pointOnBezierCurve(t: weightPositionParameterT)
                    return CGPoint(x: pointOnCurve.x, y: pointOnCurve.y - weightPositionDistance)
                }
            }
        } set {
            let (t, distance) = edgePath.closestParameterAndDistance(externalPoint: newValue)
            weightPositionParameterT = t
            weightPositionDistance = distance
            graphViewModel.setEdgeWeightPositionParameterT(id: edge.id, t: t)
            graphViewModel.setEdgeWeightPositionDistance(id: edge.id, distance: distance)
        }
    }
    var strokeStyle: Edge.StrokeStyle {
        get {
            edge.strokeStyle
        }
    }
    var forwardArrowParameter: CGFloat {
        get {
            edge.forwardArrowParameter
        } set {
            edge.forwardArrowParameter = newValue
            graphViewModel.setEdgeForwardArrowParameter(id: edge.id, parameter: newValue)
        }
    }
    var reverseArrowParameter: CGFloat {
        get {
            edge.reverseArrowParameter
        } set {
            edge.reverseArrowParameter = newValue
            graphViewModel.setEdgeReverseArrowParameter(id: edge.id, parameter: newValue)
        }
    }
    
    var edgePath: EdgePath {
        EdgePath(startVertexPosition: graphViewModel.graph.vertices[edge.startVertexID]?.position ?? CGPoint.zero, endVertexPosition: graphViewModel.graph.vertices[edge.endVertexID]?.position ?? CGPoint.zero, startOffset: graphViewModel.graph.vertices[edge.startVertexID]?.offset ?? CGSize.zero, endOffset: graphViewModel.graph.vertices[edge.endVertexID]?.offset ?? CGSize.zero, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1, size: size)
    }
    var directed: Edge.Directed {
        get {
            edge.directed
        } set {
            edge.directed = newValue
        }
    }
    
    init(edge: Edge, size: CGSize, graphViewModel: GraphViewModel) {
        self.graphViewModel = graphViewModel
        self.edge = edge
        self.size = size
    }
    
    func removeEdgeFromGraph() {
        graphViewModel.removeEdge(edge)
    }
    
    func setEdgeWeight(_ weight: Double) {
        graphViewModel.setWeight(edge: edge, weight: weight)
    }
    
    func getStartVertexPosition() -> CGPoint? {
        graphViewModel.graph.vertices[edge.startVertexID]?.position
    }
    
    func getEndVertexPosition() -> CGPoint? {
        graphViewModel.graph.vertices[edge.endVertexID]?.position
    }
    
    func getStartOffset() -> CGSize? {
        graphViewModel.graph.vertices[edge.startVertexID]?.offset
    }
    
    func getEndOffset() -> CGSize? {
        graphViewModel.graph.vertices[edge.endVertexID]?.offset
    }
    
    func getControlPoints() -> (CGPoint, CGPoint) {
        graphViewModel.getControlPoints(for: edge)
    }
    
    func getControlPointOffsets() -> (CGSize, CGSize) {
        graphViewModel.getControlPointOffsets(for: edge)
    }
    
    func getEdgeWeightOffset() -> CGSize {
        graphViewModel.getWeightPositionOffset(for: edge)!
    }
    
    func setEdgeWeightOffset(_ size: CGSize) {
        graphViewModel.setWeightPositionOffset(for: edge, offset: size)
    }
    
    func setControlPoint1(_ point: CGPoint) {
        graphViewModel.setControlPoint1(for: edge, at: point)
    }
    
    func setControlPoint2(_ point: CGPoint) {
        graphViewModel.setControlPoint2(for: edge, at: point)
    }
    
    func setControlPoint1Offset(_ size: CGSize) {
        graphViewModel.setControlPoint1Offset(for: edge, translation: size)
    }
    
    func setControlPoint2Offset(_ size: CGSize) {
        graphViewModel.setControlPoint2Offset(for: edge, translation: size)
    }
}

struct EdgeView: View {
    @ObservedObject var edgeViewModel: EdgeViewModel
    @ObservedObject var graphViewModel: GraphViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var edittingWeight = false
    @State private var forwardArrowOffset = CGSize.zero
    @State private var reverseArrowOffset = CGSize.zero
    let onWeightChange: () -> Void
    var forwardArrow = Arrow()
    var reverseArrow = Arrow()
    let edgeColors: [Color] = [Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.9, green: 0, blue: 0.9, alpha: 1))]
    @State private var tempWeightPosition: CGPoint {
        willSet {
            let (t, distance) = edgeViewModel.edgePath.closestParameterAndDistance(externalPoint: newValue)
            edgeViewModel.weightPositionParameterT = t
            edgeViewModel.weightPositionDistance = distance
            graphViewModel.setEdgeWeightPositionParameterT(id: edgeViewModel.id, t: t)
            graphViewModel.setEdgeWeightPositionDistance(id: edgeViewModel.id, distance: distance)
        }
    }
    @State private var tempWeightPositionOffset: CGSize = .zero {
        willSet {
            edgeViewModel.setEdgeWeightOffset(newValue)
        }
    }
    var size: CGSize
    var forwardAngle: CGFloat {
        var angle = CGFloat(0)
        let arrowParameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: forwardArrowPoint.x + forwardArrowOffset.width / size.width, y: forwardArrowPoint.y + forwardArrowOffset.height / size.height))
        let arrowPosition = edgeViewModel.edgePath.pointOnBezierCurve(t: arrowParameter)
        let nextArrowPosition = edgeViewModel.edgePath.pointOnBezierCurve(t: min(arrowParameter + 1e-10, 1))
        let dx = nextArrowPosition.x - arrowPosition.x
        let dy = nextArrowPosition.y - arrowPosition.y
        if let gradient = edgeViewModel.edgePath.bezierTangentGradient(t: arrowParameter) {
            if dx > 0 {
                angle = atan(gradient)
            } else if dx < 0 {
                angle = CGFloat.pi + atan(gradient)
            } else {
                angle = CGFloat.pi / 2 * (dy > 0 ? 1 : -1)
            }
        } else { // If the gradient is undefined
            if dy > 0 {
                angle = CGFloat.pi / 2
            } else {
                angle = -CGFloat.pi / 2
            }
        }
        return angle
    }
    var reverseAngle: CGFloat {
        var angle = CGFloat(0)
        let arrowParameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: reverseArrowPoint.x + reverseArrowOffset.width / size.width, y: reverseArrowPoint.y + reverseArrowOffset.height / size.height))
        let arrowPosition = edgeViewModel.edgePath.pointOnBezierCurve(t: arrowParameter)
        let nextArrowPosition = edgeViewModel.edgePath.pointOnBezierCurve(t: max(arrowParameter - 1e-10, 0))
        let dx = nextArrowPosition.x - arrowPosition.x
        let dy = nextArrowPosition.y - arrowPosition.y
        if let gradient = edgeViewModel.edgePath.bezierTangentGradient(t: arrowParameter) {
            if dx > 0 {
                angle = atan(gradient)
            } else if dx < 0 {
                angle = CGFloat.pi + atan(gradient)
            } else {
                angle = CGFloat.pi / 2 * (dy > 0 ? 1 : -1)
            }
        } else { // If the gradient is undefined
            if dy > 0 {
                angle = CGFloat.pi / 2
            } else {
                angle = -CGFloat.pi / 2
            }
        }
        return angle
    }
    var forwardArrowPoint: CGPoint {
        get {
            return edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.forwardArrowParameter)
        }
    }
    var reverseArrowPoint: CGPoint {
        get {
            return edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.reverseArrowParameter)
        }
    }
    
    init(edgeViewModel: EdgeViewModel, onWeightChange: @escaping () -> Void = {}) {
        self.edgeViewModel = edgeViewModel
        self.graphViewModel = edgeViewModel.graphViewModel
        self.tempWeightPosition = edgeViewModel.weightPosition
        self.size = edgeViewModel.size
        self.onWeightChange = onWeightChange
    }
    
    func forwardArrowPosition() -> CGPoint {
        let newParameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: forwardArrowPoint.x + forwardArrowOffset.width / size.width, y: forwardArrowPoint.y + forwardArrowOffset.height / size.height))
        let pointOnCurve = edgeViewModel.edgePath.pointOnBezierCurve(t: newParameter)
        return pointOnCurve
    }
    
    func reverseArrowPosition() -> CGPoint {
        let newParameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: reverseArrowPoint.x + reverseArrowOffset.width / size.width, y: reverseArrowPoint.y + reverseArrowOffset.height / size.height))
        let pointOnCurve = edgeViewModel.edgePath.pointOnBezierCurve(t: newParameter)
        return pointOnCurve
    }
    
    func handleSingleClickGesture() {
        graphViewModel.selectedVertex = nil
        switch graphViewModel.mode {
            // Allows the user to select an edge to display the control points
        case .edit:
            if graphViewModel.selectedEdge?.id != edgeViewModel.id {
                graphViewModel.selectedEdge = edgeViewModel.edge
                graphViewModel.edgeDirection = graphViewModel.selectedEdge!.directed
                
            } else {
                graphViewModel.selectedEdge = nil
            }
            // Change the colors of the edges to simulate a path through the graph
        case .explore:
            graphViewModel.timesEdgeSelected[edgeViewModel.id]! += 1
            let timesSelected = graphViewModel.timesEdgeSelected[edgeViewModel.id]!
            graphViewModel.setColorForEdge(edge: edgeViewModel.edge, color: edgeColors[(timesSelected - 1) % edgeColors.count])
        }
    }
    
    func handleDoubleClickGesture() {
        if graphViewModel.mode == .edit {
            graphViewModel.selectedEdge = nil
            graphViewModel.removeEdge(edgeViewModel.edge)
        }
    }
    
    func handleLongPressGesture() {
        if edgeViewModel.edge.startVertexID != edgeViewModel.edge.endVertexID {
            if graphViewModel.mode == .edit {
                let (controlPoint1, controlPoint2) = graphViewModel.initControlPointsFor(edge: edgeViewModel.edge)
                graphViewModel.setControlPoint1(for: edgeViewModel.edge, at: controlPoint1)
                graphViewModel.setControlPoint2(for: edgeViewModel.edge, at: controlPoint2)
            } else if graphViewModel.mode == .explore {
                graphViewModel.timesEdgeSelected[edgeViewModel.id] = 0
                graphViewModel.setColorForEdge(edge: edgeViewModel.edge, color: .white)
            }
        }
    }
    
    var body: some View {
        if edgeViewModel.strokeStyle == .normal {
            edgeViewModel.edgePath.makePath()
#if os(macOS)
                .stroke(edgeViewModel.color, lineWidth: 5)
#elseif os(iOS)
                .stroke(edgeViewModel.color, lineWidth: 15)
#endif
                .shadow(color: edittingWeight ? .teal : .clear, radius: 10)
                .onTapGesture(count: 2) {
                    handleDoubleClickGesture()
                }
                .onTapGesture(count: 1) {
                    handleSingleClickGesture()
                }
                .onLongPressGesture(minimumDuration: 1) {
                    handleLongPressGesture()
                }

        } else if edgeViewModel.strokeStyle == .dashed {
            edgeViewModel.edgePath.makePath()
    #if os(macOS)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [5, 10]))
                .foregroundStyle(edgeViewModel.color)
    #elseif os(iOS)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [5, 10]))
                .foregroundStyle(edgeViewModel.color)
    #endif
                .shadow(color: edittingWeight ? .teal : .clear, radius: 10)
                .onTapGesture(count: 2) {
                    handleDoubleClickGesture()
                }
                .onTapGesture(count: 1) {
                    handleSingleClickGesture()
                }
                .onLongPressGesture(minimumDuration: 1) {
                    handleLongPressGesture()
                }
        }
        
        if edgeViewModel.directed == .forward || edgeViewModel.directed == .bidirectional {
            forwardArrow
#if os(macOS)
                .stroke(edgeViewModel.color, lineWidth: 4)
#elseif os(iOS)
                .stroke(edgeViewModel.color, lineWidth: 15)
#endif
                .rotationEffect(Angle(radians: forwardAngle), anchor: UnitPoint(x: 1, y: 0.5))
                .frame(width: Arrow.dimension, height: Arrow.dimension)
                .position(CGPoint(x: forwardArrowPosition().x * size.width - Arrow.dimension / 2,
                                  y: forwardArrowPosition().y * size.height))
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        forwardArrowOffset = drag.translation
                    }).onEnded { _ in
                        let parameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: forwardArrowPosition())
                        edgeViewModel.forwardArrowParameter = parameter
                        forwardArrowOffset = .zero
                    })
        }
        
        if edgeViewModel.directed == .reverse || edgeViewModel.directed == .bidirectional {
            reverseArrow
#if os(macOS)
                .stroke(edgeViewModel.color, lineWidth: 4)
#elseif os(iOS)
                .stroke(edgeViewModel.color, lineWidth: 15)
#endif
                .rotationEffect(Angle(radians: reverseAngle), anchor: UnitPoint(x: 1, y: 0.5))
                .frame(width: Arrow.dimension, height: Arrow.dimension)
                .position(CGPoint(x: reverseArrowPosition().x * size.width - Arrow.dimension / 2,
                                  y: reverseArrowPosition().y * size.height))
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        reverseArrowOffset = drag.translation
                    }).onEnded { _ in
                        let parameter = edgeViewModel.edgePath.closestParameterToPoint(externalPoint: reverseArrowPosition())
                        edgeViewModel.reverseArrowParameter = parameter
                        reverseArrowOffset = .zero
                    })
        }
        
        // Control points for selected edge
        if edgeViewModel.graphViewModel.mode == .edit {
            if graphViewModel.selectedEdge?.id == edgeViewModel.id {
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
        
        
        if  graphViewModel.showWeights {
            // TextField for editing the weight
            
            if edittingWeight {
                ZStack {
                    TextField("Enter weight", value: Binding(get: { edgeViewModel.weight }, set: { newValue in edgeViewModel.weight = newValue }), format: .number)
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
                            onWeightChange()
                        }
#if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
#endif
                }
                .position(CGPoint(x: (edgeViewModel.weightPosition.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.weightPosition.y) * size.height + tempWeightPositionOffset.height))
                .gesture(
                    DragGesture()
                        .onChanged { drag in
                            tempWeightPositionOffset = drag.translation
                        }
                        .onEnded { _ in
                            edgeViewModel.weightPosition = CGPoint(x: edgeViewModel.weightPosition.x + tempWeightPositionOffset.width / size.width, y: edgeViewModel.weightPosition.y + tempWeightPositionOffset.height / size.height)
                            tempWeightPositionOffset = .zero
                        })
            } else {
                Group {
                    Text(edgeViewModel.weight.formatted())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(graphViewModel.selectedEdge?.id == edgeViewModel.id ? Color.teal : Color.primary)
                        .shadow(color: graphViewModel.selectedEdge?.id == edgeViewModel.id ? .teal : .clear, radius: 10)
#if os(iOS)
                    Color.clear
                        .opacity(0.25)
                        .contentShape(Rectangle())
                        .frame(width: 50, height: 50)
#endif
                    
                }
                .position(CGPoint(x: (edgeViewModel.weightPosition.x) * size.width + tempWeightPositionOffset.width, y: (edgeViewModel.weightPosition.y) * size.height + tempWeightPositionOffset.height))
                .gesture(
                    DragGesture()
                        .onChanged { drag in
                            tempWeightPositionOffset = drag.translation
                        }
                        .onEnded { _ in
                            edgeViewModel.weightPosition = CGPoint(x: edgeViewModel.weightPosition.x + tempWeightPositionOffset.width / size.width, y: edgeViewModel.weightPosition.y + tempWeightPositionOffset.height / size.height)
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
        let graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
        let graphViewModel = GraphViewModel(graph: graph)
        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
        EdgeView(edgeViewModel: edgeViewModel)
    }
}

struct EdgePath {
    var startVertexPosition: CGPoint
    var endVertexPosition: CGPoint
    var startOffset: CGSize
    var endOffset: CGSize
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
    var controlPoint1Offset: CGSize
    var controlPoint2Offset: CGSize
    var size: CGSize
    
    func makePath() -> Path {
        let path = Path { path in
            let startPoint = CGPoint(x: startVertexPosition.x * size.width + startOffset.width, y: startVertexPosition.y * size.height + startOffset.height)
            let endPoint = CGPoint(x: endVertexPosition.x * size.width + endOffset.width, y: endVertexPosition.y * size.height + endOffset.height)
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
    func distanceSquared(t: CGFloat, externalPoint: CGPoint) -> CGFloat {
        let bezierPoint = pointOnBezierCurve(t: t)
        return squaredDistance(bezierPoint, externalPoint)
    }
    
    // Find the parameter t for the closest point on the Bézier curve using numerical optimization
    func closestParameterToPoint(externalPoint: CGPoint) -> CGFloat {
        let tolerance: CGFloat = 1e-6
        var lowerBound: CGFloat = 0.0
        var upperBound: CGFloat = 1.0
        var mid: CGFloat
        
        while upperBound - lowerBound > tolerance {
            let t1 = lowerBound + (upperBound - lowerBound) / 3
            let t2 = upperBound - (upperBound - lowerBound) / 3
            
            let d1 = distanceSquared(t: t1, externalPoint: externalPoint)
            let d2 = distanceSquared(t: t2, externalPoint: externalPoint)
            
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
    func closestParameterAndDistance(externalPoint: CGPoint) -> (CGFloat, CGFloat) {
        // Find the parameter t for the closest point
        let tClosest = closestParameterToPoint(externalPoint: externalPoint)
        
        // Compute the closest point on the curve using tClosest
        let closestPoint = pointOnBezierCurve(t: tClosest)
        
        // Compute the distance from the external point to the closest point on the curve
        var distance = sqrt(squaredDistance(closestPoint, externalPoint))
        if let _ = perpendicularGradient(t: tClosest) {
            distance *= externalPoint.x >= closestPoint.x ? 1 : -1
        } else {
            distance *= externalPoint.y >= closestPoint.y ? 1 : -1
        }
        
        // Return the parameter t and the distance
        return (tClosest, distance)
    }
    
    func perpendicularGradient(t: CGFloat) -> CGFloat? {
        if let gradient = bezierTangentGradient(t: t) {
            if gradient == 0 { return nil }
            return 1 / gradient
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
    
    func pointOnBezierCurve(t: CGFloat) -> CGPoint {
        let p0 = CGPoint(x: startVertexPosition.x + startOffset.width / size.width, y: startVertexPosition.y + startOffset.height / size.height)
        let p1 = CGPoint(x: controlPoint1.x + controlPoint1Offset.width / size.width, y: controlPoint1.y + controlPoint1Offset.height / size.height)
        let p2 = CGPoint(x: controlPoint2.x + controlPoint2Offset.width / size.width, y: controlPoint2.y + controlPoint2Offset.height / size.height)
        let p3 = CGPoint(x: endVertexPosition.x + endOffset.width / size.width, y: endVertexPosition.y + endOffset.height / size.height)
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
    
    func bezierTangentGradient(t: CGFloat) -> CGFloat? {
        let p0 = CGPoint(x: startVertexPosition.x + startOffset.width / size.width, y: startVertexPosition.y + startOffset.height / size.height)
        let p1 = CGPoint(x: controlPoint1.x + controlPoint1Offset.width / size.width, y: controlPoint1.y + controlPoint1Offset.height / size.height)
        let p2 = CGPoint(x: controlPoint2.x + controlPoint2Offset.width / size.width, y: controlPoint2.y + controlPoint2Offset.height / size.height)
        let p3 = CGPoint(x: endVertexPosition.x + endOffset.width / size.width, y: endVertexPosition.y + endOffset.height / size.height)
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

struct Arrow: Shape {
    static let dimension = CGFloat(40)
    
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            let start = CGPoint(x: rect.midX, y: rect.minY)
            let point = CGPoint(x: rect.maxX, y: rect.midY)
            let end = CGPoint(x: rect.midX, y: rect.maxY)
            path.move(to: start)
            path.addLine(to: point)
            path.addLine(to: end)
        }
        return path
    }
}
