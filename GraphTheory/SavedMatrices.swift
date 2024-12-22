//
//  SavedMatrices.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/22/24.
//

import SwiftUI

struct Prim1 {
    var matrix = Matrix2D(numberOfItems: 7)
    
    init() {
        matrix[0, 1] = 27
        matrix[0, 2] = 12
        matrix[0, 3] = 15
        matrix[0, 5] = 16
        matrix[1, 0] = 27
        matrix[1, 3] = 6
        matrix[2, 0] = 12
        matrix[2, 1] = 6
        matrix[2, 3] = 14
        matrix[2, 4] = 18
        matrix[3, 0] = 15
        matrix[3, 2] = 14
        matrix[3, 4] = 11
        matrix[3, 5] = 9
        matrix[4, 2] = 18
        matrix[4, 3] = 11
        matrix[4, 6] = 14
        matrix[5, 0] = 16
        matrix[5, 3] = 9
        matrix[5, 6] = 5
        matrix[6, 4] = 14
        matrix[6, 5] = 5
        matrix.vertexLabels = ["A", "B", "C", "D", "E", "F", "G"]
    }
}

struct Prim1View: View {
    @StateObject private var primViewModel = PrimTableViewModel(matrix: Prim1().matrix)
    
    var body: some View {
        PrimTableView(primViewModel: primViewModel)
    }
}
