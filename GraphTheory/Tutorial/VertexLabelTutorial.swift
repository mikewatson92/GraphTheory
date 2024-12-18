//
//  VertexLabelTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct VertexLabelTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: Graph(vertices: [Vertex(position: CGPoint(x: 0.5, y: 0.5))], edges: []))
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var labelDidChange = false
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Long press the vertex to enter a new label.")
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
                                .onTapGesture(count: 2) {
                                    graphViewModel.removeEdge(edge)
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
                                .onSubmit {
                                    labelDidChange = true
                                }
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
            
            if labelDidChange {
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
                .animation(.easeInOut, value: labelDidChange)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Mode", selection: Binding(get: { graphViewModel.getMode() }, set: { newValue in graphViewModel.setMode(newValue)})) {
                        Text("Mode:")
                        Text("Edit").tag(Graph.Mode.edit)
                        Text("Explore").tag(Graph.Mode.explore)
                    }
                    .foregroundStyle(themeViewModel.accentColor)
                    
                    if graphViewModel.showAlgorithms {
                        
                    }
                    
                    Picker("Label Color", selection: Binding(
                        get: {
                            if let selectedVertex = graphViewModel.selectedVertex {
                                return selectedVertex.labelColor
                            }
                            return Vertex.LabelColor.white
                        },
                        set: { newColor in
                            if let selectedVertex = graphViewModel.selectedVertex {
                                graphViewModel.setVertexLabelColor(id: selectedVertex.id, labelColor: newColor)
                            }
                        }
                    )) {
                        Text("Label Color:")
                        ForEach(Vertex.LabelColor.allCases) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }
                label: {
                    Image(systemName: "gear")
                }
                
            }
        }
    }
}

#Preview {
    VertexLabelTutorial()
}
