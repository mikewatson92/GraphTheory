//
//  Vertex.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

class Vertex: Identifiable, ObservableObject, Equatable {
    
    @Published var position: CGPoint = .zero
    @Published var offset: CGSize = CGSize.zero
    @Published var isSelected = false
    @Published var status: Status = .none
    @Published var label: String = ""
    let id = UUID()
    static var diameter: CGFloat = 30
    let borderOffSet: CGFloat = 2.0
    
    init(position: CGPoint, label: String = "") {
        self.position = position
        self.label = label
    }
    
    var center: CGPoint {
        get {
            CGPoint(x: position.x + Vertex.diameter / 2, y: position.y + Vertex.diameter / 2)
        } set(newCenter) {
            let x = newCenter.x - Vertex.diameter / 2
            let y = newCenter.y - Vertex.diameter / 2
            position = CGPoint(x: x, y: y)
        }
    }
    
    func edgeIsConnected(edge: Edge) -> Bool {
        return edge.startVertex.id == self.id || edge.endVertex.id == self.id
    }
    
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum Status {
        case highlighted
        case visited
        case deleted
        case none
    }
    
}

struct VertexView: View {
    @StateObject var vertex: Vertex
    @ObservedObject var graph: Graph
    @State var labelSelected = false
    let borderWidth: CGFloat = 4

    
    init(vertex: Vertex, graph: Graph) {
        self.graph = graph
        _vertex = .init(wrappedValue: vertex)
    }
    
    public var moveGesture: some Gesture {
        DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
            .onChanged({ drag in
                if !graph.changesLocked {
                    vertex.offset = drag.translation
                    graph.isMoving = true
                    for edge in graph.edges {
                        if vertex.edgeIsConnected(edge: edge) {
                            let halfSizeWidth = drag.translation.width / 2.0
                            let halfSizeHeight = drag.translation.height / 2.0
                            let halfSize = CGSize(width: halfSizeWidth, height: halfSizeHeight)
                            edge.textOffset = halfSize
                        }
                    }
                }
            })
            .onEnded({ _ in
                if !graph.changesLocked {
                    let tempOffset = vertex.offset
                    vertex.position.x += tempOffset.width
                    vertex.position.y += tempOffset.height
                    vertex.offset = .zero
                    for edge in graph.edges {
                        let tempTextOffset = edge.textOffset
                        if vertex.edgeIsConnected(edge: edge) {
                            edge.textPosition.x += tempTextOffset.width
                            edge.textPosition.y += tempTextOffset.height
                            edge.textOffset = .zero
                        }
                    }
                    graph.isMoving = false
                }
            })
    }
    
    // Delete a vertex, and any connected edges,
    // if a vertex is clicked twice
    public var deleteGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                if !graph.changesLocked {
                    for edge in graph.edges {
                        if edge.startVertex.id == vertex.id || edge.endVertex.id == vertex.id {
                            graph.edges.remove(at: graph.edges.firstIndex(where: {$0.id == edge.id})!)
                        }
                    }
                    if graph.highlightedVertex == vertex {
                        graph.highlightedVertex = nil
                    }
                    vertex.status = .deleted
                    graph.labels.append(vertex.label)
                    graph.vertices.removeAll(where: { $0.id == vertex.id })
                }
            }
    }
    
    public var changeLabel: some Gesture {
        LongPressGesture(minimumDuration: 1, maximumDistance: 0)
            .onEnded { _ in
                if !graph.changesLocked {
                    labelSelected = true
                }
            }
    }
    
    public var drawTextField: some View {
        Form {
            TextField("", text: $vertex.label)
        }
        .onSubmit {
            labelSelected = false
        }
    }
    
    var body: some View {
        
        Group {
            if vertex.id == graph.highlightedVertex?.id {
                Circle()
                    .strokeBorder(.green, lineWidth: borderWidth)
                    .background(Circle().foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top)))
                    .overlay {
                        if labelSelected {
                            drawTextField
                        } else {
                            Text(vertex.label)
                                .foregroundColor(.white)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .shadow(color: Color.green.opacity(5), radius: Vertex.diameter + 8)
                    .frame(width: Vertex.diameter, height: Vertex.diameter)
                    .position(x: vertex.position.x, y: vertex.position.y)
                    .offset(vertex.offset)
                    .gesture(moveGesture)
                    .gesture(deleteGesture)
                    .gesture(changeLabel)
            } else if graph.vertices.contains(vertex){
                switch vertex.status {
                case .none:
                    Circle()
                        .strokeBorder(.white, lineWidth: borderWidth)
                        .background(Circle().foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top)))
                        .overlay {
                            if labelSelected {
                                drawTextField
                            } else {
                                Text(vertex.label)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(width: Vertex.diameter, height: Vertex.diameter)
                        .position(x: vertex.position.x, y: vertex.position.y)
                        .offset(vertex.offset)
                        .gesture(moveGesture)
                        .gesture(deleteGesture)
                        .gesture(changeLabel)
                case .visited:
                    Circle()
                        .strokeBorder(.white, lineWidth: borderWidth)
                        .background(Circle().foregroundStyle(redGradient))
                        .frame(width: Vertex.diameter, height: Vertex.diameter)
                        .position(x: vertex.position.x, y: vertex.position.y)
                        .offset(vertex.offset)
                        .gesture(moveGesture)
                        .gesture(deleteGesture)
                case .highlighted:
                    Circle()
                        .strokeBorder(.green, lineWidth: borderWidth)
                        .background(Circle().foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .bottom, endPoint: .top)))
                        .shadow(color: Color.green.opacity(5), radius: Vertex.diameter + 8)
                        .frame(width: Vertex.diameter, height: Vertex.diameter)
                        .position(x: vertex.position.x, y: vertex.position.y)
                        .offset(vertex.offset)
                        .gesture(moveGesture)
                        .gesture(deleteGesture)
                        .gesture(changeLabel)
                case .deleted:
                    Circle()
                        .strokeBorder(.white, lineWidth: borderWidth)
                        .background(Circle().foregroundColor(.gray))
                        .opacity(0.5)
                        .frame(width: Vertex.diameter, height: Vertex.diameter)
                        .position(x: vertex.position.x, y: vertex.position.y)
                        .offset(vertex.offset)
                }
            }
            
        }
    }
}

struct Vertex_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack{
            let x = CGFloat(100)
            let y = CGFloat(100)
            let position = CGPoint(x: x, y: y)
            let vertex = Vertex(position: position)
            VertexView(vertex: vertex, graph: Graph(vertices: [vertex]))
        }
    }
}
