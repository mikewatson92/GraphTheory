//
//  Vertex.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI

struct Vertex: Identifiable, Codable {
    let id: UUID
    var position: CGPoint = .zero
    var offset: CGSize = .zero
    var color: Color?
    var strokeColor: Color = Color.secondary
    var label: String = ""
    var labelColor: LabelColor?
    
    init() {
        self.id = UUID()
    }
    
    init(position: CGPoint) {
        self.id = UUID()
        self.position = position
    }
    
    enum LabelColor: String, CaseIterable, Identifiable {
        case white = "white"
        case blue = "blue"
        case red = "red"
        case green = "green"
        case black = "black"
        
        var id: String { self.rawValue }
    }
    
    // Custom Codable implementation for `Color`
    enum CodingKeys: String, CodingKey {
        case id, position, color
    }
    
    mutating func setOffset(_ size: CGSize) {
        offset = size
    }
}

class VertexViewModel: ObservableObject {
    @Published private var vertex: Vertex
    @Published var graphViewModel: GraphViewModel
    var mode: [Mode]
    
    init(vertex: Vertex, graphViewModel: GraphViewModel, mode: [Mode] = [.editLabels, .showLabels])
    {
        self.vertex = vertex
        self.graphViewModel = graphViewModel
        self.mode = mode
    }
    
    var color: Color? {
        get { vertex.color }
        set {
            vertex.color = newValue
            graphViewModel.setColor(vertex: vertex, color: newValue)
        }
    }
    
    var strokeColor: Color {
        vertex.strokeColor
    }
    
    enum Mode {
        case editLabels, noEditLabels, showLabels, hideLabels
    }
    
    func getVertexID() -> UUID {
        return vertex.id
    }
    
    func getLabelColor() -> Vertex.LabelColor? {
        vertex.labelColor
    }
    
    func setLabelColor(_ color: Vertex.LabelColor) {
        graphViewModel.setVertexLabelColor(id: vertex.id, labelColor: color)
    }
    
    func getPosition() -> CGPoint? {
        graphViewModel.getVertexByID(vertex.id)?.position
    }
    
    func setPosition(_ position: CGPoint) {
        graphViewModel.setVertexPosition(vertex: vertex, position: position)
    }
    
    func getOffset() -> CGSize? {
        graphViewModel.getGraph().getOffsetByID(vertex.id)
    }
    
    func setOffset(size: CGSize) {
        graphViewModel.setVertexOffset(vertex: vertex, size: size)
    }
    
    func setColor(vertexID: UUID, color: Color) {
        self.color = color
        graphViewModel.setColor(vertex: graphViewModel.getVertexByID(vertexID)!, color: color)
    }
    
    func getLabel() -> String {
        graphViewModel.getVertexByID(vertex.id)?.label ?? ""
    }
    
    func setLabel(_ newLabel: String) {
        graphViewModel.setVertexLabel(id: vertex.id, label: newLabel)
        vertex.label = newLabel
    }
}

struct VertexView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vertexViewModel: VertexViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var latexSize = CGSize(width: 1, height: 1)
    @State private var edittingLabel: Bool = false
    @State private var tempLabelColor: Vertex.LabelColor? {
        willSet {
            vertexViewModel.graphViewModel.setVertexLabelColor(id: vertexViewModel.getVertexID(), labelColor: newValue!)

        }
    }
    var colorLatexString: String { "\\textcolor{\(vertexViewModel.getLabelColor()?.rawValue ?? (colorScheme == .light ? "white" : "black"))}{\(vertexViewModel.getLabel())}"
    }
    var labelColor : Color {
        get {
            switch vertexViewModel.getLabelColor() {
            case nil:
                return colorScheme == .light ? .white : .black
            case .white:
                return Color.white
            case .blue:
                return Color.blue
            case .red:
                return Color.red
            case .green:
                return Color.green
            case .black:
                return Color.black
            }
        }
    }
    let size: CGSize
    var mode: [VertexViewModel.Mode] {
        get {
            vertexViewModel.mode
        } set {
            vertexViewModel.mode = newValue
        }
    }
    
    init(vertexViewModel: VertexViewModel, size: CGSize) {
        _vertexViewModel = .init(wrappedValue: vertexViewModel)
        self.size = size
    }
    
    var body: some View {
        Group {
            if let position = vertexViewModel.getPosition(), let offset = vertexViewModel.getOffset() {
                Group {
                    Circle()
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                        .frame(width: 20, height: 20)
#elseif os(iOS)
                        .frame(width: 40, height: 40)
#endif
                        .foregroundStyle(vertexViewModel.color ?? (colorScheme == .light ? .black : .white))
                    
                    Circle()
                        .stroke(vertexViewModel.strokeColor)
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                        .frame(width: 20, height: 20)
#elseif os(iOS)
                        .frame(width: 40, height: 40)
#endif
                }
                .onLongPressGesture {
                    if mode.contains(.editLabels) {
                        isTextFieldFocused = true
                        edittingLabel = true
                    }
                }
                
                if !edittingLabel && mode.contains(.showLabels) {
                    #if os(macOS)
                    StrokeText(text: vertexViewModel.getLabel(), color: labelColor)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .position(x: vertexViewModel.getPosition()!.x * size.width + vertexViewModel.getOffset()!.width, y: vertexViewModel.getPosition()!.y * size.height + vertexViewModel.getOffset()!.height)
                        .onLongPressGesture {
                            isTextFieldFocused = true
                            edittingLabel = true
                        }
                    #elseif os(iOS)
                    LaTeXView(latex: colorLatexString, size: $latexSize)
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .offset(x: position.x * size.width + offset.width - latexSize.width / 5, y: position.y * size.height + offset.height - latexSize.height / 5)
                        .onLongPressGesture {
                            isTextFieldFocused = true
                            edittingLabel = true
                        }
                    #endif
                } else if mode.contains(.editLabels) {
                    TextField("", text: Binding(get: {vertexViewModel.getLabel()}, set: {newValue in vertexViewModel.setLabel(newValue)}))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
                        .frame(width: 200, height: 20)
                        .focused($isTextFieldFocused)
#if os(iOS)
                        .keyboardType(UIKeyboardType.default)
#endif
                        .onSubmit {
                            isTextFieldFocused = false
                            edittingLabel = false
                        }
                }
            }
        }
        .onAppear {
            tempLabelColor = (colorScheme == .light ? .white : .black)
        }
    }
}

#Preview {
    let vertex = Vertex(position: CGPoint(x: 0.5, y: 0.5))
    let graph = Graph(vertices: [vertex], edges: [])
    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: GraphViewModel(graph: graph))
    GeometryReader { geometry in
        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
    }
}
