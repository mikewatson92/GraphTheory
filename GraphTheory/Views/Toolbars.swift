//
//  ToolbarView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/24/24.
//

import SwiftUI

struct Toolbars: ToolbarContent {
    let graph: Graph
    
    init(graph: Graph) {
        self.graph = graph
    }
    
    var body: some ToolbarContent {
        ToolbarItem {
            Form {
                Menu {
                    NavigationLink("Kruskal's Algorithm", destination: KruskalView(graph: graph))
                    NavigationLink("Prim's Algorithm", destination: PrimView(graph: graph))
                    NavigationLink("Chinese Postman", destination: ChinesePostman(graph: graph))
                    NavigationLink("Traveling Salesman", destination: TSP(graph: graph))
                } label: {
                    Text("Algorithm")
                }
                .frame(width: 175)
                .padding()
            }
        }
    }
    
    
}

#Preview {
    Canvas(graph: Graph())
        .toolbar { Toolbars(graph: Graph()) }
}
