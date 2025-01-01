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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Theme.defaultThemes) { theme in
                    Button {
                        themeViewModel.theme = theme
                    } label: {
                        ThemePreview(theme: theme)
                    }
                    .buttonStyle(.borderless)
                }
                ForEach(themes) { theme in
                    Button {
                        themeViewModel.theme = theme
                    } label: {
                        ThemePreview(theme: theme)
                    }
                    .buttonStyle(.borderless)
                }
                .onDelete(perform: deleteTheme(indexes:))
                Spacer()
                NavigationLink(destination: ThemeEditor()) {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundStyle(themeViewModel.theme!.accent)
                        Text("Add Theme")
                    }
                    .foregroundStyle(themeViewModel.theme!.secondary)
                        .padding(5)
                        .background(themeViewModel.theme!.primary, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .navigationTitle("Theme Selector")
    }
    
    private func deleteTheme(indexes: IndexSet) {
        for index in indexes {
            context.delete(themes[index])
        }
    }
}

#Preview {
    ThemeSelector()
        .environmentObject(ThemeViewModel())
}
