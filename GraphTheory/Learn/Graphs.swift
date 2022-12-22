//
//  Graphs.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct Graphs: View {
    var title = "Graph"
    var definition = """
                        \\text{A graph is an ordered pair }~ G = \\left(V,~ E\\right) ~\\text{comprising:}
                        """
    var definition1_2 = """
                            \\bullet V,~ \\text{a set of vertices, or nodes;}
                            """
    var definition1_3 = """
                            \\bullet E \\subseteq \\{\\{x,~y\\} ~ | ~ x,~y \\in V ~\\text{ and }~ x  \\neq y\\},~ \\text{a set of edges, which are unordered pairs of vertices.}
                            """
    
    var body: some View {
        ScrollView{
            VStack{
                Group {
                    Definition(title: title, latex: [Math(expression: definition), Math(expression: definition1_2), Math(expression: definition1_3)])
                        .frame(width: 600)
                    
                    Spacer(minLength: 25)
                    
                    Text("A graph is defined by its vertices, as well as the edges that form connections between two vertices.")
                    
                    Spacer(minLength: 25)
                    
                    Text("""
                    Graph theory can be applied to many different fields, such as:
                    ・computer science and computer networks;
                    ・the natural and social sciences;
                    ・GPS;
                    ・and many other areas.
                    """)
                    
                    Spacer(minLength: 25)
                    
                    Text("Terminology")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .underline()
                    
                    Spacer(minLength: 25)
                    
                    DefinitionView()
                        .frame(width: 500, height: 500)
                    
                    Spacer(minLength: 25)
                    
                }
                
                Group {
                    Text("For example, vertex A has degree 3 and vertex E has degree 4, since loops contribute 2 to the degree of a vertex.")
                    
                    Spacer(minLength: 25)
                    
                    Text("Undirected Graphs")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .underline()
                    
                    Spacer(minLength: 25)
                    
                    HStack{
                        Text("An")
                        Text("undirected graph")
                            .underline()
                            .fontWeight(.bold)
                        Text("is a graph in which movement is allowed in either direction along the edges.")
                    }
                    
                    Spacer(minLength: 25)
                    
                    HStack {
                        Text("・")
                        Text("Adjacent vertices")
                            .underline()
                        Text("are vertices which are connected by an edge.")
                    }
                    .frame(width: 750, alignment: .leading)
                    
                    HStack {
                        Text("・")
                        Text("Adjacent edges")
                            .underline()
                        Text("are edges which share a common vertex.")
                    }
                    .frame(width: 750, alignment: .leading)
                    
                    HStack {
                        Text("・ The")
                        Text("degree")
                            .underline()
                        Text("of a vertex is the number of edges connected to it. A loop contributes 2 to the degree of a vertex.")
                    }
                    .frame(width: 750, alignment: .leading)
                    
                    Spacer(minLength: 25)
                }
                
                Group {
                    Text("Directed Graphs")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .underline()
                    
                    DirectedGraph()
                        .frame(width: 750, height: 500)
                    
                    Spacer(minLength: 25)
                    
                    HStack {
                        Text("A")
                        Text("directed graph")
                            .fontWeight(.bold)
                            .underline()
                        Text("contains arrows indicating the direction in which movement is allowed.")
                    }
                    
                    HStack {
                        Text("・The")
                        Text("in degree")
                            .fontWeight(.bold)
                            .underline()
                        Text("of a vertex is the number of edges coming into that vertex.")
                    }
                    .frame(width: 500, alignment: .leading)
                    
                    HStack {
                        Text("・The")
                        Text("out degree")
                            .fontWeight(.bold)
                            .underline()
                        Text("of a vertex is the number of edges going out of that vertex.")
                    }
                    .frame(width: 500, alignment: .leading)
                    
                    Text("For example, vertex A has an in degree of 2 and an out degree of 1.")
                }
                
                HStack{
                    Spacer()
                    NavigationLink(destination: PracticeA()) {
                        Label("Practice A", systemImage: "arrow.right.circle.fill")
                            .foregroundColor(.cyan)
                            .labelStyle(.trailingIcon)
                    }
                    .padding([.bottom, .trailing], 50)
                }
                
            }
            .navigationTitle("Graphs")
            .padding()
            .frame(maxWidth: .infinity)
            .background(darkGray)
            
            Spacer(minLength: 25)
        }
    }
}

struct Graphs_Previews: PreviewProvider {
    static var previews: some View {
        Graphs()
    }
}
