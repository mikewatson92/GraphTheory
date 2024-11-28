//
//  Extensions.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/28/24.
//

import SwiftUI
import AppKit
import CoreGraphics

extension Color: Codable {
    
    init(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        let scanner = Scanner(string: hexString)
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        
        switch hexString.count {
        case 6: // RGB (without alpha)
            let r = Double((hexValue & 0xFF0000) >> 16) / 255.0
            let g = Double((hexValue & 0x00FF00) >> 8) / 255.0
            let b = Double(hexValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        case 8: // RGBA
            let r = Double((hexValue & 0xFF000000) >> 24) / 255.0
            let g = Double((hexValue & 0x00FF0000) >> 16) / 255.0
            let b = Double((hexValue & 0x0000FF00) >> 8) / 255.0
            let a = Double(hexValue & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, opacity: a)
        default:
            // Default to clear if the hex string is invalid
            self.init(.clear)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let components = self.toRGBAComponents() else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to extract RGBA components."))
        }
        try container.encode(components.red, forKey: .red)
        try container.encode(components.green, forKey: .green)
        try container.encode(components.blue, forKey: .blue)
        try container.encode(components.opacity, forKey: .opacity)
    }
    
    private func toRGBAComponents() -> (red: Double, green: Double, blue: Double, opacity: Double)? {
#if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (Double(red), Double(green), Double(blue), Double(alpha))
        }
#endif
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    func toHex() -> String? {
        let nsColor = NSColor(self)
        guard let components = nsColor.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = nsColor.cgColor.alpha
        return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
    }
}

extension CGPoint: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }

    private enum CodingKeys: String, CodingKey {
        case x, y
    }
}

extension CGSize: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }

    private enum CodingKeys: String, CodingKey {
        case width, height
    }
}
