//
//  KruskalEdgeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

struct KruskalEdgeView: View {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @StateObject var edge: Edge
    @ObservedObject var graph: Graph
    @State private var weightSelected: Bool
    @State private var weight: Double
    @Binding var showWeights: Bool
    let edgeThickness: CGFloat
    
    init(edge: Edge, graph: Graph, weightSelected: Bool = false, weight: Double = 0, showWeights: Binding<Bool>, edgeThickness: CGFloat) {
        self._edge = .init(wrappedValue: edge)
        self.graph = graph
        self.weightSelected = weightSelected
        self.weight = weight
        self._showWeights = showWeights
        self.edgeThickness = edgeThickness
    }
    
    var defaultEdgeColor: Color {
        if colorMode == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
            if (edge.isSelected && edge.status != .error) {
                edge.draw()
                    .stroke(.green, lineWidth: edgeThickness)
                    .shadow(color: .green, radius: 8)
            } else if (edge.isSelected && edge.status == .error) {
                edge.draw()
                    .stroke(.red, lineWidth: edgeThickness)
                    .shadow(color: .red, radius: 8)
            } else if (edge.status == .correct) {
                edge.draw()
                    .stroke(.green, lineWidth: edgeThickness)
            } else {
                edge.draw()
                    .stroke(defaultEdgeColor, lineWidth: edgeThickness)
            }
    }
}

#Preview {
    //KruskalEdgeView()
}
