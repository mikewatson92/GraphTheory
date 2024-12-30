//
//  Overview.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct Overview: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Why is graph theory important?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Text("A graph is a powerful way to represent connections and relationships, helping us solve problems in the real world. Think of it as a network of nodes (vertices) connected by edges, where each node represents something important, and the edges show how they interact.")
                    .padding()
                Text("Here's where graphs come into play in ways you might actually care about:")
                    .font(.headline)
                    .padding()
                BulletPoint(header: "Social Media:", text: "Imagine every user on Instagram as a node, and every follower as a line connecting them. Graphs are how platforms suggest people you might know or analyze the most influential accounts.")
                    .padding()
                BulletPoint(header: "Gaming:", text: "In open-world games, graphs map out paths between locations or help AI-controlled characters find the best routes. Graphs make fast travel and enemy strategies possible!")
                    .padding()
                BulletPoint(header: "Streaming Services:", text: "Ever wonder how Apple Music creates the perfect playlist? Graphs connect songs based on their similarities or popularity among listeners to find tracks you'll love.")
                    .padding()
                BulletPoint(header: "Sports Analytics:", text: "In team sports, graphs analyze player connections, like passes in soccer or assists in basketball, to reveal strategies and top performers.")
                    .padding()
                BulletPoint(header: "City Navigation:", text: "Apps like Apple Maps use graphs to represent cities. Each location is a node, and roads are edges. They calculate your way to school or your favorite hangout.")
                    .padding()
                Text("Graphs aren't just abstract math - they're tools that power some of the most exciting parts of your world. Whether it's understanding social trends, beating your favorite game, or just getting to class on time, graphs make it all possible.")
                    .padding()
            }
        }
    }
}

#Preview {
    Overview()
        .environmentObject(ThemeViewModel())
}
