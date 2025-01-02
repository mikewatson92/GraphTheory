//
//  ThemeSelector.swift
//  GraphTheory
//
//  Created by Mike Watson on 1/1/25.
//

import SwiftUI
import SwiftData

struct ThemeSelector: View {
    @Query private var themes: [Theme]
    @Environment(\.modelContext) private var context
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @State private var newTheme: Theme?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Theme.defaultThemes) { theme in
                    Button {
                        themeViewModel.theme = theme
                    } label: {
                        ThemePreview(theme: theme)
                    }
                }
                ForEach(themes) { theme in
                    Button {
                        themeViewModel.theme = theme
                    } label: {
                        ThemePreview(theme: theme)
                            .layoutPriority(1)
                    }
                    .swipeActions {
                        NavigationLink(destination: ThemeEditor(theme: theme)) {
                            Image(systemName: "gearshape")
                        }
                        Button(role: .destructive) {
                            deleteTheme(theme: theme)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteTheme(indexes:))
            }
            .toolbar {
                ToolbarItem {
                    Button("Add Theme", systemImage: "plus", action: addTheme)
                }
                #if os(iOS)
                ToolbarItem {
                    EditButton()
                }
                #endif
            }
            .sheet(item: $newTheme) { theme in
                NavigationStack {
                    ThemeEditor(theme: theme, isNew: true)
                    #if os(macOS)
                        .frame(width: 400, height: 400)
                    #endif
                }
            }
        }
        .navigationTitle("Theme Selector")
    }
    
    private func addTheme() {
        let newTheme = Theme(name: "New Theme", primary: Color.white, secondary: Color.black, accent: Color.blue)
        context.insert(newTheme)
        self.newTheme = newTheme
    }
    
    private func deleteTheme(indexes: IndexSet) {
        for index in indexes {
            context.delete(themes[index])
        }
    }
    
    private func deleteTheme(theme: Theme) {
        context.delete(theme)
    }
}

#Preview {
    ThemeSelector()
        .environmentObject(ThemeViewModel())
}
