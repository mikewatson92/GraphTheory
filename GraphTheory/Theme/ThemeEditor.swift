//
//  ThemeEditor.swift
//  GraphTheory
//
//  Created by Mike Watson on 1/1/25.
//

import SwiftUI

struct ThemeEditor: View {
    @Environment(\.modelContext) private var context
    @State private var name: String = "Theme Name"
    @State private var primary: Color = .black
    @State private var secondary: Color = .white
    @State private var accent: Color = .cyan
    
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Theme Name:", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                ColorPicker("Primary", selection: $primary)
                    .padding()
                ColorPicker("Secondary", selection: $secondary)
                    .padding()
                ColorPicker("Accent", selection: $accent)
                    .padding()
                Button("Save") {
                    let newTheme = Theme(name: name, primary: primary, secondary: secondary, accent: accent)
                    context.insert(newTheme)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                ThemePreview(theme: Theme(name: name, primary: primary, secondary: secondary, accent: accent))
            }
        }
        .navigationTitle("Theme Editor")
    }
}

#Preview {
    ThemeEditor()
        .environmentObject(ThemeViewModel())
}
