//
//  Canvas.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct Canvas: View {
    @Environment(\.colorScheme) var colorMode: ColorScheme
    @ObservedObject var model: ModelData
    @State private var showWeights: Bool = false
    @State private var startVertex: Vertex?
    @State private var endVertex: Vertex?
    @State private var weight: Double?
    @State private var pickerAlgorithm: GraphAlgorithm = .none
    @State private var action: Int? = 0
    @State private var algorithms: [GraphAlgorithm] = [.none, .kruskal, .prim, .primTable, .tsp, .chinesePostman]
    
    init(model: ModelData) {
        self.model = model
    }
    
    // Creates a vertex at the location the user clicks on the canvas
    public var placeVertexGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged {_ in
            }
            .onEnded {
                if !model.changesLocked {
                    let x = CGFloat($0.location.x)
                    let y = CGFloat($0.location.y)
                    let point = CGPoint(x: x, y: y)
                    let newVertex = Vertex(position: point)
                    newVertex.label = model.labels.sorted(by: < )[0]
                    model.labels.removeAll(where: { $0 == newVertex.label })
                    model.vertices.append(newVertex)
                }
            }
    }
    
    var canvas: some View {
        
        ZStack {
            Rectangle()
                .opacity(1)
                .foregroundColor(darkGray)
                .gesture(placeVertexGesture)
            
            // Draws all of the edges in the ModelData
            ForEach(model.edges) { edge in
                EdgeView(edge: edge, showWeights: $showWeights, model: model)
                    .shadow(color: edge.isSelected ? .green : .clear, radius: 8)
                    .onTapGesture(count: 1) {
                        if !model.changesLocked {
                            edge.isSelected = !edge.isSelected
                        }
                        
                    }
            }
            
            // Draws all the vertices in the ModelData
            ForEach(model.vertices) { vertex in
                VertexView(vertex: vertex, model: model)
                    .onTapGesture (count: 1){
                        //Add an edge after tapping two vertices.
                        //Keep track if which vertices have been selected.
                        if !model.changesLocked {
                            if startVertex == nil && vertex.status != .deleted {
                                startVertex = vertex
                                model.highlightedVertex = vertex
                                
                            } else if endVertex == nil && vertex.id != startVertex?.id {
                                if startVertex!.status == .deleted {
                                    startVertex = vertex
                                    model.highlightedVertex = vertex
                                } else {
                                    endVertex = vertex
                                }
                                
                            } else if endVertex == nil && vertex.id == startVertex?.id {
                                startVertex = nil
                                model.highlightedVertex = nil
                            }
                            if startVertex != nil && endVertex != nil {
                                let newEdge = Edge( startVertex!,  endVertex!)
                                model.edges.append(newEdge)
                                startVertex = nil
                                endVertex = nil
                                model.highlightedVertex = nil
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)

    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            canvas
            
            HStack {
                Toggle(isOn: $showWeights) {
                    Text("Weights")
                }
                .frame(maxWidth: 125)
                Spacer()
                Button("Clear") {
                    model.edges = []
                    model.vertices = []
                    model.highlightedVertex = nil
                    model.isMoving = false
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            model.algorithm = .none
            model.highlightedVertex = nil
            model.changesLocked = false
            model.weightChangeLocked = false
            for edge in model.edges {
                edge.isSelected = false
                edge.status = .none
            }
            for vertex in model.vertices {
                vertex.isSelected = false
            }
        }
        .navigationTitle("Canvas")
        .toolbar {
            ToolbarItem {
                Form {
                    Menu {
                        NavigationLink("Kruskal's Algorithm", destination: KruskalView(model: model))
                        NavigationLink("Prim's Algorithm", destination: PrimView(model: model))
                        //NavigationLink("Prim's Table", destination: PrimTable())
                        NavigationLink("Chinese Postman", destination: ChinesePostman(model: model))
                        NavigationLink("Traveling Salesman", destination: TSP(model: model))
                    } label: {
                        Text("Algorithm")
                    }
                    .frame(width: 175)
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
    
    
    
    struct Canvas_Previews: PreviewProvider {
        static var previews: some View {
            Canvas(model: ModelData())
        }
    }

