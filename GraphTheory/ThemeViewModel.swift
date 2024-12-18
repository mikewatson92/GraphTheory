//
//  ThemeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import Foundation
import SwiftUI

class ThemeViewModel: ObservableObject {
    @Published private(set) var accentColor: Color = Color("AccentColor")
    @Published private(set) var colorTheme1: Color = Color("Default_Primary")
    @Published private(set) var colorTheme2: Color = Color("Default_Secondary")
    @Published var theme: Theme = .defaultTheme {
        willSet(newTheme) {
            switch newTheme {
            case .defaultTheme:
                accentColor = Color("AccentColor")
                colorTheme1 = Color("Default_Primary")
                colorTheme2 = Color("Default_Secondary")
            case .cyberPunkDark:
                accentColor = Color("CyberPunkDark_Accent")
                colorTheme1 = Color("CyberPunkDark_Primary")
                colorTheme2 = Color("CyberPunkDark_Secondary")
            case .cyberPunkLight:
                accentColor = Color("CyberPunkLight_Accent")
                colorTheme1 = Color("CyberPunkLight_Primary")
                colorTheme2 = Color("CyberPunkLight_Secondary")
            }
            saveTheme(newTheme)
        }
    }
    
    init() {
        theme = loadSavedTheme() ?? .defaultTheme
        applyTheme(theme)
    }
    
    enum Theme: String, Identifiable, CaseIterable {
        case defaultTheme = "Default"
        case cyberPunkDark = "Cyber Punk Dark"
        case cyberPunkLight = "Cyber Punk Light"
        
        var id: String { self.rawValue }
    }
    
    private func applyTheme(_ theme: Theme) {
        switch theme {
        case .defaultTheme:
            accentColor = Color("AccentColor")
            colorTheme1 = Color("Default_Primary")
            colorTheme2 = Color("Default_Secondary")
        case .cyberPunkDark:
            accentColor = Color("CyberPunkDark_Accent")
            colorTheme1 = Color("CyberPunkDark_Primary")
            colorTheme2 = Color("CyberPunkDark_Secondary")
        case .cyberPunkLight:
            accentColor = Color("CyberPunkLight_Accent")
            colorTheme1 = Color("CyberPunkLight_Primary")
            colorTheme2 = Color("CyberPunkLight_Secondary")
        }
    }
    
    private func saveTheme(_ theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    private func loadSavedTheme() -> Theme? {
        guard let rawValue = UserDefaults.standard.string(forKey: "selectedTheme"),
              let savedTheme = Theme(rawValue: rawValue) else {
            return nil
        }
        return savedTheme
    }
}
