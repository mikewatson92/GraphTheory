//
//  ContentView.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: ModelData
    
    var body: some View {
        
        NavigationSplitView{
            List {
                Section(header: Text("Learn")) {
                    NavigationLink("Introduction", destination: GraphTheoryIntro())
                    NavigationLink("1 - Graphs", destination: Graphs())
                    NavigationLink("Practice A", destination: PracticeA())
                }
                Section(header: Text("Graph Algorithms")) {
                    NavigationLink("Canvas", destination: Canvas(model: model))
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
                Canvas(model: model)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ModelData())
            .environmentObject(ModelData())
    }
}
