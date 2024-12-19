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
    var itemLabels: [Double?]
    static let MAX_ITEMS = 10
    
    init(numberOfItems: Int) {
        self.numberOfItems = CGFloat(numberOfItems)
        self.vertexLabels = Array(repeating: "X", count: Matrix2D.MAX_ITEMS)
        self.itemLabels = Array(repeating: nil, count: Matrix2D.MAX_ITEMS * Matrix2D.MAX_ITEMS )
    }
    
    subscript(row: Int, column: Int) -> Double? {
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
            for index in 0..<Int(numberOfItems) {
                vertexLabels[index] = originalMatrix.vertexLabels[index]
            }

        }
        
        if difference > 0 {
            for row in 0..<Int(originalNumberOfItems) {
                for column in 0..<Int(originalNumberOfItems) {
                    self[row, column] = originalMatrix[row, column]
                }
            }
        } else if difference < 0 {
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
    var columnHeaderColors: [Color]
    var showColumnHeaders = false
    
    init(matrix: Matrix2D) {
        self.matrix = matrix
        self.columnHeaders = Array(repeating: "", count: Int(Matrix2D.MAX_ITEMS))
        self.columnHeaderColors = Array(repeating: Color.clear, count: Int(Matrix2D.MAX_ITEMS))
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
    let padding: CGFloat = CGFloat(15)
    
    var body: some View {
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let totalHorizontalPadding = 2 * padding
            let cellWidth = (width - totalHorizontalPadding) / (matrixViewModel.matrix.numberOfItems + 1)
            let cellHeight = (height - 6 * padding) / (matrixViewModel.matrix.numberOfItems + (matrixViewModel.showColumnHeaders ? 2 : 1))
            let cellSize = min(cellWidth, cellHeight)
            
            VStack(spacing: 0) {
                Slider(value: Binding(get: {matrixViewModel.matrix.numberOfItems}, set: {newValue in matrixViewModel.setNumberOfItems(Int(newValue))}), in: 1...10, step: 1)
                    .padding()
                if matrixViewModel.showColumnHeaders {
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: cellSize, height: cellSize)
                        ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { number in
                            GridItemView(label: Binding(get: {matrixViewModel.columnHeaders[number]}, set: {_ in }), weight: .constant(nil))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: cellSize, height: cellSize)
                    ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { column in
                        GridItemView(label: Binding(get: {matrixViewModel.matrix.vertexLabels[column]}, set: {newValue in matrixViewModel.matrix.vertexLabels[column] = newValue ?? "X"}), weight: .constant(nil))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
                ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { row in
                    HStack(spacing: 0) {
                        GridItemView(label: Binding(get: {matrixViewModel.matrix.vertexLabels[row]}, set: {newValue in matrixViewModel.matrix.vertexLabels[row] = newValue ?? "X"}), weight: .constant(nil))
                            .frame(width: cellSize, height: cellSize)
                        ForEach(0..<Int(matrixViewModel.matrix.numberOfItems), id: \.self) { column in
                            GridItemView(label: .constant(nil), weight: Binding(get: {matrixViewModel.matrix[row, column]}, set: {newValue in matrixViewModel.matrix[row, column] = newValue}))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .padding(padding)
        }
    }
}

struct GridItemView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Binding var label: String?
    @Binding var weight: Double?
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
                    ZStack {
                        Text(label)
                            .font(.system(size: 100)) // Start with a large font
                            .minimumScaleFactor(0.1) // Allow text to scale down
                            .lineLimit(1)            // Ensure the text stays on one line
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
                            .multilineTextAlignment(.center)
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .foregroundColor(themeViewModel.theme!.secondaryColor)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeViewModel.theme!.primaryColor, lineWidth: 5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                    }
                } else {
                    ZStack {
                        Text(weight != nil ? "\(weight?.formatted() ?? "0")" : "-")
                            .font(.system(size: 100)) // Start with a large font
                            .minimumScaleFactor(0.1) // Allow text to scale down
                            .lineLimit(1)            // Ensure the text stays on one line
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the available space
                            .multilineTextAlignment(.center)
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .foregroundColor(themeViewModel.theme!.secondaryColor)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeViewModel.theme!.primaryColor, lineWidth: 5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            .buttonStyle(.borderless)
        } else {
            if label != nil {
                TextField("Label:", text: Binding(
                    get: { label ?? "X" }, // Provide a default value when `label` is `nil`
                    set: { newValue in
                        label = newValue
                    }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                    .foregroundColor(themeViewModel.theme!.secondaryColor)
                    .onSubmit {
                        edittingLabel = false
                        if label == "" {
                            label = "X"
                        }
                    }
            } else {
                TextField("Weight:", value: $weight, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                    .foregroundColor(themeViewModel.theme!.secondaryColor)
                    .onSubmit {
                        edittingLabel = false
                    }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var matrixViewModel = Matrix2DViewModel(matrix: Matrix2D(numberOfItems: 3))
    Matrix2DView(matrixViewModel: matrixViewModel)
}
