//
//  2DMatrix.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/16/24.
//

import SwiftUI

struct Matrix2D {
    private(set) var numberOfItems: CGFloat
    var vertexLabels: [String]
    var itemLabels: [Int?]
    static let MAX_ITEMS = 10
    
    init(numberOfItems: Int) {
        self.numberOfItems = CGFloat(numberOfItems)
        self.vertexLabels = Array(repeating: "X", count: Matrix2D.MAX_ITEMS)
        self.itemLabels = Array(repeating: nil, count: Matrix2D.MAX_ITEMS * Matrix2D.MAX_ITEMS )
    }
    
    subscript(row: Int, column: Int) -> Int? {
        get {
            itemLabels[row * Int(numberOfItems) + column]
        } set {
            itemLabels[row * Int(numberOfItems) + column] = newValue
        }
    }
    
    mutating func setNumberOfItems(_ n: Int) {
        let originalMatrix = self
        let originalNumberOfItems = numberOfItems
        numberOfItems = max(1, min(10, CGFloat(n)))
        let difference = n - Int(originalNumberOfItems)
        
        if difference != 0 {
            for index in 0..<Matrix2D.MAX_ITEMS {
                itemLabels[index] = nil
                vertexLabels[index] = "X"
            }
            for index in 0..<(Matrix2D.MAX_ITEMS * Matrix2D.MAX_ITEMS) {
                itemLabels[index] = nil
            }
        }
        
        if difference > 0 {
            for index in 0..<Int(numberOfItems) {
                vertexLabels[index] = originalMatrix.vertexLabels[index]
            }
            for row in 0..<Int(originalNumberOfItems) {
                for column in 0..<Int(originalNumberOfItems) {
                    self[row, column] = originalMatrix[row, column]
                }
            }
        } else if difference < 0 {
            for index in 0..<Int(numberOfItems) {
                vertexLabels[index] = originalMatrix.vertexLabels[index]
            }
            for row in 0..<n {
                for column in 0..<n {
                    self[row, column] = originalMatrix[row, column]
                }
            }
        }
    }
}

class Matrix2DViewModel: ObservableObject {
    @Published var matrix: Matrix2D
    var columnHeaders: [String]
    
    init(matrix: Matrix2D) {
        self.matrix = matrix
        self.columnHeaders = Array(repeating: "", count: Int(matrix.numberOfItems))
    }
    
    func setNumberOfItems(_ n: Int) {
        if n > Int(matrix.numberOfItems) {
            for _ in 1...(n - Int(matrix.numberOfItems)) {
                columnHeaders.append("")
            }
        } else if n < Int(matrix.numberOfItems) {
            for _ in 1...(Int(matrix.numberOfItems) - n) {
                columnHeaders.removeLast()
            }
        }
        matrix.setNumberOfItems(n)
    }
}

struct Matrix2DView: View {
    @ObservedObject var matrixViewModel: Matrix2DViewModel
    let padding: CGFloat = 15
    
    var body: some View {
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let cellSize = (width - CGFloat(padding) * 2) / (matrixViewModel.matrix.numberOfItems + 1)
            
            VStack {
                Slider(value: Binding(get: {matrixViewModel.matrix.numberOfItems}, set: {newValue in matrixViewModel.setNumberOfItems(Int(newValue))}), in: 1...10, step: 1)
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: cellSize, height: cellSize)
                        .border(Color.black, width: 2)
                    ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { column in
                        GridItemView(label: Binding(get: {matrixViewModel.matrix.vertexLabels[column]}, set: {newValue in matrixViewModel.matrix.vertexLabels[column] = newValue ?? "X"}), weight: .constant(nil))
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.black, width: 2)
                    }
                }
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: cellSize, height: cellSize)
                        .border(Color.black, width: 2)
                    ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { number in
                        GridItemView(label: Binding(get: {matrixViewModel.columnHeaders[number]}, set: {newValue in matrixViewModel.columnHeaders[number] = newValue ?? "X"}), weight: .constant(nil))
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.black, width: 2)
                    }
                }
                ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { row in
                    HStack(spacing: 0) {
                        GridItemView(label: Binding(get: {matrixViewModel.matrix.vertexLabels[row]}, set: {newValue in matrixViewModel.matrix.vertexLabels[row] = newValue ?? "X"}), weight: .constant(nil))
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.black, width: 2)
                        ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { column in
                            GridItemView(label: .constant(nil), weight: Binding(get: {matrixViewModel.matrix[row, column]}, set: {newValue in matrixViewModel.matrix[row, column] = newValue}))
                                .frame(width: cellSize, height: cellSize)
                                .border(Color.black, width: 2)
                        }
                    }
                }
            }
            .padding([.leading, .trailing], padding)
        }
    }
}

struct GridItemView: View {
    @Binding var label: String?
    @Binding var weight: Int?
    @State private var edittingLabel = false
    @State private var mode = Mode.editLabels
    
    enum Mode {
        case editLabels
        case normal
    }
    
    var body: some View {
        if !edittingLabel {
            Button(action: {
                if mode == .editLabels {
                    edittingLabel = true
                }
            }) {
                if let label = label {
                    Text(label)
                        .font(.system(size: 100)) // Start with a large font
                        .minimumScaleFactor(0.1) // Allow text to scale down
                        .lineLimit(1)            // Ensure the text stays on one line
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(Color.primary)
                } else {
                    Text(weight != nil ? "\(weight ?? 0)" : "-")
                        .font(.system(size: 100)) // Start with a large font
                        .minimumScaleFactor(0.1) // Allow text to scale down
                        .lineLimit(1)            // Ensure the text stays on one line
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(Color.primary)
                }
            }
        } else {
            if label != nil {
                TextField("Label:", text: Binding(get: { label! }, set: {newValue in label = newValue.isEmpty ? nil : newValue}))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                    .onSubmit {
                        edittingLabel = false
                    }
            } else {
                TextField("Weight:", value: Binding(get: { weight }, set: {newValue in weight = newValue}), format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                    .onSubmit {
                        edittingLabel = false
                    }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var matrixViewModel = Matrix2DViewModel(matrix: Matrix2D(numberOfItems: 1))
    Matrix2DView(matrixViewModel: matrixViewModel)
}
