//
//  Vertex.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/27/24.
//

import SwiftUI

struct Vertex: Identifiable, Codable {
    let id: UUID
    var position: CGPoint = .zero
    var offset: CGSize = .zero
    var color: Color = Color.primary
    var strokeColor: Color = Color.secondary
    
    init() {
        self.id = UUID()
    }
    
    init(position: CGPoint) {
        self.id = UUID()
        self.position = position
    }
    
    // Custom Codable implementation for `Color`
    enum CodingKeys: String, CodingKey {
        case id, position, color
    }
    
    mutating func setOffset(_ size: CGSize) {
        offset = size
    }
    
    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        // Convert Color to a string representation (e.g., hex)
        try container.encode(color.toHex(), forKey: .color)
    }
    
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        position = try container.decode(CGPoint.self, forKey: .position)
        // Convert the stored string back into a Color
        let colorHex = try container.decode(String.self, forKey: .color)
        color = Color(hex: colorHex)
    }
}

class VertexViewModel: ObservableObject {
    @Published private var vertex: Vertex
    private var getVertexPosition: (UUID) -> CGPoint?
    private var setVertexPosition: (UUID, CGPoint) -> Void
    private var getVertexOffset: (UUID) -> CGSize?
    private var setVertexOffset: (UUID, CGSize) -> Void
    private var setVertexColor: (UUID, Color) -> Void
    
    init(vertex: Vertex, getVertexPosition: @escaping (UUID) -> CGPoint?,
         setVertexPosition: @escaping (UUID, CGPoint) -> Void,
         getVertexOffset: @escaping (UUID) -> CGSize?,
         setVertexOffset: @escaping (UUID, CGSize) -> Void,
         setVertexColor: @escaping (UUID, Color) -> Void)
    {
        self.vertex = vertex
        self.getVertexPosition = getVertexPosition
        self.setVertexPosition = setVertexPosition
        self.getVertexOffset = getVertexOffset
        self.setVertexOffset = setVertexOffset
        self.setVertexColor = setVertexColor
    }
    
    var color: Color {
        get { vertex.color }
        set {
            vertex.color = newValue
            setVertexColor(vertex.id, newValue)
        }
    }
    
    var strokeColor: Color {
        vertex.strokeColor
    }
    
    func getVertexID() -> UUID {
        return vertex.id
    }
    
    func getPosition() -> CGPoint? {
        return getVertexPosition(vertex.id)
    }
    
    func setPosition(_ position: CGPoint) {
        setVertexPosition(vertex.id, position)
    }
    
    func getOffset() -> CGSize? {
        return getVertexOffset(vertex.id)
    }
    
    func setOffset(size: CGSize) {
        setVertexOffset(vertex.id, size)
    }
    
    func setColor(vertexID: UUID, color: Color) {
        self.color = color
        setVertexColor(vertexID, color)
    }
}

struct VertexView: View {
    @ObservedObject var vertexViewModel: VertexViewModel
    let size: CGSize
    
    init(vertexViewModel: VertexViewModel, size: CGSize) {
        _vertexViewModel = .init(wrappedValue: vertexViewModel)
        self.size = size
    }
    
    var body: some View {
        if let position = vertexViewModel.getPosition(), let offset = vertexViewModel.getOffset() {
            
            Circle()
                .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
            #if os(macOS)
                .frame(width: 20, height: 20)
            #elseif os(iOS)
                .frame(width: 40, height: 40)
            #endif
                .foregroundStyle(vertexViewModel.color)
            Circle()
                .stroke(vertexViewModel.strokeColor)
                .position(x: position.x * size.width + offset.width, y: position.y * size.height + offset.height)
            #if os(macOS)
                .frame(width: 20, height: 20)
            #elseif os(iOS)
                .frame(width: 40, height: 40)
            #endif
        }
    }
}

#Preview {
    let vertex = Vertex(position: CGPoint(x: 0.5, y: 0.5))
    var graph = Graph(vertices: [vertex], edges: [])
    let vertexViewModel = VertexViewModel(vertex: vertex, getVertexPosition: { id in graph.getVertexByID(id)?.position}, setVertexPosition: { id, position in graph.setVertexPosition(forID: id, position: position) }, getVertexOffset: { id in graph.getVertexByID(id)?.offset}, setVertexOffset: {id, size in graph.setVertexOffset(forID: id, size: size)},
                                          setVertexColor: { id, color in graph.setVertexColor(forID: id, color: color)})
    GeometryReader { geometry in
        VertexView(vertexViewModel: vertexViewModel, size: geometry.size)
    }
    
}
