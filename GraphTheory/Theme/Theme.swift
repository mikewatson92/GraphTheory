//
//  Theme.swift
//  GraphTheory
//
//  Created by Mike Watson on 1/1/25.
//

import Foundation
import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

class ThemeViewModel: ObservableObject {
    @Published var theme: Theme? {
        didSet {
            if let theme = theme {
                save(theme)
            }
        }
    }
    
    init() {
        theme = load() ?? Theme.cyberPunk
    }
    
    private func save(_ theme: Theme) {
        if let encoded = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encoded, forKey: "theme")
        }
    }
    
    private func load() -> Theme? {
        if let savedData = UserDefaults.standard.data(forKey: "theme"),
           let theme = try? JSONDecoder().decode(Theme.self, from: savedData) {
            return theme
        }
        return nil
    }
}

@Model
class Theme: Codable, @unchecked Sendable {
    private(set) var id: UUID
    var name: String
    var primaryRed: CGFloat
    var primaryGreen: CGFloat
    var primaryBlue: CGFloat
    var secondaryRed: CGFloat
    var secondaryGreen: CGFloat
    var secondaryBlue: CGFloat
    var accentRed: CGFloat
    var accentGreen: CGFloat
    var accentBlue: CGFloat
    
    static let cyberPunk = Theme(name: "Cyber Punk", primary: Color(#colorLiteral(red: 0, green: 0.8086963296, blue: 1, alpha: 1)), secondary: Color(#colorLiteral(red: 1, green: 0, blue: 0.909978807, alpha: 1)), accent: Color(#colorLiteral(red: 0, green: 1, blue: 0.3673055172, alpha: 1)))
    static let defaultThemes: [Theme] = [cyberPunk]
    
    var primary: Color {
        get {
            Color(red: primaryRed, green: primaryGreen, blue: primaryBlue)
        } set {
            let (red, green, blue) = Color.toRGB(color: newValue)
            self.primaryRed = red
            self.primaryGreen = green
            self.primaryBlue = blue
        }
    }
    
    var secondary: Color {
        get {
            Color(red: secondaryRed, green: secondaryGreen, blue: secondaryBlue)
        } set {
            let (red, green, blue) = Color.toRGB(color: newValue)
            self.secondaryRed = red
            self.secondaryGreen = green
            self.secondaryBlue = blue
        }
    }
    
    var accent: Color {
        get {
            Color(red: accentRed, green: accentGreen, blue: accentBlue)
        } set {
            let (red, green, blue) = Color.toRGB(color: newValue)
            self.accentRed = red
            self.accentGreen = green
            self.accentBlue = blue
        }
    }
    
    #if os(macOS)
    init(name: String, primary: NSColor, secondary: NSColor, accent: NSColor) {
        self.id = UUID()
        self.name = name
        let primary = primary.usingColorSpace(.deviceRGB) ?? NSColor(.white)
        let secondary = secondary.usingColorSpace(.deviceRGB) ?? .black
        let accent = accent.usingColorSpace(.deviceRGB) ?? .cyan
        self.primaryRed = primary.redComponent
        self.primaryGreen = primary.greenComponent
        self.primaryBlue = primary.blueComponent
        self.secondaryRed = secondary.redComponent
        self.secondaryGreen = secondary.greenComponent
        self.secondaryBlue = secondary.blueComponent
        self.accentRed = accent.redComponent
        self.accentGreen = accent.greenComponent
        self.accentBlue = accent.blueComponent
    }
    
    convenience init(name: String, primary: Color, secondary: Color, accent: Color) {
        let primary = NSColor(primary)
        let secondary = NSColor(secondary)
        let accent = NSColor(accent)
        self.init(name: name, primary: primary, secondary: secondary, accent: accent)
    }
    
    #elseif os(iOS)
    init(name: String, primary: CIColor, secondary: CIColor, accent: CIColor) {
        self.id = UUID()
        self.name = name
        self.primaryRed = primary.red
        self.primaryGreen = primary.green
        self.primaryBlue = primary.blue
        self.secondaryRed = secondary.red
        self.secondaryGreen = secondary.green
        self.secondaryBlue = secondary.blue
        self.accentRed = accent.red
        self.accentGreen = accent.green
        self.accentBlue = accent.blue
    }
    
    convenience init(name: String, primary: Color, secondary: Color, accent: Color) {
        let primary = CIColor(color: UIColor(primary))
        let secondary = CIColor(color: UIColor(secondary))
        let accent = CIColor(color: UIColor(accent))
        self.init(name: name, primary: primary, secondary: secondary, accent: accent)
    }
    #endif
    
    enum CodingKeys: String, CodingKey {
        case id, name, primaryRed, primaryBlue, primaryGreen, secondaryRed, secondaryBlue, secondaryGreen, accentRed, accentBlue, accentGreen
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryRed, forKey: .primaryRed)
        try container.encode(primaryGreen, forKey: .primaryGreen)
        try container.encode(primaryBlue, forKey: .primaryBlue)
        try container.encode(secondaryRed, forKey: .secondaryRed)
        try container.encode(secondaryGreen, forKey: .secondaryGreen)
        try container.encode(secondaryBlue, forKey: .secondaryBlue)
        try container.encode(accentRed, forKey: .accentRed)
        try container.encode(accentGreen, forKey: .accentGreen)
        try container.encode(accentBlue, forKey: .accentBlue)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryRed = try container.decode(CGFloat.self, forKey: .primaryRed)
        primaryGreen = try container.decode(CGFloat.self, forKey: .primaryGreen)
        primaryBlue = try container.decode(CGFloat.self, forKey: .primaryBlue)
        secondaryRed = try container.decode(CGFloat.self, forKey: .secondaryRed)
        secondaryBlue = try container.decode(CGFloat.self, forKey: .secondaryBlue)
        secondaryGreen = try container.decode(CGFloat.self, forKey: .secondaryGreen)
        accentRed = try container.decode(CGFloat.self, forKey: .accentRed)
        accentBlue = try container.decode(CGFloat.self, forKey: .accentBlue)
        accentGreen = try container.decode(CGFloat.self, forKey: .accentGreen)
    }
}
