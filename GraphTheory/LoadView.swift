//
//  LoadView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI

struct LoadView: View {
    @Binding var isVisible: Bool // Binding to control visibility from parent view
    
    var body: some View {
        VStack {
            Text("Load Your Graph")
                .font(.headline)
                .padding()
            
            Button("Cancel") {
                isVisible = false // Dismiss load view
            }
            .padding()
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoadView(isVisible: .constant(true))
}
