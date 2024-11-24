//
//  Edge.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class Edge: Identifiable, ObservableObject, Equatable {
    
    let id: UUID = UUID()
    @Published var startVertex: Vertex
    @Published var endVertex: Vertex
    @Published var weight: Double = 0.0
    @Published var textOffset: CGSize = .zero
    @Published var isCurved = false
    @Published var controlPointOffset: CGSize = .zero
    @Published var isSelected = false
    @Published var textPosition: CGPoint
    lazy var controlPoint: CGPoint = midpoint
    @Published var status: Status = .none
    @Published var timesSelectedCPP: Int = 0
    var textDistance: Double = 20
    var textDirection: TextDirection = .positive
    var textEdgePosition: Double = 0.5 // A double between 0 and 1 indicating a point on edge
    var textStartPosition: CGPoint {
        perpendicularPoint(startPoint: pointOnEdge(textEdgePosition))
    }
    var isLoop: Bool { startVertex == endVertex }
    var directed: Directed
    var midpoint: CGPoint {
        let startX = startVertex.position.x
        let endX = endVertex.position.x
        let startY = startVertex.position.y
        let endY = endVertex.position.y
        let x = (startX + endX) / 2.0
        let y = (startY + endY) / 2.0
        
        return CGPoint(x: x, y: y)
    }
    
    private init(_ start: Vertex, _ end: Vertex, _ directed: Directed = .none) {
        _startVertex = .init(wrappedValue: start)
        _endVertex = .init(wrappedValue: end)
        self.textPosition = .zero
        self.directed = directed
    }
    
    convenience init(_ start: Vertex, _ end: Vertex, _ startTextPosition: Double = 0.5, _ directed: Directed = .none) {
        self.init(start, end, directed)
        let pointOnEdge = pointOnEdge(startTextPosition)
        self.textEdgePosition = startTextPosition
        self.textPosition = perpendicularPoint(startPoint: pointOnEdge)
    }
    
    enum Directed {
        case none
        case forward
        case reversed
        case bidirectional
    }
    
    enum Status {
        case error
        case correct
        case deleted
        case none
    }
    
    enum TextDirection {
        case positive, negative
    }
    
    static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id == rhs.id
    }
    
    // For creating arrow paths on directed graph edges
    func arrowPath() -> Path {
        // Doing it rightwards
        Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: -30.0, y: 15.0))
            path.addLine(to: .init(x: -30.0, y: -15.0))
            path.closeSubpath()
        }
    }
    
    // Calculate the x-coordinate for an arrow
    var arrowX: CGFloat {
        startVertex.position.x + 0.75 * (endVertex.position.x - startVertex.position.x)
    }
    
    // Calculate an additional x-coordinate for an arrow
    // on bidirectional edges
    var arrowX2: CGFloat {
        startVertex.position.x + 0.25 * (endVertex.position.x - startVertex.position.x)
    }
    
    // Function for correctly positioning an arrow on
    // a directed edge
    func arrowTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX, y: edgeYValue(x: arrowX) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(endVertex.position.y-startVertex.position.y, endVertex.position.x-startVertex.position.x)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    // Function for correctly positioning the second arrow on
    // a bidirectional edge
    func arrowTransform2() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX2, y: edgeYValue(x: arrowX2) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(startVertex.position.y - endVertex.position.y, startVertex.position.x - endVertex.position.x)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    // Function for correctly positioning an arrow on
    // an edge when edge.directed = Directed.reversed
    func arrowTransformReversed() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX, y: edgeYValue(x: arrowX) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(startVertex.position.y - endVertex.position.y, startVertex.position.x - endVertex.position.y)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    // Change positions of the start and end vertices of an edge
    func swapVertices() {
        let tempStartVertex = startVertex
        self.startVertex = self.endVertex
        self.endVertex = tempStartVertex
    }
    
    // Calculates the length of an edge as a CGFloat
    func length() -> CGFloat {
        let term1 = endVertex.position.x - startVertex.position.x
        let term2 = endVertex.position.y - startVertex.position.y
        let d = (term1 * term1 - term2 * term2).squareRoot()
        return d
    }
    
    // Returns a CGPoint on an edge representing a point position
    // units away from the starting vertex
    func pointOnEdge(_ position: Double) -> CGPoint {
        // position is a Double between 0 and 1, representing the position
        // on the edge from startVertex (position = 0) to
        // endVertex (position = 1).
        var x: CGFloat
        var y: CGFloat?
        let xDistance = endVertex.position.x - startVertex.position.x
        let yDistance = endVertex.position.y - startVertex.position.y
        if xDistance == 0 {
            x = startVertex.position.x
        } else {
            x = startVertex.position.x + position * xDistance
        }
        
        y = edgeYValue(x: x)
        
        if y == nil {
            if startVertex.position.y < endVertex.position.y {
                y = startVertex.position.y + position * abs(yDistance)
            } else {
                y = endVertex.position.y + position * abs(yDistance)
            }
        }
        
        return CGPoint(x: x, y: y!)
    }
    
    // Returns the y-intercept of the line perpendicular
    // to the edge
    func perpendicularYIntercept(point: CGPoint) -> CGFloat? {
        if endVertex.position.y - startVertex.position.y == 0 {
            return nil
        }
        let gradient = -(endVertex.position.x - startVertex.position.x) / (endVertex.position.y - startVertex.position.y)
        let b = -gradient * point.x + point.y
        return b
    }
    
    // Returns an x-coordinate for a point on the line
    // perpendicular to the edge.
    // Used for findining the x-coordinate of the weight label
    func perpendicularX(point: CGPoint, distance: CGFloat) -> CGFloat {
        if edgeGradient() == nil {
            switch textDirection {
            case .positive:
                return midpoint.x + distance
            case .negative:
                return midpoint.x - distance
            }
        } else if perpendicularGradient() == nil {
            return midpoint.x
        }
        
        let term1 = -perpendicularYIntercept(point: point)! * perpendicularGradient()! + point.x + point.y * perpendicularGradient()!
        let term2 = -perpendicularYIntercept(point: point)! * perpendicularYIntercept(point: point)!
        let term3 = -2 * perpendicularYIntercept(point: point)! * point.x * perpendicularGradient()!
        let term4 = 2 * perpendicularYIntercept(point: point)! * point.y
        let term5 = -point.x * point.x * perpendicularGradient()! * perpendicularGradient()!
        let term6 = 2 * point.x * point.y * perpendicularGradient()!
        let term7 = -point.y * point.y
        let term8 = distance * distance * perpendicularGradient()! * perpendicularGradient()!
        let term9 = distance * distance
        let term10 = perpendicularGradient()! * perpendicularGradient()! + 1
        
        switch textDirection {
        case .positive:
            return (term1 + (term2 + term3 + term4 + term5 + term6 + term7 + term8 + term9).squareRoot())
            / term10
        case .negative:
            return (term1 - (term2 + term3 + term4 + term5 + term6 + term7 + term8 + term9).squareRoot())
            / term10
        }
    }
    
    // Returns a y-coordinate for a point on the line
    // perpendicular to the edge.
    // Used for findining the x-coordinate of the weight label
    func perpendicularY(x: CGFloat, point: CGPoint) -> CGFloat {
        if perpendicularGradient() == nil {
            switch textDirection {
            case .positive:
                return point.y + textDistance
            case .negative:
                return point.y - textDistance
            }
        } else {
            return perpendicularGradient()! * x + perpendicularYIntercept(point: point)!
        }
    }
    
    // Returns a CGPoint on a line perpendicular to the edge.
    // Used for positioning weight labels.
    func perpendicularPoint(startPoint: CGPoint) -> CGPoint {
        let x: CGFloat = perpendicularX(point: startPoint, distance: textDistance)
        let y: CGFloat = perpendicularY(x: x, point: startPoint)
        
        if edgeGradient() == nil {
            return CGPoint(x: x + textDistance, y: y)
        } else {
            return CGPoint(x: x, y: y)
        }
    }
    
    // Returns the gradient of the edge
    func edgeGradient() -> CGFloat? {
        if endVertex.position.x == startVertex.position.x { return nil }
        
        return (endVertex.position.y - startVertex.position.y) / (endVertex.position.x - startVertex.position.x)
    }
    
    // Given an x-coordinate, return the corresponding
    // y-coordinate for a point on the edge
    func edgeYValue(x: CGFloat) -> CGFloat? {
        if edgeGradient() == nil || edgeYIntercept() == nil {
            return nil
        } else {
            return edgeGradient()! * x + edgeYIntercept()!
            
        }
    }
    
    // Returns the y-intercept of the equation of the line
    // for the edge
    func edgeYIntercept() -> CGFloat? {
        if endVertex.position.x == startVertex.position.x {
            return nil
        }
        
        return startVertex.position.y - edgeGradient()! * startVertex.position.x
        
    }
    
    // Get the gradient of the line perpendicular to the edge
    func perpendicularGradient() -> CGFloat? {
        // If starting vertex and ending positions are the same,
        // then there is no gradient to calculate
        if endVertex.position.y == startVertex.position.y { return nil }
        else {
            let gradient: CGFloat = -(endVertex.position.x - startVertex.position.x) / (endVertex.position.y - startVertex.position.y)
            
            return gradient
        }
    }
    
    // Returns the path used for drawing an edge
    func draw() -> Path {
        // If the edge is not a loop
        if !isLoop {
            let path = Path { path in
                path.move(to: CGPoint(x: startVertex.position.x + startVertex.offset.width, y: startVertex.position.y + startVertex.offset.height))
                if(isCurved){
                    path.addCurve(to: CGPoint(x: endVertex.position.x + endVertex.offset.width, y: endVertex.position.y + endVertex.offset.height), control1: CGPoint(x: controlPoint.x + controlPointOffset.width, y: controlPoint.y + controlPointOffset.height), control2: CGPoint(x: controlPoint.x + controlPointOffset.width, y: controlPoint.y + controlPointOffset.height))
                } else {
                    path.addLine(to: CGPoint(x: endVertex.position.x + endVertex.offset.width, y: endVertex.position.y + endVertex.offset.height))
                }
            }
            return path
        } else { // Used for drawing loops
            let path = Path { path in
                path.move(to: CGPoint(x: startVertex.position.x + startVertex.offset.width - Vertex.diameter / 4.0,
                                      y: startVertex.position.y + startVertex.offset.height))
                path.addCurve(to: CGPoint(x: startVertex.position.x + startVertex.offset.width + Vertex.diameter / 4.0,
                                          y: startVertex.position.y + startVertex.offset.height),
                              control1: CGPoint(x: startVertex.position.x + startVertex.offset.width - 2 * Vertex.diameter,
                                                y: startVertex.position.y + startVertex.offset.height + 2 * Vertex.diameter),
                              control2: CGPoint(x: startVertex.position.x + startVertex.offset.width + 2 * Vertex.diameter,
                                                y: startVertex.position.y + startVertex.offset.height + 2 * Vertex.diameter))
            }
            return path
        }
    }
}


struct EdgeView: View {
    @Environment(\.colorScheme) static var colorMode: ColorScheme
    @StateObject var edge: Edge
    @ObservedObject var graph: Graph
    @State private var weightSelected: Bool = false
    @State private var weight: Double
    @State var edgeColor: Color?
    @Binding var showWeights: Bool
    let edgeThickness: CGFloat = 8
    
    
    init(edge: Edge, showWeights: Binding<Bool>, graph: Graph) {
        _edge = .init(wrappedValue: edge)
        _showWeights = showWeights
        _weight = State(initialValue: edge.weight)
        self.graph = graph
    }
    
    var edgeGesture: GraphGesture {
        GraphGesture(edge: edge, graph: graph, weightSelected: $weightSelected)
    }
    
    var weightColor: Color {
        if weightSelected {
            return Color.blue
        } else {
            return Color.white
        }
    }
    
    static var defaultEdgeColor: Color {
        if colorMode == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // Returns a view of the edge drawn when no algorithm
    // is applied in the model
    var drawEdge: some View {
        // Draw the edge
        Group{
            if (edge.isSelected || edge.status == .correct) {
                edge.draw()
                    .stroke(.green, lineWidth: edgeThickness)
                    .gesture(edgeGesture.deleteGesture)
                    .gesture(edgeGesture.highlightGesture)
                    .shadow(color: .green, radius: 8)
                    .gesture(edgeGesture.straightenGesture)
                    .gesture(edgeGesture.curveGesture)
            } else if weightSelected {
                edge.draw()
                    .stroke(.blue, lineWidth: edgeThickness)
                    .shadow(color: .blue, radius: 8)
            } else {
                edge.draw()
                    .stroke(edgeColor ?? EdgeView.defaultEdgeColor, lineWidth: edgeThickness)
                    .gesture(edgeGesture.deleteGesture)
                    .gesture(edgeGesture.highlightGesture)
                    .gesture(edgeGesture.straightenGesture)
                    .gesture(edgeGesture.curveGesture)
            }
        }
    }
    
    // Returns a view showing the textfield for the edge weight
    var drawWeightTextField: some View {
        ZStack {
            Form {
                TextField("", value: $edge.weight, formatter: formatter)
                    .foregroundColor(weightColor)
                    .frame(width: 40, height: 25)
                    .position(x: edge.textPosition.x, y: edge.textPosition.y)
                    .offset(edge.textOffset)
                    .padding()
                    .gesture(edgeGesture.moveWeightGesture)
            }
            .onSubmit {
                weightSelected = false
            }
        }
    }
    
    // Returns a view showing the weights
    var drawWeights: some View {
        ZStack {
            // Display the weights of the edges near the
            // midpoint of each edge.
            if showWeights {
                Text(edge.weight.removeZerosFromEnd())
                    .foregroundColor(weightColor)
                    .position(x: edge.textPosition.x, y: edge.textPosition.y)
                    .offset(edge.textOffset)
                    .padding()
                
                // Return the weight label to the midpoint of the edge when double clicking the weight label.
                    .onTapGesture(count: 2) {
                        edge.textPosition = edge.textStartPosition
                    }
                // Display a form to change the edge weight when single clicking the weight label.
                    .onLongPressGesture(minimumDuration: 1, maximumDistance: 0){
                        if !graph.weightChangeLocked {
                            weightSelected = true
                        }
                    }
                    .gesture(edgeGesture.moveWeightGesture)
            }
        }
    }
    
    var body: some View {
        if graph.edges.contains(edge) {
            Group {
                switch graph.algorithm {
                case .kruskal:
                    KruskalEdgeView(edge: edge, graph: graph, showWeights: $showWeights, edgeThickness: edgeThickness)
                case .prim:
                    PrimEdgeView(edge: edge, graph: graph, showWeights: $showWeights, edgeThickness: edgeThickness)
                case .chinesePostman:
                    ChinesePostmanEdgeView(edge: edge, graph: graph, showWeights: $showWeights, edgeThickness: edgeThickness)
                case .tsp:
                    TSPEdgeView(edge: edge, graph: graph, showWeights: $showWeights, edgeThickness: edgeThickness)
                case .euler:
                    EulerEdgeView(edge: edge, graph: graph, showWeights: $showWeights, edgeThickness: edgeThickness)
                default:
                    drawEdge
                }
                
                if weightSelected && !graph.weightChangeLocked {
                    drawWeightTextField
                } else { drawWeights }
                
                if edge.directed == .forward {
                    edge.arrowPath()
                        .transform(edge.arrowTransform())
                        .stroke(.white, lineWidth: 4)
                        .background(edge.arrowPath()
                            .transform(edge.arrowTransform())
                            .fill(.cyan)
                        )
                } else if edge.directed == .reversed {
                    edge.arrowPath()
                        .transform(edge.arrowTransformReversed())
                        .stroke(.white, lineWidth: 4)
                        .background(edge.arrowPath()
                            .transform(edge.arrowTransformReversed())
                            .fill(.cyan))
                } else if edge.directed == .bidirectional {
                    edge.arrowPath()
                        .transform(edge.arrowTransform())
                        .stroke(.white, lineWidth: 4)
                        .background(edge.arrowPath()
                            .transform(edge.arrowTransform())
                            .fill(.cyan))
                    edge.arrowPath()
                        .transform(edge.arrowTransform2())
                        .stroke(.white, lineWidth: 4)
                        .background(edge.arrowPath()
                            .transform(edge.arrowTransform2())
                            .fill(.cyan))
                }
            }
        }
    }
}

struct Edge_Previews: PreviewProvider {
    
    static let firstVertex = Vertex(position: CGPoint(x: CGFloat(100), y: CGFloat(100)))
    static let secondVertex = Vertex(position: CGPoint(x: CGFloat(250), y: CGFloat(250)))
    static var edge = Edge(firstVertex, secondVertex)
    static let graph = Graph(edges: [edge], vertices: [firstVertex, secondVertex])
    
    static var previews: some View {
        ZStack{
            EdgeView(edge: edge, showWeights: .constant(false), graph: graph)
            VertexView(vertex: firstVertex, graph: graph)
            VertexView(vertex: secondVertex, graph: graph)
        }
    }
}
