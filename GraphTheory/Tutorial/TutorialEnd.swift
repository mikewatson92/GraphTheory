//
//  TutorialEnd.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/15/24.
//

import SwiftUI

struct TutorialEnd: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    
    var body: some View {
        Text("You have finished the Graph Theory tutorial! Create your own custom graphs in the Canvas, and apply various graph theory algorithms.")
            .font(.title2)
            .foregroundColor(themeViewModel.theme!.primary)
            .padding()
    }
}

#Preview {
    TutorialEnd()
}
