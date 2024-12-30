//
//  Terminology.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct Terminology: View {
    var body: some View {
#if os(macOS)
        GeometryReader { geometry1 in
            ScrollView {
                HStack {
                    VStack {
                        BulletPoint(header: "Vertex:", text: "A vertex, or vertices, are points on a graph.")
                            .padding()
                        BulletPoint(header: "Edge:", text: "The lines are called edges.")
                            .padding()
                        BulletPoint(header: "Loop:", text: "An edge that starts and ends at the same vertex is called a loop.")
                            .padding()
                        Text("Try interacting with the graph and see what happens!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                    }
                    Spacer()
                    VStack {
                        GeometryReader { geometry2 in
                            ExampleGraph1View()
                                .frame(width: geometry2.size.width, height: geometry2.size.height)
                            ArrowLine()
                                .stroke(lineWidth: 5)
                                .foregroundStyle(Color.teal)
                                .rotationEffect(Angle(radians: Double.pi / 6), anchor: UnitPoint(x: 1, y: 0.5))
                                .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                .position(x: geometry2.size.width * 0.8, y: geometry2.size.height * 0.6)
                            Text("edge")
                                .position(x: geometry2.size.width * 0.65, y: geometry2.size.height * 0.45)
                                .foregroundStyle(Color.teal)
                            ArrowLine()
                                .stroke(lineWidth: 5)
                                .foregroundStyle(Color.green)
                                .rotationEffect(Angle(radians: 5 * Double.pi / 6))
                                .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                .position(x: geometry2.size.width * 0.525, y: geometry2.size.height * 0.3)
                            Text("vertex")
                                .position(x: geometry2.size.width * 0.7, y: geometry2.size.height * 0.2)
                                .foregroundStyle(Color.green)
                            ArrowLine()
                                .stroke(lineWidth: 5)
                                .foregroundStyle(Color.pink)
                                .rotationEffect(Angle(radians: Double.pi))
                                .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                .position(x: geometry2.size.width * 0.425, y: geometry2.size.height * 0.85)
                            Text("loop")
                                .position(x: geometry2.size.width * 0.6, y: geometry2.size.height * 0.85)
                                .foregroundStyle(Color.pink)
                            
                        }
                        .frame(width: geometry1.size.width * 0.5, height: geometry1.size.height * 0.75)
                        .padding()
                    }
                }
                .padding()
            }
        }
#elseif os(iOS)
        GeometryReader { geometry1 in
            let minimumDimension = min(geometry1.size.width, geometry1.size.height)
            ScrollView {
                VStack {
                    Group {
                        BulletPoint(header: "Vertex:", text: "A vertex, or vertices, are points on a graph.")
                        BulletPoint(header: "Edge:", text: "The lines are called edges.")
                        BulletPoint(header: "Loop:", text: "An edge that starts and ends at the same vertex is called a loop.")
                        Text("Try interacting with the graph and see what happens!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                    }
                    .padding()
                    
                    GeometryReader { geometry2 in
                        ExampleGraph1View()
                            .frame(width: geometry2.size.width, height: geometry2.size.height)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.teal)
                            .rotationEffect(Angle(radians: Double.pi / 6), anchor: UnitPoint(x: 1, y: 0.5))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(x: geometry2.size.width * 0.8, y: geometry2.size.height * 0.6)
                        Text("edge")
                            .position(x: geometry2.size.width * 0.65, y: geometry2.size.height * 0.45)
                            .foregroundStyle(Color.teal)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.green)
                            .rotationEffect(Angle(radians: 5 * Double.pi / 6))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(x: geometry2.size.width * 0.525, y: geometry2.size.height * 0.3)
                        Text("vertex")
                            .position(x: geometry2.size.width * 0.7, y: geometry2.size.height * 0.2)
                            .foregroundStyle(Color.green)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.pink)
                            .rotationEffect(Angle(radians: Double.pi))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(x: geometry2.size.width * 0.425, y: geometry2.size.height * 0.85)
                        Text("loop")
                            .position(x: geometry2.size.width * 0.6, y: geometry2.size.height * 0.85)
                            .foregroundStyle(Color.pink)
                        
                    }
                    .frame(width: minimumDimension, height: minimumDimension)
                    .padding()
                }
            }
            .padding()
            .frame(maxWidth: minimumDimension)
        }
        .padding()
#endif
    }
}

#Preview {
    Terminology()
        .environmentObject(ThemeViewModel())
}
