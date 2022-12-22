//
//  GraphTheoryIntro.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct GraphTheoryIntro: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Graph Theory")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Text("Introduction")
                    .foregroundColor(.white)
                    .underline()
                    .font(.title)
                    .padding()
                Text("The Seven Bridges of Königsberg")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.black)
                    .padding()
                Text("""
                        In 18th century Russia, the city of Königsberg (which is presently known as Kaliningrad) was built around the Pregel river, across which 7 bridges were constructed connecting 4 main land masses. The puzzle people pondered was as follows: how can one design a walk through the city that visits each land mass and crosses every bridge exactly once?
                    """)
                .foregroundColor(.white)
                .font(.body)
                .padding()
                .padding([.leading, .trailing], 20)
                
                Image("konigsberg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                
                Text("""
                    Leonhard Euler simplified the problem by noticing that the essential information was simply the sequence in which the bridges were crossed. He replaced the land masses with dots, or vertices, and represented the bridges with edges.
                
                    In the graph below, the blue vertices represent the 4 land masses, and the white edges represent the 7 bridges. See if you can solve the puzzle.
                
                1.) Start by clicking on any vertex as your starting point.
                2.) Click on an edge connected to your starting vertex. Your new vertex position will update.
                3.) Keep selecting edges to design your walk through the city.
                4.) If you want to start over, click on the "Clear" button.
                
                After experimenting for a bit, scroll down further to view the solution.
                """)
                .foregroundColor(.white)
                .font(.body)
                .padding()
                .padding([.leading, .trailing], 20)
                
                Konigsberg()
                    .frame(width: 500, height: 500)
                    .padding()
                    .padding(.bottom, 100)
                
                Text("Solution")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                
                Text("""
                        You may have noticed that it is difficult to design a walk through the old city of Konigsberg which crosses every bridge exactly once. In fact, it is impossible to do so. Euler proved in 1736 that such a walk through the city was indeed impossible. His publication is considered to contain the very first theorem on the topic of graph theory.
                    
                        However, the problem becomes possible to solve if you either delete a certain edge, or add an edge in a specific place. Take a moment to consider what aspects of the above graph made designing an appropriate walk impossible. Were there certain vertices that were difficult to reach or edges that couldn't be traversed? What properties of the graph made these difficulties arise? Was it the location of the vertices? Or perhaps the number of edges connected to a vertex?
                    
                        Test your knowledge on the graph below. You'll start by double tapping an edge to delete it. Next, single tap any vertex to mark it as your starting point. From there, single click on the connected edges to model your walk through the city of Konigsberg. If you get stuck or make a mistake, click the "Clear" button.
                    """)
                .foregroundColor(.white)
                .font(.body)
                .padding()
                .padding([.leading, .trailing], 20)
                
                Konigsberg2()
                    .frame(width: 500, height: 500)
                
            }
            .frame(maxWidth: .infinity)
            
            HStack{
                Spacer()
                NavigationLink(destination: Graphs()) {
                    Label("Graphs", systemImage: "arrow.right.circle.fill")
                        .foregroundColor(.cyan)
                        .labelStyle(.trailingIcon)
                }
                .padding([.bottom, .trailing], 50)
            }
        }
        .background(darkGray)
        .preferredColorScheme(.dark)
        .navigationTitle("Graph Theory Intro")
    }
}

struct GraphTheoryIntro_Previews: PreviewProvider {
    static var previews: some View {
        GraphTheoryIntro()
    }
}
