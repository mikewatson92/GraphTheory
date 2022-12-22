//
//  Gradients.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
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
    .linearGradient(Gradient(colors: [Color("darkGreen"), Color("lightGreen")]), startPoint: .bottom, endPoint: .top)
}

var redGradient: LinearGradient {
    .linearGradient(Gradient(colors: [Color("darkRed"), Color("lightRed")]), startPoint: .bottom, endPoint: .top)
}
