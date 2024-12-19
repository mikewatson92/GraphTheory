//
//  2DMatrix.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/16/24.
//

import SwiftUI

struct Matrix2D {
    // numberOfItems is actually the number of rows (or columns) of a square matrix
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
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < Int(numberOfItems) && column >= 0 && column < Int(numberOfItems)
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
    
    init(matrix: Matrix2D) {
        self.matrix = matrix
    }
    
    func setNumberOfItems(_ n: Int) {
        matrix.setNumberOfItems(n)
    }
}

struct Matrix2DView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @ObservedObject var matrixViewModel: Matrix2DViewModel
    @State private var showPrimsAlgorithm = false
    let showSlider = true
    let padding: CGFloat = CGFloat(15)
    
    func clear() {
        matrixViewModel.setNumberOfItems(3)
        matrixViewModel.matrix.vertexLabels = Array(repeating: "X", count: Matrix2D.MAX_ITEMS)
        matrixViewModel.matrix.itemLabels = Array(repeating: nil, count: Matrix2D.MAX_ITEMS * Matrix2D.MAX_ITEMS )
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let totalHorizontalPadding = 2 * padding
            let cellWidth = (width - totalHorizontalPadding) / (matrixViewModel.matrix.numberOfItems + 1)
            let cellHeight = (height - 6 * padding) / (matrixViewModel.matrix.numberOfItems + 1)
            let cellSize = min(cellWidth, cellHeight)
            
            VStack(spacing: 0) {
                if showSlider {
                    Slider(value: Binding(get: {matrixViewModel.matrix.numberOfItems}, set: {newValue in matrixViewModel.setNumberOfItems(Int(newValue))}), in: 1...10, step: 1)
                        .padding()
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
            .navigationDestination(isPresented: $showPrimsAlgorithm) {
                PrimTableView(primViewModel: PrimTableViewModel(matrix: matrixViewModel.matrix))
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { clear() }) {
                        Image(systemName: "arrow.uturn.left.circle")
                            .tint(themeViewModel.theme!.accentColor)
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: { showPrimsAlgorithm = true }) {
                        Image(systemName: "flask")
                            .tint(themeViewModel.theme!.accentColor)
                    }
                }
            }
        }
    }
}

struct GridItemView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Binding var label: String?
    @Binding var weight: Double?
    @Binding var color: Color
    @State private var edittingLabel = false
    var mode = Mode.editLabels
    var customAction: (() -> Void)?
    
    init(label: Binding<String?> = .constant(nil), weight: Binding<Double?> = .constant(nil), color: Binding<Color> = .constant(Color.clear), mode: Mode = .editLabels, customAction: (() -> Void)? = nil) {
        self._label = label
        self._weight = weight
        self._color = color
        self.mode = mode
        self.customAction = customAction
    }
    
    enum Mode {
        case editLabels
        case normal
    }
    
    var body: some View {
        if !edittingLabel {
            Button(action: {
                if mode == .editLabels {
                    edittingLabel = true
                } else if customAction != nil {
                    customAction!()
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
                        Circle()
                            .stroke(color, lineWidth: 5)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fill)
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
                        Circle()
                            .stroke(color, lineWidth: 5)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fill)
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
