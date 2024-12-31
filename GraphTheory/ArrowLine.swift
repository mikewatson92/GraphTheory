//
//  ArrowLine.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct ArrowLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startPoint = CGPoint(x: rect.width * 0.1, y: rect.height * 0.5)
        let arrowTip = CGPoint(x: rect.width * 0.9, y: rect.height * 0.5)
        let arrowWingTop = CGPoint(x: rect.width * 0.8, y: rect.height * 0.25)
        let arrowEndTop = CGPoint(x: rect.width * 0.89, y: rect.height * (0.49))
        let arrowWingBottom = CGPoint(x: rect.width * 0.8, y: rect.height * 0.75)
        let arrowEndBottom = CGPoint(x: rect.width * 0.89, y: rect.height * 0.51)
        path.move(to: startPoint)
        path.addLine(to: arrowTip)
        path.move(to: arrowWingTop)
        path.addLine(to: arrowEndTop)
        path.addCurve(to: arrowEndBottom, control1: arrowTip, control2: arrowTip)
        path.addLine(to: arrowWingBottom)
        return path
    }
}

#Preview {
    GeometryReader { geometry in
        ArrowLine()
            .stroke(lineWidth: 5)
            .environmentObject(ThemeViewModel())
    }
}
