//
//  PrimTableModel1.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

import SwiftUI

struct PrimTableModel1: View {
    var matrix: Matrix = Matrix(rows: 7, cols: 7)
    init() {
        matrix[0,0] = nil
        matrix[0,1] = 27
        matrix[0,2] = 12
        matrix[0,3] = 15
        matrix[0,4] = nil
        matrix[0,5] = 16
        matrix[0,6] = nil
        matrix[1,0] = 27
        matrix[1,1] = nil
        matrix[1,2] = 6
        matrix[1,3] = nil
        matrix[1,4] = nil
        matrix[1,5] = nil
        matrix[1,6] = nil
        matrix[2,0] = 12
        matrix[2,1] = 6
        matrix[2,2] = nil
        matrix[2,3] = 14
        matrix[2,4] = 18
        matrix[2,5] = nil
        matrix[2,6] = nil
        matrix[3,0] = 15
        matrix[3,1] = nil
        matrix[3,2] = 14
        matrix[3,3] = nil
        matrix[3,4] = 11
        matrix[3,5] = 9
        matrix[3,6] = nil
        matrix[4,0] = nil
        matrix[4,1] = nil
        matrix[4,2] = 18
        matrix[4,3] = 11
        matrix[4,4] = nil
        matrix[4,5] = nil
        matrix[4,6] = 14
        matrix[5,0] = 16
        matrix[5,1] = nil
        matrix[5,2] = nil
        matrix[5,3] = 9
        matrix[5,4] = nil
        matrix[5,5] = nil
        matrix[5,6] = 5
        matrix[6,0] = nil
        matrix[6,1] = nil
        matrix[6,2] = nil
        matrix[6,3] = nil
        matrix[6,4] = 14
        matrix[6,5] = 5
        matrix[6,6] = nil
    }
    
    var body: some View {
        PrimTable(matrix: matrix)
            .navigationTitle("Prim's Table")
    }

}
