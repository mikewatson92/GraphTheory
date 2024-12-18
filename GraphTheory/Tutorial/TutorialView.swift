//
//  TutorialView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel

    var body: some View {
        TabView {
            AddVertexTutorial()
            AddEdgeTutorial()
            DeleteTutorial()
            MoveTutorial()
            ColorTutorial()
            CurveEdgeTutorial()
            StraightenTutorial()
            WeightsTutorial()
            VertexLabelTutorial()
            TutorialEnd()
        }
        #if os(iOS)
        .tabViewStyle(.page)
        #elseif os(macOS)
        .tabViewStyle(.automatic)
        #endif
    }
}

#Preview {
    TutorialView()
}
