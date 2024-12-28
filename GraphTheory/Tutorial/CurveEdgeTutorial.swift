//
//  CurveEdgeTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/15/24.
//

import SwiftUI

struct CurveEdgeTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel: GraphViewModel
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var curveDidHappen = false
    
    init() {
        let vertex1 = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        let vertex2 = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        let edge = Edge(startVertexID: vertex1.id, endVertexID: vertex2.id)
        let graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
        _graphViewModel = StateObject(wrappedValue: GraphViewModel(graph: graph))
    }
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Tap an edge to select it. Drag the red dots to change the shape.")
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
                            CurveEdgeTutorialView(edgeViewModel: edgeViewModel, size: geometry.size, curveDidHappen: { curveDidHappen = true })
                                .onTapGesture(count: 1) {
                                    if let selectedEdge = graphViewModel.selectedEdge {
                                        if selectedEdge.id == edge.id {
                                            graphViewModel.selectedEdge = nil
                                        } else {
                                            graphViewModel.selectedEdge = edge
                                        }
                                    } else {
                                        graphViewModel.selectedVertex = nil
                                        graphViewModel.selectedEdge = edge
                                    }
                                }
                                
                        }
                        ForEach(graphViewModel.getVertices(), id: \.id) { vertex in
                            let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                            VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
            
            if curveDidHappen {
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
                .animation(.easeInOut, value: curveDidHappen)
            }
        }
    }
}

struct CurveEdgeTutorialView: View {
    @ObservedObject var edgeViewModel: EdgeViewModel
    @ObservedObject var graphViewModel: GraphViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var edittingWeight = false
    @State private var tempForwardArrowPosition = CGPoint.zero
    @State private var tempReverseArrowPosition = CGPoint.zero
    @State private var forwardArrowOffset = CGSize.zero {
        willSet {
            edgeViewModel.forwardArrowParameter = (edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: tempForwardArrowPosition.x + forwardArrowOffset.width / size.width, y: tempForwardArrowPosition.y + forwardArrowOffset.height / size.height)))
        }
    }
    @State private var reverseArrowOffset = CGSize.zero {
        willSet {
            edgeViewModel.reverseArrowParameter = (edgeViewModel.edgePath.closestParameterToPoint(externalPoint: CGPoint(x: tempReverseArrowPosition.x + reverseArrowOffset.width / size.width, y: tempReverseArrowPosition.y + reverseArrowOffset.height / size.height)))
        }
    }
    @State private var tempWeightPosition: CGPoint {
        willSet {
            let (t, distance) = edgeViewModel.edgePath.closestParameterAndDistance(externalPoint: newValue)
            edgeViewModel.weightPositionParameterT = t
            edgeViewModel.weightPositionDistance = distance
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
            return edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.forwardArrowParameter)
        }
    }
    var reverseArrowPoint: CGPoint {
        get {
            return edgeViewModel.edgePath.pointOnBezierCurve(t: edgeViewModel.reverseArrowParameter)
        }
    }
    var curveDidHappen: () -> Void
    
    init(edgeViewModel: EdgeViewModel, size: CGSize, curveDidHappen: @escaping () -> Void) {
        self.edgeViewModel = edgeViewModel
        self.graphViewModel = edgeViewModel.graphViewModel
        self.tempWeightPosition = edgeViewModel.weightPosition
        self.size = size
        self.curveDidHappen = curveDidHappen
        self._tempForwardArrowPosition = .init(wrappedValue: forwardArrowPoint)
        self._tempReverseArrowPosition = .init(wrappedValue: reverseArrowPoint)
    }
    
    var body: some View {
            edgeViewModel.edgePath.makePath()
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
                        curveDidHappen()
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
                        curveDidHappen()
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
    CurveEdgeTutorial()
}
