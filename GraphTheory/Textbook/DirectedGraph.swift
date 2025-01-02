//
//  DirectedGraph.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct DirectedGraph: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    
    var body: some View {
        #if os(macOS)
        HStack {
            VStack {
                Group {
                    Text("A ") + Text("directed graph").fontWeight(.bold) + Text(" contains arrows indicating the direction of movement.")
                }
                .padding()
                BulletPoint(header: "In degree:", text: "the in degree of a vertex is the number of edges going into that vertex.")
                    .padding()
                BulletPoint(header: "Out degree:", text: "the out degree of a vertex is the number of edges leaving that vertex.")
                    .padding()
                Text("Vertex B has an in degree of 3 and an out degree of 3.")
                    .padding()
                Text("Tip: try dragging the arrows!")
            }
            .foregroundStyle(themeViewModel.theme!.primary)
            DirectedGraphExampleView()
                .padding()
        }
        #elseif os(iOS)
            VStack {
                Group {
                    Text("A ") + Text("directed graph").fontWeight(.bold) + Text(" contains arrows indicating the direction of movement.")
                }
                .padding()
                BulletPoint(header: "In degree:", text: "the in degree of a vertex is the number of edges going into that vertex.")
                    .padding()
                BulletPoint(header: "Out degree:", text: "the out degree of a vertex is the number of edges leaving that vertex.")
                    .padding()
                Text("Vertex B has an in degree of 3 and an out degree of 3.")
                    .padding()
                Text("Tip: try dragging the arrows!")
            DirectedGraphExampleView()
                .padding()
            }
            .foregroundStyle(themeViewModel.theme!.primary)
        #endif
    }
}

#Preview {
    DirectedGraph()
        .environmentObject(ThemeViewModel())
}
