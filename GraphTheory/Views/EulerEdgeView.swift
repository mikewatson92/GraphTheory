//
//  EulerEdgeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

struct EulerEdgeView: View {
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
    
    var body: some View {
        if edge.isSelected {
            edge.draw()
                .stroke(.green, lineWidth: edgeThickness)
                .shadow(color: .green, radius: 8)
        } else {
            edge.draw()
                .stroke(.white, lineWidth: edgeThickness)
        }
    }
}

#Preview {
    //EulerEdgeView()
}
