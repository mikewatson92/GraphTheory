//
//  Matrix.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

struct Matrix {
    var grid: [Double?]
    let rows: Int
    let columns: Int
    static var zero = Matrix(rows: 1, cols: 1)
    
    init(rows: Int, cols columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    static func validDimensionsForMult(first: Matrix, second: Matrix) -> Bool {
        return first.columns == second.rows
    }
    
    subscript(row: Int, column: Int) -> Double? {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range!")
            return grid[(row * columns) + column] ?? nil
        } set {
            assert(indexIsValid(row: row, column: column), "Index is out of range!")
            grid[(row * columns) + column] = newValue
        }
    }
    
    public static func multiply(first: Matrix, second: Matrix) -> Matrix {
        assert(validDimensionsForMult(first: first, second: second), "Invalid matrix dimensions")
        var newMatrix = Matrix(rows: first.rows, cols: second.columns)
        for i in 0..<first.rows {
            for j in 0..<first.columns {
                for k in 0..<first.columns{
                    newMatrix[i,j]! += first[i,k]! * second[k,j]!
                }
            }
        }
        return newMatrix
    }
    
    public static func nthMatrix(matrix: Matrix, nMatrix: Matrix, power: Int) -> Matrix {
        if power == 1 {
            return nMatrix
        } else {
            let productMatrix = multiply(first: matrix, second: nMatrix)
            return nthMatrix(matrix: matrix, nMatrix: productMatrix, power: power - 1)
        }
    }
    
    
    public static func addMatrices(_ matrix1: Matrix, _ matrix2: Matrix) -> Matrix? {
        var returnMatrix = Matrix(rows: matrix1.rows, cols: matrix1.columns)
        guard (matrix1.rows == matrix2.rows && matrix1.columns == matrix2.columns) else { return nil }
        for i in 0..<matrix1.grid.count {
            returnMatrix.grid[i]! = matrix1.grid[i]! + matrix2.grid[i]!
        }
        return returnMatrix
    }
}
