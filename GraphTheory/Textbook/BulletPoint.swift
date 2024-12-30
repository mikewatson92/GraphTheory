//
//  BulletPoint.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/30/24.
//

import SwiftUI

struct BulletPoint: View {
    let header: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("• ")
                .font(.body)
                .fontWeight(.bold) +
            Text("\(header) ")
                .fontWeight(.bold) +
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    BulletPoint(header: "Sample header", text: "sample text.")
}
