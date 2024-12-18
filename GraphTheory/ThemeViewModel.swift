//
//  ThemeView.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/14/24.
//

import Foundation
import SwiftUI

class ThemeViewModel: ObservableObject {
    @Published var customThemes: [Theme] = []
    @Published var theme: Theme? {
        didSet {
            if let theme = theme {
                saveSelectedTheme(theme)
            }
        }
    }
    
    init() {
        theme = loadSavedSelectedTheme() ?? DefaultThemes.natural
        loadCustomThemes()
    }
    
    private func saveCustomThemes() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(customThemes)
            UserDefaults.standard.set(data, forKey: "customThemes")
        } catch {
            print("Failed to save custom themes: \(error)")
        }
    }
    
    private func loadCustomThemes() {
        guard let data = UserDefaults.standard.data(forKey: "customThemes") else { return }
        do {
            customThemes = try JSONDecoder().decode([Theme].self, from: data)
        } catch {
            print("Failed to load custom themes: \(error)")
        }
    }
    
    private func saveSelectedTheme(_ theme: Theme) {
        do {
            let data = try JSONEncoder().encode(theme)
            UserDefaults.standard.set(data, forKey: "theme")
        } catch {
            print("Failed to save selected theme: \(error)")
        }
    }
    
    private func loadSavedSelectedTheme() -> Theme? {
        guard let data = UserDefaults.standard.data(forKey: "theme") else { return nil }
        do {
            return try JSONDecoder().decode(Theme.self, from: data)
        } catch {
            print("Failed to load selected theme: \(error)")
            return nil
        }
    }
}

struct Theme: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var accentColor: Color
    var primaryColor: Color
    var secondaryColor: Color
    
    enum CodingKeys: String, CodingKey {
        case id, name, accentColor, primaryColor, secondaryColor
    }
    
    init(id: UUID = UUID(), name: String, accentColor: Color, primaryColor: Color, secondaryColor: Color) {
        self.id = id
        self.name = name
        self.accentColor = accentColor
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(accentColor.toHexString(), forKey: .accentColor)
        try container.encode(primaryColor.toHexString(), forKey: .primaryColor)
        try container.encode(secondaryColor.toHexString(), forKey: .secondaryColor)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let accentColorHex = try container.decode(String.self, forKey: .accentColor)
        let primaryColorHex = try container.decode(String.self, forKey: .primaryColor)
        let secondaryColorHex = try container.decode(String.self, forKey: .secondaryColor)
        
        accentColor = Color(hex: accentColorHex) ?? DefaultThemes.natural.accentColor
        primaryColor = Color(hex: primaryColorHex) ?? DefaultThemes.natural.primaryColor
        secondaryColor = Color(hex: secondaryColorHex) ?? DefaultThemes.natural.secondaryColor
    }
}

struct DefaultThemes {
    static let natural = Theme(name: "Natural", accentColor: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), primaryColor: Color.primary, secondaryColor: Color.secondary)
    static let defaultLight = Theme(name: "Default Light Mode", accentColor: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), primaryColor: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), secondaryColor: Color(#colorLiteral(red: 0.1934801936, green: 0.1934801936, blue: 0.1934801936, alpha: 1)))
    static let defaultDark = Theme(name: "Default Dark Mode", accentColor: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), primaryColor: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), secondaryColor: Color(#colorLiteral(red: 0.7725917697, green: 0.7725917697, blue: 0.7725917697, alpha: 1)))
    static let cyberPunkLight = Theme(name: "Cyber Punk Light", accentColor: Color(#colorLiteral(red: 0, green: 0.7207589746, blue: 0, alpha: 1)), primaryColor: Color(#colorLiteral(red: 0.6627575755, green: 0, blue: 0.5499150753, alpha: 1)), secondaryColor: Color(#colorLiteral(red: 0, green: 0.5573580861, blue: 0.7087256312, alpha: 1)))
    static let cyberPunkDark = Theme(name: "Cyber Punk Dark", accentColor: Color(#colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)), primaryColor: Color(#colorLiteral(red: 1, green: 0, blue: 0.909978807, alpha: 1)), secondaryColor: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)))
}
