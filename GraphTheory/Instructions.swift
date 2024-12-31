//
//  Instructions.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/31/24.
//

import SwiftUI

struct Instructions: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Binding var showBanner: Bool
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(themeViewModel.theme!.primaryColor)
                .padding()
                .background(themeViewModel.theme!.secondaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Button {
                withAnimation {
                    showBanner = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding([.top, .bottom], 25)
        .transition(.move(edge: .top))
    }
}

#Preview {
    Instructions(showBanner: .constant(true), text: "Instructions")
}
