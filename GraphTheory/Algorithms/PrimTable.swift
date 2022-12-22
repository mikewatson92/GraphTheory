//
//  PrimTable.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

class PrimTableModel: ObservableObject {
    @Published var status: Status
    @Published var hLineColor: [Color]
    @Published var circleRowColor: [Color]
    @Published var colColor: [Color]
    @Published var numColor: [[Color]]
    @Published var numLabelRow: [Int]
    @Published var availableColumns: [Int] = []
    @Published var selectedCellNumbers: [[Int]] = [[]]
    @Published var cells: [[Cell]] = [[]]
    @Published var totalWeight: Double = 0
    var step = 0
    var almostFinished: Bool { step == numVertices - 1 }
    var rowsUsed: [Int] = []
    let numVertices: Int
    let colors = [Color(red: 1, green: 0.2, blue: 0.5),
                  Color(red: 0.8, green: 0.3, blue: 1),
                  Color(red: 0, green: 0.5, blue: 1),
                  Color(red: 0, green: 1, blue: 0),
                  Color(red: 0.4, green: 0, blue: 1),
                  Color(red: 0.2, green: 0.6, blue: 0.2),
                  Color(red: 0.8, green: 0.5, blue: 0),
                  Color(red: 0, green: 0, blue: 1),
                  Color(red: 1, green: 0.9, blue: 0.2),
                  Color(red: 1, green: 0, blue: 0)
    ]
    var matrix: Matrix
    
    enum Status {
        case notStarted, started, inProgress, finished
    }
    
    init(matrix: Matrix, status: Status = .notStarted) {
        self.matrix = matrix
        self.status = status
        self.numVertices = matrix.rows
        self.hLineColor = Array(repeating: .clear, count: matrix.rows + 2)
        self.circleRowColor = Array(repeating: .clear, count: matrix.rows + 1)
        self.numColor = Array(repeating: Array(repeating: .clear, count: matrix.rows + 1), count: matrix.rows + 2)
        self.colColor = Array(repeating: .clear, count: matrix.rows)
        self.numLabelRow = Array(repeating: 0, count: numVertices + 1)
    }
    
    func getLeastWeight() -> Double {
        var leastWeight: Double?
        for col in availableColumns {
            for row in 0..<matrix.rows {
                if !rowsUsed.contains(row + 2) {
                    let value = matrix[row, col - 1]
                    if value != nil {
                        if leastWeight == nil {
                            leastWeight = value!
                        } else if value! <= leastWeight! {
                            leastWeight = value!
                        }
                    }
                }
            }
        }
        return leastWeight!
    }
    
    func checkButton(row: Int, col: Int) {
        if status == .started {
            if col == 0 && row > 1 {
                rowsUsed.append(row)
                availableColumns.append(row - 1)
                status = .inProgress
                hLineColor[row] = colors[0]
                circleRowColor[row - 1] = colors[0]
                numLabelRow[row - 1] = step + 1
                step += 1
            }
        } else if status == .inProgress {
            if col > 0 && row > 1 { // If it is a number cell
                let weight = matrix[row - 2, col - 1]
                if !rowsUsed.contains(row) && availableColumns.contains(col) {
                    if weight != nil && weight! <= getLeastWeight() {
                        totalWeight += weight!
                        numColor[row][col] = colors[step - 1]
                        rowsUsed.append(row)
                        availableColumns.append(row - 1)
                        hLineColor[row] = colors[step]
                        if !almostFinished {
                            circleRowColor[row - 1] = colors[step]
                        }
                        numLabelRow[row - 1] = step + 1
                        step += 1
                        if step == numVertices { status = .finished }
                    }
                }
            }
        }
        if status == .finished {
            disableAllCells()
        }
    }
    
    func disableAllCells() {
        for row in 0..<cells.count {
            for col in 0..<cells[row].count {
                cells[row][col].disabled = true
            }
        }
    }
}

struct Cell: View {
    @ObservedObject var prim: PrimTableModel
    @State var text: String?
    @State var number: Double?
    @State var style: Style
    @State var row: Int
    @State var col: Int
    @State var disabled: Bool = false
    var blankCellNumber: Int = 0
    enum Style {
        case text, number, blank, hidden
    }
    
    init(prim: PrimTableModel, row: Int, col: Int, hidden: Bool = false) {
        self.prim = prim
        self.row = row
        self.col = col
        if hidden {
            self.style = .hidden
        } else {
            self.style = .blank
        }
    }
    
    init(prim: PrimTableModel, row: Int, col: Int, text: String) {
        self.prim = prim
        self.row = row
        self.col = col
        self.text = text
        self.style = .text
    }
    
    init(prim: PrimTableModel, row: Int, col: Int, number: Double) {
        self.prim = prim
        self.row = row
        self.col = col
        self.number = number
        self.style = .number
    }
    
    
    var body: some View {
        switch self.style {
        case .text:
            Button() {
                // Do something
                prim.checkButton(row: row, col: col)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .aspectRatio(1.0, contentMode: ContentMode.fit)
                    Text(self.text!)
                        .foregroundColor(.white)
                }
            }
            .foregroundStyle(darkGradient)
            .buttonStyle(.plain)
            .disabled(disabled)
        case .number:
            Button() {
                // Do something
                prim.checkButton(row: row, col: col)
                
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .aspectRatio(1.0, contentMode: ContentMode.fit)
                        .backgroundStyle(darkGradient)
                    Text("\(self.number!.removeZerosFromEnd())")
                        .foregroundColor(.white)
                }
            }
            .foregroundStyle(darkGradient)
            .buttonStyle(.plain)
            .overlay {
                Circle()
                    .stroke(prim.numColor[row][col], lineWidth: 5)
                    .padding()
            }
            .disabled(disabled)
        case .blank:
            Button() {
                // Do nothing
            } label: {
                RoundedRectangle(cornerRadius: 5)
                    .aspectRatio(1.0, contentMode: ContentMode.fit)
                    .backgroundStyle(darkGradient)
            }
            .foregroundStyle(darkGradient)
            .buttonStyle(.plain)
            .overlay{
                ZStack{
                    Circle()
                        .stroke(prim.circleRowColor[col], lineWidth: 5)
                        .padding()
                    Text("\(prim.numLabelRow[col])")
                        .foregroundColor(prim.circleRowColor[col])
                }
            }
            .disabled(disabled)
        case .hidden:
            Button() {
                // Do nothing
            } label: {
                RoundedRectangle(cornerRadius: 5)
                    .aspectRatio(1.0, contentMode: ContentMode.fit)
                    .hidden()
            }
            .foregroundStyle(darkGradient)
            .buttonStyle(.plain)
            .disabled(disabled)
        }
    }
}

struct PrimTable: View {
    @StateObject var prim: PrimTableModel
    let vertices = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    var matrix: Matrix
    let rows: Int
    
    init(matrix: Matrix) {
        _prim = .init(wrappedValue: PrimTableModel(matrix: matrix, status: .started))
        self.matrix = matrix
        self.rows = matrix.rows
        
    }
    
    var body: some View {
        
        ZStack{
            if prim.status == .finished {
                Rectangle()
                    .foregroundStyle(blueGradient)
            } else {
                Rectangle()
                    .foregroundColor(darkGray)
            }
            VStack{
                Text("Path weight = \(prim.totalWeight.removeZerosFromEnd())")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
                Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                    ForEach(0..<rows + 2, id: \.self) { row in
                        GridRow {
                            if !prim.cells[0].isEmpty {
                                ForEach(0..<rows + 1, id: \.self) { col in
                                    prim.cells[row][col]
                                }
                            }
                        }
                        .overlay{
                            GeometryReader{ geometry in
                                let length = geometry.size.width
                                Rectangle()
                                    .frame(width: length, height: 5)
                                    .position(x: length  / 2, y: length / 2)
                                    .foregroundColor(prim.hLineColor[row])
                            }
                        }
                    }
                }
                .onAppear {
                    initCellModel()
                    updateCellModel()
                }
                .padding()
            }
        }
    }
    
    func initCellModel() {
        prim.cells = Array(repeating: Array(repeating: Cell(prim: PrimTableModel(matrix: Matrix.zero, status: .notStarted), row: 0, col: 0), count: rows + 1), count: rows + 2)
    }
    
    func updateCellModel() {
        prim.cells[0][0] = Cell(prim: prim, row: 0, col: 0, hidden: true)
        for col in 0..<rows {
            prim.cells[0][col + 1] = Cell(prim: prim, row: 0, col: col + 1)
        }
        prim.cells[1][0] = Cell(prim: prim, row: 1, col: 0, hidden: true)
        for col in 0..<rows {
            prim.cells[1][col + 1] = Cell(prim: prim, row: 1, col: col + 1, text: vertices[col])
        }
        for row in 0..<rows {
            prim.cells[row + 2][0] = Cell(prim: prim, row: row + 2, col: 0, text: vertices[row])
            for col in 0..<rows {
                let value = matrix[row, col]
                if value == nil {
                    prim.cells[row + 2][col + 1] = Cell(prim: prim, row: row + 2, col: col + 1, text: "-")
                } else {
                    prim.cells[row + 2][col + 1] = Cell(prim: prim, row: row + 2, col: col + 1, number: value!)
                }
            }
        }
    }
}


/*
 struct PrimTable_Previews: PreviewProvider {
 static var previews: some View {
 PrimTable()
 }
 }
 */
