//
//  AddVertexTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct AddVertexTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel = GraphViewModel(graph: Graph())
    @State private var showInstructions = true
    @State private var showEnd = false
    
    var body: some View {
        ZStack {
            if showInstructions {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                    
                    VStack {
                        Spacer()
                        Text("Tap on the screen to add a vertex.")
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
                .transition(.slide)
                .animation(.easeInOut(duration: 1), value: showInstructions)
                .onTapGesture(count: 1) {
                    withAnimation {
                        showInstructions = false
                    }
                }
                
            } else {
                ZStack {
                    GeometryReader { geometry in
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { tapLocation in
                                            if !showEnd {
                                                let normalizedLocation = CGPoint(
                                                    x: tapLocation.location.x / geometry.size.width,
                                                    y: tapLocation.location.y / geometry.size.height
                                                )
                                                let newVertex = Vertex(position: normalizedLocation)
                                                graphViewModel.addVertex(newVertex)
                                                withAnimation {
                                                    showEnd = true
                                                }
                                            }
                                        }
                                )
                            GraphView(graphViewModel: graphViewModel)
                        }
                    }
                }
                .transition(.slide)
                .animation(.easeInOut(duration: 1), value: showInstructions)
            }
            
            if showEnd {
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
                .transition(.slide)
                .animation(.easeInOut(duration: 1), value: showEnd)
            }
        }
    }
}

#Preview {
    AddVertexTutorial()
        .environmentObject(ThemeViewModel())
}
