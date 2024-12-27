//
//  MoveTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct MoveTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: K33().graph)
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var moveDidHappen = false
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Drag a vertex to move it.")
                            .font(.largeTitle)
                            .foregroundColor(themeViewModel.theme!.primaryColor)
                            .padding()
                        Spacer()
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Tap")
                                .padding([.leading], 50)
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .padding([.trailing], 50)
                        }
                        .padding([.bottom], 50)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        showInstructions = false
                        showCanvas = true
                    }
                }
                .animation(.easeInOut, value: showInstructions)
            }
            
            if showCanvas {
                ZStack {
                    GeometryReader { geometry in
                        ForEach(graphViewModel.getEdges(), id: \.id) { edge in
                            let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                            EdgeView(edgeViewModel: edgeViewModel)

                        }
                        ForEach(graphViewModel.getVertices(), id: \.id) { vertex in
                            let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                            VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                                .gesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                                    .onChanged({ drag in
                                        if graphViewModel.getMode() == .edit {
                                            graphViewModel.movingVertex = vertex
                                            vertexViewModel.setOffset(size: drag.translation)
                                            // Notify the model to store copies of
                                            // the vertex and connected edges in
                                            // their original states.
                                            graphViewModel.vertexWillMove(vertex, size: geometry.size)
                                            //Update the control points and control point offsets for every edge connected to a moving vertex
                                            let connectedEdges = graphViewModel.getConnectedEdges(to: vertex.id)
                                            for edge in connectedEdges {
                                                // Keep original copies of all
                                                // vertices connected by edge.
                                                let otherVertexID = edge.traverse(from: vertex.id)!
                                                let otherVertex = graphViewModel.getVertexByID(otherVertexID)!
                                                graphViewModel.vertexWillMove(otherVertex, size: geometry.size)
                                                // Update the control point
                                                // offsets for edge
                                                graphViewModel.setEdgeControlPointOffsets(edge: edge, translation: drag.translation, geometrySize: geometry.size)
                                            }
                                        }
                                    }).onEnded { _ in
                                        withAnimation {
                                            moveDidHappen = true
                                        }
                                        if graphViewModel.getMode() == .edit {
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
                                                    let edgePath = EdgePath(startVertexPosition: startVertex.position, endVertexPosition: endVertex.position, startOffset: startVertex.offset, endOffset: endVertex.offset, controlPoint1: graphViewModel.getControlPoints(for: edge).0, controlPoint2: graphViewModel.getControlPoints(for: edge).1, controlPoint1Offset: graphViewModel.getControlPointOffsets(for: edge).0, controlPoint2Offset: graphViewModel.getControlPointOffsets(for: edge).1, size: geometry.size)
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
                                                    graphViewModel.setWeightPosition(for: edge, position: newWeightPosition, size: geometry.size)
                                                    
                                                }
                                                graphViewModel.resetVertexEdgeChanges()
                                                
                                            }
                                        }
                                    })
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
            
            if moveDidHappen {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Spacer()
                        HStack {
                            Spacer()
                            HStack {
                                Text("Swipe")
                                    .font(.title)
                                    .padding([.leading], 50)
                                Image(systemName: "arrow.forward")
                                    .font(.title)
                                    .padding([.trailing], 50)
                            }
                            .background(in: RoundedRectangle(cornerRadius: 10))
                            .backgroundStyle(themeViewModel.theme!.accentColor)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .animation(.easeInOut, value: moveDidHappen)
            }
        }
    }
}

#Preview {
    MoveTutorial()
}
