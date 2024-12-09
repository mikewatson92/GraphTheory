//
//  GraphDocument.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/28/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct GraphDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var graph: Graph
    
    init(graph: Graph) {
        self.graph = graph
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.graph = try JSONDecoder().decode(Graph.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            let data = try JSONEncoder().encode(graph)
            return FileWrapper(regularFileWithContents: data)
        } catch {
            print("Error encoding graph: \(error)")
            throw error
        }
    }
}
