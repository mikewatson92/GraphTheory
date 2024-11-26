//
//  ContentView.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        NavigationSplitView{
            List {
                /*
                 Access to the textbook temporarily disabled due to
                 issues setting up Cocoapods
                
                Section(header: Text("Learn")) {
                    NavigationLink("Introduction", destination: GraphTheoryIntro())
                    NavigationLink("1 - Graphs", destination: Graphs())
                    NavigationLink("Practice A", destination: PracticeA())
                }
                 */
                Section(header: Text("Graph Algorithms")) {
                    NavigationLink("Canvas", destination: Canvas())
                }
                Section(header: Text("Practice Problems")) {
                    NavigationLink("Prim Table 1", destination: PrimTableModel1())
                    NavigationLink("Kruskal 1", destination: Kruskal1())
                    NavigationLink("Chinese Postman 1", destination: ChinesePostman1View())
                    NavigationLink("TSP 1", destination: TSP1())
                }
            }
        } detail: {
            NavigationStack{
                Canvas()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
