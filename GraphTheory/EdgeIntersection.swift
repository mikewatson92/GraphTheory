//
//  EdgeIntersection.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import Foundation

struct EdgeIntersection {
    static func intersects(_ edge1: Edge, _ edge2: Edge, graphViewModel: GraphViewModel) -> Bool {
        let size = CGSize(width: 1, height: 1)
        let epsilon = 1e-2
        let edge1ViewModel = EdgeViewModel(edge: edge1, size: size, graphViewModel: graphViewModel)
        let edge2ViewModel = EdgeViewModel(edge: edge2, size: size, graphViewModel: graphViewModel)
        var parameters: [CGFloat] = []
        for i in 15..<85 {
            parameters.append(CGFloat(i) / CGFloat(99))
        }
        var edge1Coordinates: [CGPoint] = []
        var edge2Coordinates: [CGPoint] = []
        for parameter in parameters {
            edge1Coordinates.append(edge1ViewModel.edgePath.pointOnBezierCurve(t: parameter))
            edge2Coordinates.append(edge2ViewModel.edgePath.pointOnBezierCurve(t: parameter))
        }
        for point1 in edge1Coordinates {
            if edge2Coordinates.contains(where: { abs(point1.x - $0.x) < epsilon && abs(point1.y - $0.y) < epsilon }) {
                return true
            }
        }
        return false
    }
}
