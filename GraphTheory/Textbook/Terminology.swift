//
//  Terminology.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct Terminology: View {
    @StateObject private var graphViewModel = GraphViewModel(graph: ExampleGraph1().graph)
    
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
                            ExampleGraph1View(graphViewModel: graphViewModel)
                            if let vertexB = graphViewModel.graph.vertices.values.first(where: { $0.label == "B" }),
                               let vertexC = graphViewModel.graph.vertices.values.first(where: { $0.label == "C" }),
                               let edgeBC = graphViewModel.graph.edges.values.first(where: { $0.startVertexID == vertexB.id && $0.endVertexID == vertexC.id }) {
                                let edgeViewModel = EdgeViewModel(edge: edgeBC, size: geometry2.size, graphViewModel: graphViewModel)
                                let arrowPoint1 = edgeViewModel.edgePath.pointOnBezierCurve(t: 0.75)
                                let adjustedArrowPoint1 = CGPoint(x: arrowPoint1.x * geometry2.size.width - 0.1 * geometry2.size.width, y: arrowPoint1.y * geometry2.size.height - 0.1 * geometry2.size.height)
                                let textPosition1 = CGPoint(x: arrowPoint1.x * geometry2.size.width - 0.25 * geometry2.size.width, y: arrowPoint1.y * geometry2.size.height - 0.25 * geometry2.size.height)
                                ArrowLine()
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(Color.teal)
                                    .rotationEffect(Angle(radians: Double.pi / 6), anchor: UnitPoint(x: 1, y: 0.5))
                                    .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                    .position(adjustedArrowPoint1)
                                Text("edge")
                                    .position(textPosition1)
                                    .foregroundStyle(Color.teal)
                            }
                            if let vertexD = graphViewModel.graph.vertices.values.first(where: { $0.label == "D" }) {
                                let arrowPoint2 = CGPoint(x: vertexD.position.x + vertexD.offset.width / geometry2.size.width, y: vertexD.position.y + vertexD.offset.height / geometry2.size.height)
                                let adjustedArrowPoint2 = CGPoint(x: arrowPoint2.x * geometry2.size.width + 0.1 * geometry2.size.width, y: arrowPoint2.y * geometry2.size.height - 0.1 * geometry2.size.height)
                                ArrowLine()
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(Color.green)
                                    .rotationEffect(Angle(radians: 5 * Double.pi / 6))
                                    .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                    .position(adjustedArrowPoint2)
                                Text("vertex")
                                    .position(CGPoint(x: adjustedArrowPoint2.x + 20, y: adjustedArrowPoint2.y - 25))
                                    .foregroundStyle(Color.green)
                            }
                            if let vertexE = graphViewModel.graph.vertices.values.first(where: { $0.label == "E" }), let loop = graphViewModel.graph.edges.values.first(where: { $0.startVertexID == vertexE.id && $0.endVertexID == vertexE.id }) {
                                let edgeViewModel = EdgeViewModel(edge: loop, size: geometry2.size, graphViewModel: graphViewModel)
                                let arrowPoint3 = edgeViewModel.edgePath.pointOnBezierCurve(t: 0.75)
                                let adjustedArrowPoint3 = CGPoint(x: arrowPoint3.x * geometry2.size.width, y: arrowPoint3.y * geometry2.size.height)
                                ArrowLine()
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(Color.pink)
                                    .rotationEffect(Angle(radians: Double.pi), anchor: UnitPoint(x: 0.75, y: 0.5))
                                    .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                                    .position(adjustedArrowPoint3)
                                Text("loop")
                                    .position(x: adjustedArrowPoint3.x + geometry2.size.width * 0.275, y: adjustedArrowPoint3.y)
                                    .foregroundStyle(Color.pink)
                            }
                            
                        }
                        .frame(width: geometry1.size.width * 0.5, height: geometry1.size.height * 0.75)
                        .padding()
                    }
                }
                .padding()
            }
        }
#elseif os(iOS)
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
                    ExampleGraph1View(graphViewModel: graphViewModel)
                    if let vertexB = graphViewModel.graph.vertices.values.first(where: { $0.label == "B" }),
                       let vertexC = graphViewModel.graph.vertices.values.first(where: { $0.label == "C" }),
                       let edgeBC = graphViewModel.graph.edges.values.first(where: { $0.startVertexID == vertexB.id && $0.endVertexID == vertexC.id }) {
                        let edgeViewModel = EdgeViewModel(edge: edgeBC, size: geometry2.size, graphViewModel: graphViewModel)
                        let arrowPoint1 = edgeViewModel.edgePath.pointOnBezierCurve(t: 0.75)
                        let adjustedArrowPoint1 = CGPoint(x: arrowPoint1.x * geometry2.size.width - 0.1 * geometry2.size.width, y: arrowPoint1.y * geometry2.size.height - 0.1 * geometry2.size.height)
                        let textPosition1 = CGPoint(x: arrowPoint1.x * geometry2.size.width - 0.25 * geometry2.size.width, y: arrowPoint1.y * geometry2.size.height - 0.25 * geometry2.size.height)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.teal)
                            .rotationEffect(Angle(radians: Double.pi / 6), anchor: UnitPoint(x: 1, y: 0.5))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(adjustedArrowPoint1)
                        Text("edge")
                            .position(textPosition1)
                            .foregroundStyle(Color.teal)
                    }
                    if let vertexD = graphViewModel.graph.vertices.values.first(where: { $0.label == "D" }) {
                        let arrowPoint2 = CGPoint(x: vertexD.position.x + vertexD.offset.width / geometry2.size.width, y: vertexD.position.y + vertexD.offset.height / geometry2.size.height)
                        let adjustedArrowPoint2 = CGPoint(x: arrowPoint2.x * geometry2.size.width + 0.1 * geometry2.size.width, y: arrowPoint2.y * geometry2.size.height - 0.1 * geometry2.size.height)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.green)
                            .rotationEffect(Angle(radians: 5 * Double.pi / 6))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(adjustedArrowPoint2)
                        Text("vertex")
                            .position(CGPoint(x: adjustedArrowPoint2.x + 20, y: adjustedArrowPoint2.y - 25))
                            .foregroundStyle(Color.green)
                    }
                    if let vertexE = graphViewModel.graph.vertices.values.first(where: { $0.label == "E" }), let loop = graphViewModel.graph.edges.values.first(where: { $0.startVertexID == vertexE.id && $0.endVertexID == vertexE.id }) {
                        let edgeViewModel = EdgeViewModel(edge: loop, size: geometry2.size, graphViewModel: graphViewModel)
                        let arrowPoint3 = edgeViewModel.edgePath.pointOnBezierCurve(t: 0.75)
                        let adjustedArrowPoint3 = CGPoint(x: arrowPoint3.x * geometry2.size.width, y: arrowPoint3.y * geometry2.size.height)
                        ArrowLine()
                            .stroke(lineWidth: 5)
                            .foregroundStyle(Color.pink)
                            .rotationEffect(Angle(radians: Double.pi), anchor: UnitPoint(x: 0.75, y: 0.5))
                            .frame(width: geometry2.size.width * 0.2, height: geometry2.size.height * 0.2)
                            .position(adjustedArrowPoint3)
                        Text("loop")
                            .position(x: adjustedArrowPoint3.x + geometry2.size.width * 0.275, y: adjustedArrowPoint3.y)
                            .foregroundStyle(Color.pink)
                    }
                }
                .frame(height: UIScreen.main.bounds.width)
            }
        }
        .padding()
#endif
    }
}

#Preview {
    Terminology()
        .environmentObject(ThemeViewModel())
}
