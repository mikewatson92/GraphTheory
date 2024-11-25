//
//  ChinesePostmanEdgeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

struct ChinesePostmanEdgeView: View {
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
        edge.draw()
            .stroke(ChinesePostmanModel.colors[edge.timesSelectedCPP % 4], lineWidth: edgeThickness)
    }
}

#Preview {
    //ChinesePostmanEdgeView()
}
