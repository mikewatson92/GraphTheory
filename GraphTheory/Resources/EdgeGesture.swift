//
//  EdgeGesture.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//
import SwiftUI

class EdgeGesture: ObservableObject {

    @ObservedObject var edge: Edge
    @ObservedObject var graph: Graph
    @Binding var weightSelected: Bool
    
    init(edge: Edge, graph: Graph, weightSelected: Binding<Bool>) {
        self._edge = .init(wrappedValue: edge)
        self.graph = graph
        self._weightSelected = weightSelected
    }
    
    var curveGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged{ drag in
                if !self.graph.changesLocked {
                    self.edge.isCurved = true
                    self.edge.controlPointOffset = drag.translation
                    self.edge.textOffset = drag.translation
                }
            }
            .onEnded({ _ in
                if !self.graph.changesLocked {
                    let tempOffset = self.edge.controlPointOffset
                    self.edge.controlPointOffset = .zero
                    self.edge.textOffset = .zero
                    let edgeX = self.edge.controlPoint.x + tempOffset.width
                    let edgeY = self.edge.controlPoint.y + tempOffset.height
                    let textX = self.edge.textPosition.x + tempOffset.width
                    let textY = self.edge.textPosition.y + tempOffset.height
                    self.edge.controlPoint = CGPoint(x: edgeX, y: edgeY)
                    self.edge.textPosition = CGPoint(x: textX, y: textY)
                }
            })
    }
    
    var deleteGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                if !self.graph.changesLocked {
                    self.graph.edges.removeAll(where: { $0.id == self.edge.id })
                }
            }
    }
    
    var highlightGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                if !self.graph.changesLocked {
                    self.edge.isSelected = !self.edge.isSelected
                }
            }
    }
    
    var straightenGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: TapGesture())
            .onEnded({ _ in
                if !self.graph.changesLocked {
                    self.edge.isCurved = false
                    self.edge.controlPoint = self.edge.midpoint
                }
            })
    }
    
    // Allow the user to drag and reposition the edge weight label.
    var moveWeightGesture: some Gesture {
        DragGesture()
            .onChanged({ drag in
                self.edge.textOffset = drag.translation
            })
                .onEnded({ _ in
                    
                    let tempOffset = self.edge.textOffset
                    self.edge.textPosition.x += tempOffset.width
                    self.edge.textPosition.y += tempOffset.height
                    self.edge.textOffset = .zero
                    
                })
    }
}


#Preview {
    //GraphGesture()
}
