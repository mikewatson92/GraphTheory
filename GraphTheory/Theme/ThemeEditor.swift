//
//  ThemeEditor.swift
//  GraphTheory
//
//  Created by Mike Watson on 1/1/25.
//

import SwiftUI

struct ThemeEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var theme: Theme
    let isNew: Bool
    
    init(theme: Theme, isNew: Bool = false) {
        self.theme = theme
        self.isNew = isNew
    }
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Theme Name:", text: $theme.name)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                ColorPicker("Primary", selection: $theme.primary)
                    .padding()
                ColorPicker("Secondary", selection: $theme.secondary)
                    .padding()
                ColorPicker("Accent", selection: $theme.accent)
                    .padding()
                ThemePreview(theme: theme)
            }
            .toolbar {
                if isNew {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            context.delete(theme)
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme Editor")
    }
}

#Preview {
    //ThemeEditor()
        //.environmentObject(ThemeViewModel())
}
