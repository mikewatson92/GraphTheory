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
    
    func arrowPath() -> Path {
        // Doing it rightwards
        Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: -30.0, y: 15.0))
            path.addLine(to: .init(x: -30.0, y: -15.0))
            path.closeSubpath()
        }
    }
    
    var arrowX: CGFloat {
        startVertex.position.x + 0.75 * (endVertex.position.x - startVertex.position.x)
    }
    
    var arrowX2: CGFloat {
        startVertex.position.x + 0.25 * (endVertex.position.x - startVertex.position.x)
    }
    
    func arrowTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX, y: edgeYValue(x: arrowX) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(endVertex.position.y-startVertex.position.y, endVertex.position.x-startVertex.position.x)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    func arrowTransform2() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX2, y: edgeYValue(x: arrowX2) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(startVertex.position.y - endVertex.position.y, startVertex.position.x - endVertex.position.x)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    func arrowTransformReversed() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: arrowX, y: edgeYValue(x: arrowX) ?? (startVertex.position.y + endVertex.position.y) / 2.0 )
        let angle = atan2(startVertex.position.y - endVertex.position.y, startVertex.position.x - endVertex.position.y)
        let rotation = CGAffineTransform(rotationAngle: angle)
        return rotation.concatenating(translation)
    }
    
    func swapVertices() {
        let tempStartVertex = startVertex
        self.startVertex = self.endVertex
        self.endVertex = tempStartVertex
    }
    
    func length() -> CGFloat {
        let term1 = endVertex.position.x - startVertex.position.x
        let term2 = endVertex.position.y - startVertex.position.y
        let d = (term1 * term1 - term2 * term2).squareRoot()
        return d
    }
    
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
    
    func perpendicularYIntercept(point: CGPoint) -> CGFloat? {
        if endVertex.position.y - startVertex.position.y == 0 {
            return nil
        }
        let gradient = -(endVertex.position.x - startVertex.position.x) / (endVertex.position.y - startVertex.position.y)
        let b = -gradient * point.x + point.y
        return b
    }
    
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
    
    func perpendicularPoint(startPoint: CGPoint) -> CGPoint {
        let x: CGFloat = perpendicularX(point: startPoint, distance: textDistance)
        let y: CGFloat = perpendicularY(x: x, point: startPoint)
        
        if edgeGradient() == nil {
            return CGPoint(x: x + textDistance, y: y)
        } else if edgeGradient()! <= 0 {
            return CGPoint(x: x, y: y)
        } else {
            return CGPoint(x: x, y: y)
        }
    }
    
    func edgeGradient() -> CGFloat? {
        if endVertex.position.x == startVertex.position.x { return nil }
        
        return (endVertex.position.y - startVertex.position.y) / (endVertex.position.x - startVertex.position.x)
    }
    
    func edgeYValue(x: CGFloat) -> CGFloat? {
        if edgeGradient() == nil || edgeYIntercept() == nil {
            return nil
        } else {
            return edgeGradient()! * x + edgeYIntercept()!
     
        }
    }
    
    func edgeYIntercept() -> CGFloat? {
        if endVertex.position.x == startVertex.position.x {
            return nil
        }
        
        return startVertex.position.y - edgeGradient()! * startVertex.position.x
        
    }
    
    func perpendicularGradient() -> CGFloat? {
        if endVertex.position.y == startVertex.position.y { return nil }
        else {
            let gradient: CGFloat = -(endVertex.position.x - startVertex.position.x) / (endVertex.position.y - startVertex.position.y)

            return gradient
        }
    }
    
    func draw() -> Path {
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
    
    func print() {
        let text = "(Start: \(startVertex.id), End: \(endVertex.id))"
        Swift.print(text)
    }
}


struct EdgeView: View {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    //@EnvironmentObject var model: ModelData
    @StateObject var edge: Edge
    @ObservedObject var model: ModelData
    @State private var weightSelected: Bool = false
    @State private var weight: Double
    @Binding var showWeights: Bool
    let edgeThickness: CGFloat = 8
    
    init(edge: Edge, showWeights: Binding<Bool>, model: ModelData) {
        _edge = .init(wrappedValue: edge)
        _showWeights = showWeights
        _weight = State(initialValue: edge.weight)
        self.model = model
    }
    
    var weightColor: Color {
        if weightSelected {
            return Color.blue
        } else {
            return Color.white
        }
    }
    
    var defaultEdgeColor: Color {
        if colorMode == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    @State var edgeColor: Color?
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    public var curveGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged{ drag in
                if !model.changesLocked {
                    edge.isCurved = true
                    edge.controlPointOffset = drag.translation
                    edge.textOffset = drag.translation
                }
            }
            .onEnded({ _ in
                if !model.changesLocked {
                    let tempOffset = edge.controlPointOffset
                    edge.controlPointOffset = .zero
                    edge.textOffset = .zero
                    let edgeX = edge.controlPoint.x + tempOffset.width
                    let edgeY = edge.controlPoint.y + tempOffset.height
                    let textX = edge.textPosition.x + tempOffset.width
                    let textY = edge.textPosition.y + tempOffset.height
                    edge.controlPoint = CGPoint(x: edgeX, y: edgeY)
                    edge.textPosition = CGPoint(x: textX, y: textY)
                }
            })
    }
    
    public var deleteGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                if !model.changesLocked {
                    //model.edges.remove(at: model.edges.firstIndex(where: {$0.id == edge.id})!)
                    model.edges.removeAll(where: { $0.id == edge.id })
                }
            }
    }
    
    public var highlightGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                if !model.changesLocked {
                    edge.isSelected = !edge.isSelected
                }
            }
    }
    
    public var straightenGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: TapGesture())
            .onEnded({ _ in
                if !model.changesLocked {
                    edge.isCurved = false
                    edge.controlPoint = edge.midpoint
                }
            })
    }
    
    var drawEdge: some View {
        // Draw the edge
        ZStack{
            if (edge.isSelected || edge.status == .correct) {
                edge.draw()
                    .stroke(.green, lineWidth: edgeThickness)
                    .gesture(deleteGesture)
                    .gesture(highlightGesture)
                    .shadow(color: .green, radius: 8)
                    .gesture(straightenGesture)
                    .gesture(curveGesture)
            } else if weightSelected {
                edge.draw()
                    .stroke(.blue, lineWidth: edgeThickness)
                    .shadow(color: .blue, radius: 8)
            } else {
                edge.draw()
                    .stroke(edgeColor ?? defaultEdgeColor, lineWidth: edgeThickness)
                    .gesture(deleteGesture)
                    .gesture(highlightGesture)
                    .gesture(straightenGesture)
                    .gesture(curveGesture)
            }
        }
    }
    
    var drawWeightTextField: some View {
        ZStack {
            Form {
                TextField("", value: $edge.weight, formatter: formatter)
                    .foregroundColor(weightColor)
                    .frame(width: 40, height: 25)
                    .position(x: edge.textPosition.x, y: edge.textPosition.y)
                    .offset(edge.textOffset)
                    .padding()
                // Allow the user to drag and reposition the edge weight label.
                    .gesture(DragGesture()
                        .onChanged({ drag in
                            edge.textOffset = drag.translation
                        })
                            .onEnded({ _ in
                                
                                let tempOffset = edge.textOffset
                                edge.textPosition.x += tempOffset.width
                                edge.textPosition.y += tempOffset.height
                                edge.textOffset = .zero
                                
                            })
                    )
            }
            .onSubmit {
                weightSelected = false
            }
        }
    }
    
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
                        if !model.weightChangeLocked {
                            weightSelected = true
                        }
                    }
                // Allow the user to drag and reposition the edge weight label.
                    .gesture(DragGesture()
                        .onChanged({ drag in
                            edge.textOffset = drag.translation
                        })
                            .onEnded({ _ in
                                
                                let tempOffset = edge.textOffset
                                edge.textPosition.x += tempOffset.width
                                edge.textPosition.y += tempOffset.height
                                edge.textOffset = .zero
                                
                            })
                    )
            }
        }
    }
    
    var body: some View {
        
        ZStack {
            switch model.algorithm {
            case .kruskal:
                drawKruskalEdge
            case .prim:
                drawPrimEdge
            case .chinesePostman:
                drawChinesePostmanEdge
            case .tsp:
                drawTSPEdge
            case .euler:
                drawEulerEdge
            default:
                drawEdge
            }
            
            if weightSelected && !model.weightChangeLocked {
                drawWeightTextField
            } else {
                drawWeights
            }
            
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

struct Edge_Previews: PreviewProvider {
       
    static var previews: some View {
        let firstVertex = Vertex(position: CGPoint(x: CGFloat(100), y: CGFloat(100)))
        let secondVertex = Vertex(position: CGPoint(x: CGFloat(250), y: CGFloat(250)))
        let edge = Edge(firstVertex, secondVertex)

        ZStack{
            EdgeView(edge: edge, showWeights: .constant(false), model: ModelData())
            VertexView(vertex: firstVertex, model: ModelData())
            VertexView(vertex: secondVertex, model: ModelData())
        }
        
    }
}
