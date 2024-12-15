//
//  DeleteTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct DeleteTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: K33().graph)
    @State private var showInstructions = true
    @State private var showCanvas = false
    @State private var everythingIsDeleted = false
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    VStack {
                        Spacer()
                        Text("Double tap a vertex or edge to delete it.")
                            .font(.largeTitle)
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
                                .onTapGesture(count: 2) {
                                    if graphViewModel.getConnectedEdges(to: vertex.id).contains(where: { $0.id == graphViewModel.selectedEdge?.id }) {
                                        graphViewModel.selectedEdge = nil
                                    }
                                    
                                    graphViewModel.removeEdgesConnected(to: vertexViewModel.getVertexID())
                                    graphViewModel.removeVertex(vertex)
                                    graphViewModel.selectedVertex = nil
                                    
                                    if graphViewModel.getVertices().count == 0 {
                                        withAnimation {
                                            everythingIsDeleted = true
                                        }
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut, value: showCanvas)
                }
            }
            
            if everythingIsDeleted {
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
                .animation(.easeInOut, value: everythingIsDeleted)
            }
        }
    }
}

#Preview {
    DeleteTutorial()
}
