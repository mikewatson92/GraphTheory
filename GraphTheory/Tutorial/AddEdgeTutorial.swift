//
//  AddEdgeTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct AddEdgeTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel: GraphViewModel
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var edgeWasAdded = false
    
    init() {
        let vertex1 = Vertex(position: CGPoint(x: 0.5, y: 0.2))
        let vertex2 = Vertex(position: CGPoint(x: 0.5, y: 0.8))
        let graph = Graph(vertices: [vertex1, vertex2])
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
                        Text("Tap a vertex to select it. Tap another to draw an edge.")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(themeViewModel.theme!.primaryColor)
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
                            EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
                        }
                        ForEach(graphViewModel.getVertices(), id: \.id) { vertex in
                            let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: graphViewModel)
                            VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
                                .shadow(color: vertexViewModel.getVertexID() == graphViewModel.selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                                .onTapGesture(count: 1) {
                                    if let selectedVertex = graphViewModel.selectedVertex {
                                        if selectedVertex.id == vertex.id {
                                            graphViewModel.selectedVertex = nil
                                        } else {
                                            let newEdge = Edge(startVertexID: selectedVertex.id, endVertexID: vertex.id)
                                            graphViewModel.addEdge(newEdge)
                                            withAnimation {
                                                edgeWasAdded = true
                                            }
                                        }
                                    } else {
                                        graphViewModel.selectedVertex = vertex
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                    
                    
                }
            }
            
            if edgeWasAdded {
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
                .animation(.easeInOut, value: edgeWasAdded)
            }
        }
    }
}

#Preview {
    AddEdgeTutorial()
}
