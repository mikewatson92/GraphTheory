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
    static let DEFAULT_WEIGHT_DISTANCE = 0.05
    var weightPositionDistance: CGFloat = DEFAULT_WEIGHT_DISTANCE
    var weightPositionOffset: CGSize = .zero
    var sign = 1 // Used for deciding which side of the edge the weight will be display on
    var directed = Directed.none
    
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
    @Published var graphViewModel: GraphViewModel
    var size: CGSize
    lazy var forwardArrow = Arrow(angle: forwardAngle)
    lazy var reverseArrow = Arrow(angle: reverseAngle)
    var forwardAngle: CGFloat {
        var angle = CGFloat(0)
        if let startPosition = getStartVertexPosition(),
        let startOffset = getStartOffset(),
        let endPosition = getEndVertexPosition(),
        let endOffset = getEndOffset(),
        let arrowParameter = graphViewModel.getEdgeForwardArrowParameter(edge: edge) {
            let p0X = startPosition.x + startOffset.width / size.width
            let p0Y = startPosition.y + startOffset.height / size.height
            let p1X = getControlPoints().0.x + getControlPointOffsets().0.width / size.width
            let p1Y = getControlPoints().0.y + getControlPointOffsets().0.height / size.height
            let p2X = getControlPoints().1.x + getControlPointOffsets().1.width / size.width
            let p2Y = getControlPoints().1.y + getControlPointOffsets().1.height / size.height
            let p3X = endPosition.x + endOffset.width / size.width
            let p3Y = endPosition.y + endOffset.height / size.height
            let arrowPosition = edgePath.pointOnBezierCurve(t: arrowParameter, p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            let nextArrowPosition = edgePath.pointOnBezierCurve(t: min(arrowParameter + 0.01, 1), p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            let dx = nextArrowPosition.x - arrowPosition.x
            let dy = nextArrowPosition.y - arrowPosition.y
            if let gradient = edgePath.bezierTangentGradient(t: graphViewModel.getGraph().edgeForwardArrowParameters[edge.id] ?? 0.5, p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y)) {
                if dx > 0 {
                    angle = atan(gradient)
                } else if dx < 0 {
                    angle = CGFloat.pi + atan(gradient)
                } else {
                    angle = CGFloat.pi / 2 * (dy >= 0 ? 1 : -1)
                }
            } else { // If the gradient is undefined
                if dy > 0 {
                    angle = -CGFloat.pi / 2
                } else {
                    angle = CGFloat.pi / 2
                }
            }
        }

        return angle
    }
    var reverseAngle: CGFloat {
        var angle = CGFloat(0)
        if let startPosition = getStartVertexPosition(),
        let startOffset = getStartOffset(),
        let endPosition = getEndVertexPosition(),
        let endOffset = getEndOffset(),
        let arrowParameter = graphViewModel.getEdgeReverseArrowParameter(edge: edge) {
            let p0X = startPosition.x + startOffset.width / size.width
            let p0Y = startPosition.y + startOffset.height / size.height
            let p1X = getControlPoints().0.x + getControlPointOffsets().0.width / size.width
            let p1Y = getControlPoints().0.y + getControlPointOffsets().0.height / size.height
            let p2X = getControlPoints().1.x + getControlPointOffsets().1.width / size.width
            let p2Y = getControlPoints().1.y + getControlPointOffsets().1.height / size.height
            let p3X = endPosition.x + endOffset.width / size.width
            let p3Y = endPosition.y + endOffset.height / size.height
            let arrowPosition = edgePath.pointOnBezierCurve(t: arrowParameter, p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            let nextArrowPosition = edgePath.pointOnBezierCurve(t: max(arrowParameter - 0.01, 0), p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            let dx = nextArrowPosition.x - arrowPosition.x
            let dy = nextArrowPosition.y - arrowPosition.y
            if let gradient = edgePath.bezierTangentGradient(t: graphViewModel.getGraph().edgeReverseArrowParameters[edge.id] ?? 0.5, p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y)) {
                if dx > 0 {
                    angle = atan(gradient)
                } else if dx < 0 {
                    angle = CGFloat.pi + atan(gradient)
                } else {
                    angle = CGFloat.pi / 2 * (dy > 0 ? 1 : -1)
                }
            } else { // If the gradient is undefined
                if dy > 0 {
                    angle = -CGFloat.pi / 2
                } else {
                    angle = CGFloat.pi / 2
                }
            }
        }
        
        return angle
    }
    lazy var edgePath: EdgePath = EdgePath(startVertexPosition: graphViewModel.getVertexByID(edge.startVertexID)!.position, endVertexPosition: graphViewModel.getVertexByID(edge.endVertexID)!.position, startOffset: graphViewModel.getGraph().getOffsetByID(edge.startVertexID)!, endOffset: graphViewModel.getGraph().getOffsetByID(edge.endVertexID)!, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1)
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
        self.forwardArrow = Arrow(angle: forwardAngle)
        self.reverseArrow = Arrow(angle: reverseAngle)
    }
    
    func removeEdgeFromGraph() {
        graphViewModel.removeEdge(edge)
    }
    
    func initWeightPosition() -> CGPoint {
        let midPoint = edgePath.midpoint()
        let offset = getEdgeWeightOffset()
        
        if let perpendicularGradient = edgePath.perpendicularGradient() {
            let (pointOnPerpendicular, _) = edgePath.pointOnPerpendicular(point: midPoint, perpendicularGradient: perpendicularGradient, distance: Edge.DEFAULT_WEIGHT_DISTANCE)
            return CGPoint(
                x: pointOnPerpendicular.x,
                y: pointOnPerpendicular.y
            )
        }
        
        return CGPoint(
            x: midPoint.x * size.width + offset.width,
            y: (midPoint.y + Edge.DEFAULT_WEIGHT_DISTANCE) * size.height + offset.height
        )
    }
    
    func getID() -> UUID {
        return edge.id
    }
    
    func getGraphMode() -> Graph.Mode {
        graphViewModel.getMode()
    }
    
    func getColor() -> Color {
        return edge.color
    }
    
    func getEdgeWeight() -> Double? {
        graphViewModel.getWeight(edge: edge)
    }
    
    func setEdgeWeight(_ weight: Double) {
        graphViewModel.setWeight(edge: edge, weight: weight)
    }
    
    func getForwardArrowParameter() -> CGFloat {
        graphViewModel.getGraph().edgeForwardArrowParameters[edge.id] ?? 0.75
    }
    
    func getReverseArrowParameter() -> CGFloat {
        graphViewModel.getGraph().edgeReverseArrowParameters[edge.id] ?? 0.25
    }
    
    func setForwardArrowParameter(_ p: CGFloat) {
        graphViewModel.setEdgeForwardArrowParameter(id: edge.id, parameter: p)
    }
    
    func setReverseArrowParameter(_ p: CGFloat) {
        graphViewModel.setEdgeReverseArrowParameter(id: edge.id, parameter: p)
    }
    
    func setColor(_ color: Color) {
        edge.color = color
    }
    
    func getStartVertexPosition() -> CGPoint? {
        graphViewModel.getVertexByID(edge.startVertexID)?.position
    }
    
    func getEndVertexPosition() -> CGPoint? {
        graphViewModel.getVertexByID(edge.endVertexID)?.position
    }
    
    func getStartOffset() -> CGSize? {
        graphViewModel.getGraph().getOffsetByID(edge.startVertexID)
    }
    
    func getEndOffset() -> CGSize? {
        graphViewModel.getGraph().getOffsetByID(edge.endVertexID)
    }
    
    func getControlPoints() -> (CGPoint, CGPoint) {
        graphViewModel.getControlPoints(for: edge)
    }
    
    func getControlPointOffsets() -> (CGSize, CGSize) {
        graphViewModel.getControlPointOffsets(for: edge)
    }
    
    func getEdgeWeightPosition() -> CGPoint? {
        graphViewModel.getWeightPosition(for: edge)
    }
    
    func setEdgeWeightPosition(position: CGPoint) {
        graphViewModel.setWeightPosition(for: edge, position: position)
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
    @State private var tempForwardArrowPosition = CGPoint.zero
    @State private var tempReverseArrowPosition = CGPoint.zero
    @State private var forwardArrowOffset = CGSize.zero {
        willSet {
            edgeViewModel.setForwardArrowParameter( edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: tempForwardArrowPosition.x + forwardArrowOffset.width / size.width, y: tempForwardArrowPosition.y + forwardArrowOffset.height / size.height), p0: edgeViewModel.getStartVertexPosition() ?? .zero, p1: edgeViewModel.getControlPoints().0, p2: edgeViewModel.getControlPoints().1, p3: edgeViewModel.getEndVertexPosition() ?? .zero))
        }
    }
    @State private var reverseArrowOffset = CGSize.zero {
        willSet {
            edgeViewModel.setReverseArrowParameter(edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: tempReverseArrowPosition.x + reverseArrowOffset.width / size.width, y: tempReverseArrowPosition.y + reverseArrowOffset.height / size.height), p0: edgeViewModel.getStartVertexPosition() ?? .zero, p1: edgeViewModel.getControlPoints().0, p2: edgeViewModel.getControlPoints().1, p3: edgeViewModel.getEndVertexPosition() ?? .zero))
        }
    }
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
    var forwardArrowPoint: CGPoint {
        get {
            let startPosition = edgeViewModel.getStartVertexPosition() ?? CGPoint.zero
            let startOffset = edgeViewModel.getStartOffset() ?? CGSize.zero
            let (controlPoint1, controlPoint2) = edgeViewModel.getControlPoints()
            let (control1Offset, control2Offset) = edgeViewModel.getControlPointOffsets()
            let endPosition = edgeViewModel.getEndVertexPosition() ?? CGPoint.zero
            let endOffset = edgeViewModel.getEndOffset() ?? CGSize.zero
            let p0X = startPosition.x + startOffset.width / size.width
            let p0Y = startPosition.y + startOffset.height / size.height
            let p1X = controlPoint1.x + control1Offset.width / size.width
            let p1Y = controlPoint1.y + control1Offset.height / size.height
            let p2X = controlPoint2.x + control2Offset.width / size.width
            let p2Y = controlPoint2.y + control2Offset.height / size.height
            let p3X = endPosition.x + endOffset.width / size.width
            let p3Y = endPosition.y + endOffset.height / size.height
            let pointOnCurve = edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.getForwardArrowParameter(), p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            return CGPoint(x: pointOnCurve.x, y: pointOnCurve.y)
        }
    }
    var reverseArrowPoint: CGPoint {
        get {
            let startPosition = edgeViewModel.getStartVertexPosition() ?? CGPoint.zero
            let startOffset = edgeViewModel.getStartOffset() ?? CGSize.zero
            let (controlPoint1, controlPoint2) = edgeViewModel.getControlPoints()
            let (control1Offset, control2Offset) = edgeViewModel.getControlPointOffsets()
            let endPosition = edgeViewModel.getEndVertexPosition() ?? CGPoint.zero
            let endOffset = edgeViewModel.getEndOffset() ?? CGSize.zero
            let p0X = startPosition.x + startOffset.width / size.width
            let p0Y = startPosition.y + startOffset.height / size.height
            let p1X = controlPoint1.x + control1Offset.width / size.width
            let p1Y = controlPoint1.y + control1Offset.height / size.height
            let p2X = controlPoint2.x + control2Offset.width / size.width
            let p2Y = controlPoint2.y + control2Offset.height / size.height
            let p3X = endPosition.x + endOffset.width / size.width
            let p3Y = endPosition.y + endOffset.height / size.height
            let pointOnCurve = edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.getReverseArrowParameter(), p0: CGPoint(x: p0X, y: p0Y), p1: CGPoint(x: p1X, y: p1Y), p2: CGPoint(x: p2X, y: p2Y), p3: CGPoint(x: p3X, y: p3Y))
            return CGPoint(x: pointOnCurve.x, y: pointOnCurve.y)
        }
    }
    
    init(edgeViewModel: EdgeViewModel, size: CGSize) {
        self.edgeViewModel = edgeViewModel
        self.graphViewModel = edgeViewModel.graphViewModel
        self.tempWeightPosition = edgeViewModel.getEdgeWeightPosition() ?? edgeViewModel.initWeightPosition()
        self.size = size
        self._tempForwardArrowPosition = .init(wrappedValue: forwardArrowPoint)
        self._tempReverseArrowPosition = .init(wrappedValue: reverseArrowPoint)
    }
    
    var body: some View {
        edgeViewModel.edgePath.makePath(size: size)
#if os(macOS)
            .stroke(edgeViewModel.getColor(), lineWidth: 5)
#elseif os(iOS)
            .stroke(edgeViewModel.getColor(), lineWidth: 15)
#endif
            .shadow(color: edittingWeight ? .teal : .clear, radius: 10)
            .onTapGesture(count: 2) {
                if edgeViewModel.getGraphMode() == .edit {
                    if graphViewModel.selectedEdge?.id == edgeViewModel.getID() {
                        graphViewModel.selectedEdge = nil
                    }
                    edgeViewModel.removeEdgeFromGraph()
                }
            }
            .onTapGesture(count: 1) {
                if graphViewModel.selectedEdge?.id == edgeViewModel.getID() {
                    graphViewModel.selectedEdge = nil
                } else {
                    graphViewModel.selectedEdge = graphViewModel.getGraph().edges[edgeViewModel.getID()]
                }
            }
        
        if edgeViewModel.directed == .forward || edgeViewModel.directed == .bidirectional {
            edgeViewModel.forwardArrow
#if os(macOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 4)
#elseif os(iOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 15)
#endif
                .frame(width: 40, height: 40)
                .position(CGPoint(x: forwardArrowPoint.x * size.width, y: forwardArrowPoint.y * size.height))
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        forwardArrowOffset = drag.translation
                    }).onEnded { _ in
                        forwardArrowOffset = .zero
                        tempForwardArrowPosition = forwardArrowPoint
                    })
        }
        
        if edgeViewModel.directed == .reverse || edgeViewModel.directed == .bidirectional {
            edgeViewModel.reverseArrow
#if os(macOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 4)
#elseif os(iOS)
                .stroke(edgeViewModel.getColor(), lineWidth: 15)
#endif
                .frame(width: 40, height: 40)
                .position(CGPoint(x: reverseArrowPoint.x * size.width, y: reverseArrowPoint.y * size.height))
                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onChanged({ drag in
                        reverseArrowOffset = drag.translation
                    }).onEnded { _ in
                        reverseArrowOffset = .zero
                        tempReverseArrowPosition = reverseArrowPoint
                    })
        }
        
        // Control points for selected edge
        if edgeViewModel.getGraphMode() == .edit {
            if graphViewModel.selectedEdge?.id == edgeViewModel.getID() {
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
                    TextField("Enter weight", value: Binding(get: { edgeViewModel.getEdgeWeight() ?? 0.0 }, set: { newValue in edgeViewModel.setEdgeWeight(newValue)}), format: .number)
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
                Group {
                    Text("\(edgeViewModel.getEdgeWeight()?.formatted() ?? "0")")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(graphViewModel.selectedEdge?.id == edgeViewModel.getID() ? Color.teal : Color.primary)
                        .shadow(color: graphViewModel.selectedEdge?.id == edgeViewModel.getID() ? .teal : .clear, radius: 10)
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
        let graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
        let graphViewModel = GraphViewModel(graph: graph)
        let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
        EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
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

struct Arrow: Shape {
    let angle: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path { path in
            let start = CGPoint(x: rect.midX, y: rect.minY)
            let point = CGPoint(x: rect.maxX, y: rect.midY)
            let end = CGPoint(x: rect.midX, y: rect.maxY)
            path.move(to: start)
            path.addLine(to: point)
            path.addLine(to: end)
        }
        path = path.applying(CGAffineTransform.init(translationX: -rect.width / 2, y: -rect.height / 2))
        path = path.applying(CGAffineTransform.init(rotationAngle: angle))
        path = path.applying(CGAffineTransform.init(translationX: rect.width / 2, y: rect.height / 2))
        return path
    }
}
