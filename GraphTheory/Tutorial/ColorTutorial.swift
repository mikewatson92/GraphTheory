//
//  ColorTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct ColorTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: K33().graph)
    @State private var vertexEdgeColor: Color = .white
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var colorDidChange = false
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Tap a vertex or edge to select it. Use the color picker to change its color.")
                            .font(.largeTitle)
                            .foregroundColor(themeViewModel.colorTheme1)
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
                            EdgeView(edgeViewModel: edgeViewModel, size: geometry.size)
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
                                .shadow(color: vertexViewModel.getVertexID() == graphViewModel.selectedVertex?.id ? Color.green : Color.clear, radius: 10)
                                .onTapGesture(count: 1) {
                                    if let selectedVertex = graphViewModel.selectedVertex {
                                        if selectedVertex.id == vertex.id {
                                            graphViewModel.selectedVertex = nil
                                        } else {
                                            graphViewModel.selectedVertex = vertex
                                        }
                                    } else {
                                        graphViewModel.selectedEdge = nil
                                        graphViewModel.selectedVertex = vertex
                                    }
                                }
                                
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
            
            if colorDidChange {
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
                            .backgroundStyle(themeViewModel.accentColor)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .animation(.easeInOut, value: colorDidChange)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ColorPicker(
                    "",
                    selection: Binding(
                        get: {
                            if let selectedEdge = graphViewModel.selectedEdge {
                                return selectedEdge.color
                            } else if let selectedVertexColor = graphViewModel.selectedVertex?.color {
                                return selectedVertexColor
                            } else {
                                return vertexEdgeColor
                            }
                        },
                        set: { newColor in
                            if let selectedEdge = graphViewModel.selectedEdge {
                                colorDidChange = true
                                graphViewModel.setColorForEdge(edge: selectedEdge, color: newColor)
                                graphViewModel.selectedEdge =  graphViewModel.getGraph().edges[selectedEdge.id]
                            } else if let selectedVertex = graphViewModel.selectedVertex {
                                colorDidChange = true
                                graphViewModel.setColor(vertex: selectedVertex, color: newColor)
                                graphViewModel.selectedVertex = graphViewModel.getVertexByID(selectedVertex.id) // Sync selected vertex
                            } else {
                                vertexEdgeColor = newColor
                            }
                        }
                    )
                )
                .labelsHidden()
            }
        }
    }
}

#Preview {
    ColorTutorial()
}
