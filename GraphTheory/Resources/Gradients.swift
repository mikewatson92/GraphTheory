//
//  Gradients.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import SwiftUI

var darkGradient: LinearGradient {
    .linearGradient(
        Gradient(colors: [.black.opacity(1), Color(#colorLiteral(red: 0.1770332754, green: 0.1703237593, blue: 0.1745822132, alpha: 1)).opacity(1), Color(#colorLiteral(red: 0.2038498521, green: 0.2038498521, blue: 0.2038498521, alpha: 1))]),
        startPoint: .bottomTrailing,
        endPoint: .topLeading)
}

var blueGradient = LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.9400200248, blue: 0.9575836062, alpha: 1)).opacity(0.8), Color(#colorLiteral(red: 0, green: 0.7929652333, blue: 0.9635403752, alpha: 1)).opacity(0.6), Color(#colorLiteral(red: 0, green: 0.5268225074, blue: 0.9663056731, alpha: 1)).opacity(0.4)], startPoint: .bottomTrailing, endPoint: .topLeading)

var greenGradient: LinearGradient {
    .linearGradient(Gradient(colors: [Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)), Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))]), startPoint: .bottom, endPoint: .top)
}

var redGradient: LinearGradient {
    .linearGradient(Gradient(colors: [Color(#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)), Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))]), startPoint: .bottom, endPoint: .top)
}
