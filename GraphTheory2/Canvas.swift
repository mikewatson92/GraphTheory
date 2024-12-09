//
//  Canvas.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/28/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct Canvas: View {
    @ObservedObject var graphViewModel: GraphViewModel
    @State private var isFileImporterPresented = false
    @State private var isFileExporterPresented = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                // Background to detect taps
                Color.clear
                    .contentShape(Rectangle()) // Ensures the tap area spans the entire view
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { tapLocation in
                                if graphViewModel.mode == .edit {
                                    // Add a vertex at the tap location
                                    let normalizedLocation = CGPoint(
                                        x: tapLocation.location.x / geometry.size.width,
                                        y: tapLocation.location.y / geometry.size.height
                                    )
                                    let newVertex = Vertex(position: normalizedLocation)
                                    graphViewModel.addVertex(newVertex)
                                }
                            }
                    )
                
                // Render the graph
                GraphView(graphViewModel: graphViewModel)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button("Save") {
                    isFileExporterPresented = true
                }
                
                Button("Load") {
                    isFileImporterPresented = true
                }
                
                Button("Weights") {
                    graphViewModel.showWeights = !graphViewModel.showWeights
                }
            }
        }
        .fileExporter(
            isPresented: $isFileExporterPresented,
            document: graphViewModel.createDocument(),
            contentType: .json,
            defaultFilename: "Graph"
        ) { result in
            handleFileExport(result: result)
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result) // Correctly handle the file import result
        }
        .alert(isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleFileExport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Graph successfully exported to: \(url)")
            errorMessage = nil // Clear previous errors, if any
        case .failure(let error):
            errorMessage = "Failed to export file: \(error.localizedDescription)"
            print("Export error: \(error)")
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else {
                errorMessage = "No file selected"
                return
            }
            
            print("Attempting to load file from: \(fileURL)")
            
            // Start accessing the security-scoped resource
            if fileURL.startAccessingSecurityScopedResource() {
                defer { fileURL.stopAccessingSecurityScopedResource() } // Ensure cleanup
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let loadedGraph = try JSONDecoder().decode(Graph.self, from: data)
                    graphViewModel.setGraph(loadedGraph)
                    errorMessage = nil // Clear previous errors
                    print("Graph successfully loaded from: \(fileURL)")
                } catch {
                    errorMessage = "Failed to parse graph: \(error.localizedDescription)"
                    print("Import error: \(error)")
                }
            } else {
                errorMessage = "Unable to access the selected file."
                print("Failed to start accessing security-scoped resource for: \(fileURL.path)")
            }
        case .failure(let error):
            errorMessage = "Failed to import file: \(error.localizedDescription)"
            print("Import error: \(error)")
        }
    }
}

#Preview {
    let graphViewModel = GraphViewModel(graph: Graph())
    Canvas(graphViewModel: graphViewModel)
}
