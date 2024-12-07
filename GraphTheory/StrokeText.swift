//
//  StrokeText.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                    .fontWeight(.bold)
                Text(text).offset(x: -width, y: -width)
                    .fontWeight(.bold)
                Text(text).offset(x: -width, y:  width)
                    .fontWeight(.bold)
                Text(text).offset(x:  width, y: -width)
                    .fontWeight(.bold)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

#Preview {
    StrokeText(text: "A", width: 1, color: .black)
        .frame(width: 50, height: 50)
}
