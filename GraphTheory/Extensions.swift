//
//  Extensions.swift
//  GraphTheory
//
//  Created by Mike Watson on 1/2/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

extension Color: Codable {
    public func encode(to encoder: any Encoder) throws {
        let (red, green, blue) = Color.toRGB(color: self)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        self.init(Color(red: red, green: green, blue: blue))
    }
    
    static func toRGB(color: Color) -> (CGFloat, CGFloat, CGFloat) {
        #if os(macOS)
        let nsColor = NSColor(color).usingColorSpace(.deviceRGB)
        return (nsColor!.redComponent, nsColor!.greenComponent, nsColor!.blueComponent)
        #elseif os(iOS)
        let ciColor = CIColor(color: UIColor(color))
        return (ciColor.red, ciColor.green, ciColor.blue)
        #endif
    }
    
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
}
