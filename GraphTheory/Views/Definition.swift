//
//  Definition.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct Definition: View {
    
    var title: String = ""
    var definition: String = ""
    var latex: [Math]?
    
    init(title: String, definition: String) {
        self.title = title
        self.definition = definition
    }
    
    init(title: String, latex: [Math]) {
        self.title = title
        self.latex = latex
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Definition: \(title)")
                .frame(height: 25)
                .foregroundColor(.black)
                .padding(.leading)
                .font(.title3)
                .fontWeight(.bold)
            if latex == nil {
                Text(definition)
                    .padding()
            } else {
                ForEach(latex!, id: \.self) { equation in
                    equation.frame(height: 0)
                }
                .scaledToFit()
                .padding()
            }
        }
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundColor(.blue)
                Rectangle()
                    .frame(height: 25)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

struct Definition_Previews: PreviewProvider {
    static var previews: some View {
        Definition(title: "Graph", definition: "A graph is a a set of vertices and edges")
    }
}
