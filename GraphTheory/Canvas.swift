//
//  Canvas.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct Canvas: View {
    //@Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @ObservedObject var graphViewModel: GraphViewModel
    //@State private var isLoadViewVisible = false // State to control visibility
    
    /*
     private func saveGraph() {
     modelContext.insert(graphViewModel.getGraph())
     try? modelContext.save()
     }
     */
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                // Background to detect taps
                Color.clear
                    .contentShape(Rectangle()) // Ensures the tap area spans the entire view
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { tapLocation in
                                if graphViewModel.mode == .edit {
                                    // Add a vertex at the tap location
                                    let normalizedLocation = CGPoint(
                                        x: tapLocation.location.x / geometry.size.width,
                                        y: tapLocation.location.y / geometry.size.height
                                    )
                                    let newVertex = Vertex(position: normalizedLocation)
                                    graphViewModel.addVertex(newVertex)
                                }
                            }
                    )
                
                // Render the graph
                GraphView(graphViewModel: graphViewModel)
            }
        }
        /*
         .sheet(isPresented: $isLoadViewVisible) {
         LoadView(isVisible: $isLoadViewVisible) // Pass binding to manage visibility
         }
         */
        /*
         .toolbar {
         #if os(macOS)
         ToolbarItemGroup(placement: .automatic) {
         /*
          Button("Save") {
          saveGraph()
          }
          
          Button("Load") {
          isLoadViewVisible = true
          }
          */
         
         }
         #elseif os(iOS)
         ToolbarItemGroup(placement: .topBarTrailing) {
         /*
          Button("Save") {
          saveGraph()
          }
          
          Button("Load") {
          isLoadViewVisible = true
          }
          */
         
         }
         #endif
         }
         */
    }
}

#Preview {
    let graphViewModel = GraphViewModel(graph: Graph())
    Canvas(graphViewModel: graphViewModel)
        .environmentObject(ThemeViewModel())
}
