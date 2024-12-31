//
//  PlanarGraph1.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct PlanarGraph1 {
    let graph: Graph
    
    init() {
        let a = Vertex(position: CGPoint(x: 0.5000, y: 1 - 0.9500))
        let b = Vertex(position: CGPoint(x: 0.9280, y: 1 - 0.6391))
        let c = Vertex(position: CGPoint(x: 0.7645, y: 1 - 0.1359))
        let d = Vertex(position: CGPoint(x: 0.2355, y: 1 - 0.1359))
        let e = Vertex(position: CGPoint(x: 0.0720, y: 1 - 0.6391))
        let f = Vertex(position: CGPoint(x: 0.5000, y: 1 - 0.2500))
        let edgeAB = Edge(startVertexID: a.id, endVertexID: b.id)
        let edgeAC = Edge(startVertexID: a.id, endVertexID: c.id)
        let edgeAD = Edge(startVertexID: a.id, endVertexID: d.id)
        let edgeAE = Edge(startVertexID: a.id, endVertexID: e.id)
        let edgeBC = Edge(startVertexID: b.id, endVertexID: c.id)
        let edgeBF = Edge(startVertexID: b.id, endVertexID: f.id)
        let edgeBE = Edge(startVertexID: b.id, endVertexID: e.id)
        let edgeCD = Edge(startVertexID: c.id, endVertexID: d.id)
        let edgeCF = Edge(startVertexID: c.id, endVertexID: f.id)
        let edgeDE = Edge(startVertexID: d.id, endVertexID: e.id)
        let edgeDF = Edge(startVertexID: d.id, endVertexID: f.id)
        let edgeEF = Edge(startVertexID: e.id, endVertexID: f.id)
        let vertices = [a, b, c, d, e, f]
        let edges = [edgeAB, edgeAC, edgeAD, edgeAE, edgeBC, edgeBF, edgeBE, edgeCD, edgeCF, edgeDE, edgeDF, edgeEF]
        var graph = Graph(vertices: vertices, edges: edges)
        graph.resetMethod = .restoreToOriginal
        self.graph = graph
    }
}

struct PlanarGraph1View: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: PlanarGraph1().graph)
    @State private var showBanner = true
    @State private var result = Result.instructions
    
    enum Result: String {
        case instructions = "Move the vertices so that none of the edges intersect. Click on the checkmark to check your solution."
        case notFinished = "There are still some edges that are intersecting."
        case finished = "Congratulations! You've uncrossed all of the edges!"
    }
    
    func checkForCompletion() {
        for edge in graphViewModel.getEdges() {
            var otherEdges = graphViewModel.getEdges()
            otherEdges.removeAll(where: { $0.id == edge.id })
            for otherEdge in otherEdges {
                let intersects = EdgeIntersection.intersects(edge, otherEdge, graphViewModel: graphViewModel)
                if intersects {
                    return
                }
            }
        }
        result = .finished
        showBanner = true
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
    
    var body: some View {
        VStack {
            if showBanner {
                VStack {
                    Text(result.rawValue)
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Button {
                        withAnimation {
                            showBanner = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding([.top], 25)
                .transition(.move(edge: .top))
            }
            GeometryReader { geometry in
                ForEach(graphViewModel.getEdges()) { edge in
                    let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                    EdgeView(edgeViewModel: edgeViewModel)
                    // Negate the edge's natural gestures.
                        .highPriorityGesture(TapGesture())
                }
                ForEach(graphViewModel.getVertices()) { vertex in
                    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                    VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                            .onChanged({ drag in
                                handleVertexOnDragGesture(for: vertexViewModel, drag: drag, geometrySize: geometry.size)
                            }).onEnded { _ in
                                handleVertexEndDragGesture(for: vertexViewModel, geometrySize: geometry.size)
                                checkForCompletion()
                            })
                }
            }
        }
    }
}

#Preview {
    PlanarGraph1View()
        .environmentObject(ThemeViewModel())
}
