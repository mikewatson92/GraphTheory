//
//  Math.swift
//  
//
//  Created by Mike Watson on 12/8/24.
//

/*
import SwiftUI
import iosMath
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct Math: NSViewRepresentable, Hashable {
    var expression: String
    
    nonisolated static func == (lhs: Math, rhs: Math) -> Bool {
        return lhs.expression == rhs.expression
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
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

#Preview {
    Math(expression: "\\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}")
}
*/
