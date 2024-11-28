//
//  VertexColorPicker.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/28/24.
//

import SwiftUI

struct VertexColorPickerModifier: ViewModifier {
    @Binding var selectedColor: Color

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    ColorPicker("Vertex Color", selection: $selectedColor)
                        .labelsHidden()
                }
            }
    }
}

extension View {
    func withVertexColorPicker(selectedColor: Binding<Color>) -> some View {
        self.modifier(VertexColorPickerModifier(selectedColor: selectedColor))
    }
}
