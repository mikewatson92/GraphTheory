//
//  ThemePreview.swift
//  Theme
//
//  Created by Mike Watson on 1/1/25.
//

import SwiftUI

struct ThemePreview: View {
    let name: String
    let primary: Color
    let secondary: Color
    let accent: Color
    
    init(name: String, primary: Color, secondary: Color, accent: Color) {
        self.name = name
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
    }
    
    init(theme: Theme) {
        self.name = theme.name
        self.primary = Color(red: theme.primaryRed, green: theme.primaryGreen, blue: theme.primaryBlue)
        self.secondary = Color(red: theme.secondaryRed, green: theme.secondaryGreen, blue: theme.secondaryBlue)
        self.accent = Color(red: theme.accentRed, green: theme.accentGreen, blue: theme.accentBlue)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(accent)
                .font(.largeTitle)
            Text(name)
                .foregroundStyle(secondary)
                .font(.largeTitle)
            Spacer()
        }
        .padding()
        .background(primary, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ThemePreview(theme: Theme.cyberPunk)
}
