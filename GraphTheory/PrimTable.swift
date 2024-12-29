//
//  PrimTable.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/22/24.
//

import SwiftUI

struct PrimTable {
    var matrix: Matrix2D
    var crossedOffRows: [Int] = []
    var availableWeightPositions: [(Int, Int)] = [] // The coordinates in the matrix corresponding to
    // weights the user can select.
    var step = Step.deleteRow
    var sumOfWeights = 0.0
    var numSelectedWeights = 0
    var availableWeights: [Double] {
        var weights: [Double] = []
        for (row, column) in availableWeightPositions {
            if let weight = matrix[row, column] {
                weights.append(weight)
            }
        }
        return weights
    }
    
    enum Step {
        case deleteRow
        case selectWeights
        case finished
    }
    
    mutating func deleteRow(index: Int) {
        if !crossedOffRows.contains(where: { $0 == index }) {
            // Add the row to the list of deleted rows
            crossedOffRows.append(index)
            if step == .deleteRow {
                step = .selectWeights
            } else if step == .selectWeights && numSelectedWeights == Int(matrix.numberOfItems) - 1 {
                step = .finished
            }
            // Add weights in the corresponding column that aren't crossed off
            for row in 0..<Int(matrix.numberOfItems) {
                if !crossedOffRows.contains(where: { $0 == row }) {
                    availableWeightPositions.append((row, index))
                }
            }
            // Remove weights in the crossed off row from
            // availableWeightPositions
            for column in 0..<Int(matrix.numberOfItems) {
                availableWeightPositions.removeAll(where: { ($0.0, $0.1) == (index, column) })
            }
        }
    }
    
    mutating func chooseWeight(row: Int, column: Int) -> Bool {
        guard matrix.indexIsValid(row: row, column: column) else { return false }
        guard availableWeightPositions.contains(where: { ($0.0, $0.1) == (row, column) }) else { return false }
        guard !availableWeights.isEmpty else { return false }
        guard availableWeights.sorted(by: { $0 <= $1 })[0] == matrix[row, column] else { return false }
        guard matrix[row, column] != nil else { return false }
        guard step == .selectWeights else { return false }
        sumOfWeights += matrix[row, column]!
        deleteRow(index: row)
        numSelectedWeights += 1
        
        if numSelectedWeights == Int(matrix.numberOfItems) - 1 {
            step = .finished
        }
        
        return true
    }
}

class PrimTableViewModel: ObservableObject {
    @Published var prim: PrimTable
    var colors: [Color] = [Color(#colorLiteral(red: 1, green: 0, blue: 0.909978807, alpha: 1)), Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.602193892, green: 0, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 1, green: 0, blue: 0.08336835355, alpha: 1)), Color(#colorLiteral(red: 0.5639209747, green: 1, blue: 0.8105410933, alpha: 1))]
    @Published var headerNumbers: [Int?]
    @Published var rowHeaderColors: [Color]
    @Published var itemColors: [Color]
    var numberLabeledColumns = 0
    
    init(matrix: Matrix2D) {
        self.prim = PrimTable(matrix: matrix)
        self.headerNumbers = Array(repeating: nil, count: Int(matrix.numberOfItems))
        self.rowHeaderColors = Array(repeating: .clear, count: Int(matrix.numberOfItems))
        self.itemColors = Array(repeating: .clear, count: Int(matrix.numberOfItems * matrix.numberOfItems))
    }
    
    func chooseWeight(row: Int, column: Int) {
        if prim.step == .selectWeights {
            if prim.chooseWeight(row: row, column: column) {
                itemColors[getIndex(row: row, column: column)] = colors[0]
                colors.remove(at: 0)
                if prim.step != .finished {
                    rowHeaderColors[row] = colors[0]
                    headerNumbers[row] = numberLabeledColumns + 1
                    numberLabeledColumns += 1
                }
            }
        }
    }
    
    func deleteRow(_ row: Int) {
        if prim.step == .deleteRow {
            prim.deleteRow(index: row)
            rowHeaderColors[row] = colors[0]
            
            headerNumbers[row] = 1
            numberLabeledColumns += 1
            prim.step = .selectWeights
        }
    }
    
    func getIndex(row: Int, column: Int) -> Int {
        return row * Int(prim.matrix.numberOfItems) + column
    }
}

struct PrimTableView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @StateObject var primViewModel: PrimTableViewModel
    @State private var showBanner = false
    let padding: CGFloat = CGFloat(15)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let width = geometry.size.width
                let height = geometry.size.height
                let totalHorizontalPadding = 2 * padding
                let cellWidth = (width - totalHorizontalPadding) / (primViewModel.prim.matrix.numberOfItems + 1)
                let cellHeight = (height - 4 * padding) / (primViewModel.prim.matrix.numberOfItems + 2)
                let cellSize = min(cellWidth, cellHeight)
                
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        // The column headers
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: cellSize, height: cellSize)
                            ForEach(0..<Int(primViewModel.prim.matrix.numberOfItems), id: \.self) { column in
                                GridItemView(label: .constant(nil), weight: Binding(get: { primViewModel.headerNumbers[column].map { Double($0)} }, set: { _ in }), color: Binding(get: { primViewModel.rowHeaderColors[column] }, set: {_ in}), mode: .normal)
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                        // The vertex column labels
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: cellSize, height: cellSize)
                            ForEach(0..<Int(primViewModel.prim.matrix.numberOfItems), id: \.self) { column in
                                GridItemView(label: Binding(get: {primViewModel.prim.matrix.vertexLabels[column]}, set: {newValue in primViewModel.prim.matrix.vertexLabels[column] = newValue ?? "X"}), weight: .constant(nil), mode: .normal)
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                        ForEach(0..<Int(primViewModel.prim.matrix.numberOfItems), id: \.self) { row in
                            ZStack {
                                HStack(spacing: 0) {
                                    GridItemView(label: Binding(get: {primViewModel.prim.matrix.vertexLabels[row]}, set: {newValue in primViewModel.prim.matrix.vertexLabels[row] = newValue ?? "X"}), weight: .constant(nil), mode: .normal, customAction: { primViewModel.deleteRow(row) })
                                        .frame(width: cellSize, height: cellSize)
                                    ForEach(0..<Int(primViewModel.prim.matrix.numberOfItems), id: \.self) { column in
                                        GridItemView(label: .constant(nil), weight: Binding(get: {primViewModel.prim.matrix[row, column]}, set: {newValue in primViewModel.prim.matrix[row, column] = newValue}), color: Binding(get: { primViewModel.itemColors[primViewModel.getIndex(row: row, column: column)] }, set: {_ in}), mode: .normal, customAction: { primViewModel.chooseWeight(row: row, column: column)
                                            if primViewModel.prim.step == .finished {
                                                withAnimation {
                                                    showBanner = true
                                                }
                                            }
                                        })
                                        .frame(width: cellSize, height: cellSize)
                                    }
                                }
                                Rectangle()
                                    .frame(width: cellSize * (primViewModel.prim.matrix.numberOfItems + 1), height: cellWidth / 25)
                                    .foregroundColor(primViewModel.rowHeaderColors[row])
                            }
                        }
                    }
                    Spacer()
                }
            }
            if showBanner {
                HStack {
                    Spacer()
                    Text("The weight of the minimum spanning tree is: \(primViewModel.prim.sumOfWeights.formatted()).")
                        .foregroundColor(themeViewModel.theme!.primaryColor)
                        .padding()
                        .background(themeViewModel.theme!.secondaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .transition(.move(edge: .top))
                Spacer()
            }
        }
        .padding(padding)
    }
}

#Preview {
    //PrimTableView()
}
