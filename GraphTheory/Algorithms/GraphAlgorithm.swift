//
//  GraphAlgorithm.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import Foundation

enum GraphAlgorithm: String, Identifiable, CaseIterable {
    case none = "none"
    case kruskal = "Kruskal's Algorithm"
    case prim = "Prim's Algorithm"
    case primTable = "Prim's Table Algorithm"
    case tsp = "Travelling Salesman Problem"
    case chinesePostman = "Chinese Postman Problem"
    case euler = "Eulerian Circuit"
    
    var id: Self { self }
}
