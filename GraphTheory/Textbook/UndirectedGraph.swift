//
//  UndirectedGraph.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct UndirectedGraph: View {
    var body: some View {
        #if os(macOS)
        HStack {
            VStack {
                BulletPoint(header: "Adjacent vertices", text: "are vertices connected by an edge. A and B are adjacent vertices, but not D and F.")
                    .padding()
                BulletPoint(header: "Adjacent edges", text: "are edges which share a vertex. AB and BE are adjacent edges, but AB and CD are not.")
                    .padding()
                BulletPoint(header: "Degree:", text: "the degree of a vertex is the number of edges attached to it. The degree of A is 2. Loops add 2 to the degree, so C has degree 4.")
                    .padding()
            }
            UndirectedGraphExampleView()
        }
        .padding()
        #elseif os(iOS)
        VStack {
            BulletPoint(header: "Adjacent vertices", text: "are vertices connected by an edge. A and B are adjacent vertices, but not D and F.")
                .padding()
            BulletPoint(header: "Adjacent edges", text: "are edges which share a vertex. AB and BE are adjacent edges, but AB and CD are not.")
                .padding()
            BulletPoint(header: "Degree:", text: "the degree of a vertex is the number of edges attached to it. The degree of A is 2. Loops add 2 to the degree, so C has degree 4.")
                .padding()
            UndirectedGraphExampleView()
                .padding()
        }
        #endif
    }
}

#Preview {
    UndirectedGraph()
        .environmentObject(ThemeViewModel())
}
