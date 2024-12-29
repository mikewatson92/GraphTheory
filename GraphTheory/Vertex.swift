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
    var opacity = 1.0
    
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
}

class VertexViewModel: ObservableObject {
    @Published private(set) var vertex: Vertex
    @Published var graphViewModel: GraphViewModel
    var id: UUID {
        get {
            vertex.id
        }
    }
    var label: String {
        get {
            vertex.label
        } set {
            vertex.label = newValue
            graphViewModel.setVertexLabel(id: vertex.id, label: newValue)
        }
    }
    var labelColor: Vertex.LabelColor? {
        get {
            vertex.labelColor
        } set {
            vertex.labelColor = newValue
            graphViewModel.setVertexLabelColor(id: vertex.id, labelColor: newValue!)
        }
    }
    var mode: [Mode]
    var position: CGPoint {
        get {
            graphViewModel.graph.vertices[vertex.id]?.position ?? CGPoint.zero
        } set {
            vertex.position = newValue
            graphViewModel.setVertexPosition(vertex: vertex, position: newValue)
        }
    }
    var offset: CGSize {
        get {
            vertex.offset
        } set {
            vertex.offset = newValue
            graphViewModel.setVertexOffset(vertex: vertex, size: newValue)
        }
    }
    var opacity: Double {
        get {
            vertex.opacity
        } set {
            vertex.opacity = newValue
        }
    }
    var color: Color? {
        get { vertex.color }
        set {
            vertex.color = newValue
            graphViewModel.setVertexColor(vertex: vertex, color: newValue!)
        }
    }
    var strokeColor: Color {
        vertex.strokeColor
    }
    
    init(vertex: Vertex, graphViewModel: GraphViewModel, mode: [Mode] = [.editLabels, .showLabels])
    {
        self.vertex = vertex
        self.graphViewModel = graphViewModel
        self.mode = mode
    }
    
    enum Mode {
        case editLabels, noEditLabels, showLabels, hideLabels
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
            vertexViewModel.graphViewModel.setVertexLabelColor(id: vertexViewModel.id, labelColor: newValue!)
            
        }
    }
    var colorLatexString: String { "\\textcolor{\(vertexViewModel.labelColor?.rawValue ?? (colorScheme == .light ? "white" : "black"))}{\(vertexViewModel.label)}"
    }
    var labelColor : Color {
        get {
            switch vertexViewModel.labelColor {
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
        let position = vertexViewModel.position
        let offset = vertexViewModel.offset
        
        Group {
            Circle()
                .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                .frame(width: 20, height: 20)
#elseif os(iOS)
                .frame(width: 40, height: 40)
#endif
                .foregroundStyle(vertexViewModel.color ?? (colorScheme == .light ? .black : .white))
                .opacity(vertexViewModel.opacity)
            
            Circle()
                .stroke(vertexViewModel.strokeColor)
                .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
#if os(macOS)
                .frame(width: 20, height: 20)
#elseif os(iOS)
                .frame(width: 40, height: 40)
#endif
                .opacity(vertexViewModel.opacity)
        }
        .onLongPressGesture {
            if mode.contains(.editLabels) {
                isTextFieldFocused = true
                edittingLabel = true
            }
        }
        .onAppear {
            tempLabelColor = (colorScheme == .light ? .white : .black)
        }
        
        if !edittingLabel && mode.contains(.showLabels) {
#if os(macOS)
            StrokeText(text: vertexViewModel.label, color: labelColor)
                .opacity(vertexViewModel.opacity)
                .frame(width: size.width, height: size.height, alignment: .center)
                .position(x: vertexViewModel.position.x * size.width + vertexViewModel.offset.width, y: vertexViewModel.position.y * size.height + vertexViewModel.offset.height)
                .onLongPressGesture {
                    isTextFieldFocused = true
                    edittingLabel = true
                }
#elseif os(iOS)
            LaTeXView(latex: colorLatexString, size: $latexSize)
                .opacity(vertexViewModel.opacity)
                .frame(width: size.width, height: size.height, alignment: .center)
                .offset(x: position.x * size.width + offset.width - latexSize.width / 5, y: position.y * size.height + offset.height - latexSize.height / 5)
                .onLongPressGesture {
                    isTextFieldFocused = true
                    edittingLabel = true
                }
#endif
        } else if mode.contains(.editLabels) {
            TextField("", text: Binding(get: {vertexViewModel.label}, set: {newValue in vertexViewModel.label = newValue}))
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

#Preview {
    let vertex = Vertex(position: CGPoint(x: 0.5, y: 0.5))
    let graph = Graph(vertices: [vertex], edges: [])
    let vertexViewModel = VertexViewModel(vertex: vertex, graphViewModel: GraphViewModel(graph: graph))
    GeometryReader { geometry in
        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
    }
}
