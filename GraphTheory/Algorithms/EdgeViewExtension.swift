//
//  EdgeViewExtension.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

extension EdgeView {
    
    var drawKruskalEdge: some View {
        ZStack{
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
    
    var drawPrimEdge: some View {
        ZStack{
            if (edge.isSelected && edge.status != .error) {
                edge.draw()
                .stroke(.green, lineWidth: edgeThickness)
                .shadow(color: .green, radius: 8)
            } else if (edge.isSelected && edge.status == .error) {
                edge.draw()
                    .stroke(.red, lineWidth: edgeThickness)
                    .shadow(color: .red, radius: 8)
            } else{
                edge.draw()
                    .stroke(defaultEdgeColor, lineWidth: edgeThickness)
            }
        }
    }
    
    var drawChinesePostmanEdge: some View {
        ZStack{
            edge.draw()
                .stroke(ChinesePostmanModel.colors[edge.timesSelectedCPP % 4], lineWidth: edgeThickness)
        }
    }
    
    var drawTSPEdge: some View {
        ZStack {
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
    
    var drawEulerEdge: some View {
        ZStack {
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
    
}
