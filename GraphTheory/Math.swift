//
//  Math.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI
import iosMath
import AppKit

struct Math: NSViewRepresentable, Hashable {
    var expression: String
    
    static func == (lhs: Math, rhs: Math) -> Bool {
        return lhs.expression == rhs.expression
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(expression)
    }
    
    
    func makeNSView(context: Context) -> MTMathUILabel {
        let expression = MTMathUILabel()
        expression.fontSize = 14.0
        expression.textColor = NSColor.white
        return expression
        
    }
    
    func updateNSView(_ nsView: MTMathUILabel, context: Context) {
        nsView.latex = self.expression
    }
        
    
}

struct MathView: View {
    var expression = "\\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"
    
    var body: some View {
        Math(expression: expression)
    }
}
