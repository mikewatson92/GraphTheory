//
//  TSPEdgeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

struct TSPEdgeView: View {
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
        switch edge.status {
        case .none:
            edge.draw()
                .stroke(.white, lineWidth: edgeThickness)
        case .error:
            edge.draw()
                .stroke(.red, lineWidth: edgeThickness)
        case .correct:
            edge.draw()
                .stroke(.green, lineWidth: edgeThickness)
        case .deleted:
            edge.draw()
                .stroke(.gray, style: StrokeStyle(lineWidth: edgeThickness / 2, dash: [10]))
                .opacity(0.33)
        }
    }
}

#Preview {
    //TSPEdgeView()
}
