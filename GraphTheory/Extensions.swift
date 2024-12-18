//
//  Extensions.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import CoreGraphics

extension Color: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rgba = try container.decode([CGFloat].self)
        guard rgba.count == 4 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid RGBA array; expected 4 components.")
        }
        self = Color(.sRGB, red: rgba[0], green: rgba[1], blue: rgba[2], opacity: rgba[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let components = self.cgColorComponents else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to extract CGColor components"))
        }
        try container.encode(components)
    }
    
    var cgColorComponents: [CGFloat]? {
#if os(macOS)
        let cgColor = NSColor(self).cgColor
#else
        let cgColor = UIColor(self).cgColor
#endif
        guard let components = cgColor.components, components.count >= 4 else { return nil }
        return components
    }
    
    func toHexString() -> String? {
#if os(macOS)
        let cgColor = NSColor(self).cgColor
#else
        let cgColor = UIColor(self).cgColor
#endif
        
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = Int((components.count >= 4 ? components[3] : 1.0) * 255)
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let length = hexSanitized.count
        
        let r, g, b, a: CGFloat
        if length == 6 {
            (r, g, b, a) = (
                CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                CGFloat(rgb & 0x0000FF) / 255.0,
                1.0
            )
        } else if length == 8 {
            (r, g, b, a) = (
                CGFloat((rgb & 0xFF000000) >> 24) / 255.0,
                CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
                CGFloat((rgb & 0x0000FF00) >> 8) / 255.0,
                CGFloat(rgb & 0x000000FF) / 255.0
            )
        } else {
            return nil
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

#if os(macOS)
extension NSColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = hexSanitized.count == 8 ? CGFloat((rgb & 0xFF000000) >> 24) / 255.0 : 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // Convert NSColor to hex string
    var hexString: String {
        guard let rgbColor = usingColorSpace(.deviceRGB) else { return "#000000" }
        let r = Int(rgbColor.redComponent * 255)
        let g = Int(rgbColor.greenComponent * 255)
        let b = Int(rgbColor.blueComponent * 255)
        let a = Int(rgbColor.alphaComponent * 255)
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
}
#else
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = hexSanitized.count == 8 ? CGFloat((rgb & 0xFF000000) >> 24) / 255.0 : 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // Convert UIColor to hex string
    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = components.count == 4 ? Int(components[3] * 255) : 255
        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
}
#endif
