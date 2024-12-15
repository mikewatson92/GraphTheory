//
//  WeightsTutorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct WeightsTutorial: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject private var graphViewModel: GraphViewModel
    @State private var showInstructions = true
    @State private var weightsDidChange = false
    
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
                        Text("Tap the \(Image(systemName: "number.square.fill")) symbol to show the edge weights. Tap a weight and enter a new number.")
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
                .onTapGesture(count: 1) {
                    withAnimation {
                        showInstructions = false
                    }
                }
                .animation(.easeInOut, value: showInstructions)
            }
            
            if !showInstructions {
                ZStack {
                    GeometryReader { geometry in
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())
                            GraphView(graphViewModel: graphViewModel)
                                .onSubmit {
                                    weightsDidChange = true
                                }
                        }
                    }
                }
                .animation(.easeInOut, value: weightsDidChange || showInstructions)
            }
            
            if weightsDidChange {
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
                .animation(.easeInOut, value: weightsDidChange)
            }
            
        }
    }
}

#Preview {
    WeightsTutorial()
}
