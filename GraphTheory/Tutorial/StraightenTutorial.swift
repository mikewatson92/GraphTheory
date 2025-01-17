//
//  StraightenTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct StraightenTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel: GraphViewModel
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var straightenDidHappen = false
    
    init() {
        let vertex1 = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        let vertex2 = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        let edge = Edge(startVertexID: vertex1.id, endVertexID: vertex2.id)
        var graph = Graph(vertices: [vertex1, vertex2], edges: [edge])
        graph.edges[edge.id]?.controlPoint1 = CGPoint(x: 0.2, y: 0.35)
        graph.edges[edge.id]?.controlPoint2 = CGPoint(x: 0.8, y: 0.65)
        _graphViewModel = StateObject(wrappedValue: GraphViewModel(graph: graph))
    }
    
    var edges: [Edge] {
        get {
            graphViewModel.getEdges()
        }
    }
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Long press a curved edge to straighten it.")
                            .font(.largeTitle)
                            .foregroundColor(themeViewModel.theme!.primary)
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
                        ForEach(graphViewModel.getEdges()) { edge in
                            let edgeViewModel = EdgeViewModel(edge: edge, size: geometry.size, graphViewModel: graphViewModel)
                            EdgeView(edgeViewModel: edgeViewModel)
                                .onLongPressGesture {
                                    let (controlPoint1, controlPoint2) = graphViewModel.initControlPointsFor(edge: edge)
                                    graphViewModel.setControlPoint1(for: edge, at: controlPoint1)
                                    graphViewModel.setControlPoint2(for: edge, at: controlPoint2)
                                    edgeViewModel.setControlPoint1Offset(.zero)
                                    edgeViewModel.setControlPoint2Offset(.zero)
                                    withAnimation {
                                        straightenDidHappen = true
                                    }
                                }
                        }
                        ForEach(graphViewModel.getVertices()) { vertex in
                            let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                            VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
                    
            
            if straightenDidHappen {
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
                            .backgroundStyle(themeViewModel.theme!.accent)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .animation(.easeInOut, value: straightenDidHappen)
            }
        }
        .onAppear {
            graphViewModel.selectedEdge = graphViewModel.getEdges()[0]
        }
    }
}

#Preview {
    StraightenTutorial()
}
