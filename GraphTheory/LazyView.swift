//
//  LazyView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/31/24.
//

import SwiftUI

// LazyView wrapper to defer initialization
struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
