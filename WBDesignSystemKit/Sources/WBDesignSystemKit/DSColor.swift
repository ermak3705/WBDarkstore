//
//  DSColor.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 14.07.2026.
//

import SwiftUI

public enum DSColors {
    public static let primary = Color(hex: "#BF22E1")
    
    public static let gradientStart = Color(hex: "#ED3CCA")
    public static let gradientEnd = Color(hex: "#6600FF")
    
    public static let background = Color.white
    public static let secondaryBackground = Color(uiColor: .systemGray6)
    public static let textPrimary = Color.black
    public static let textSecondary = Color.gray
    public static let error = Color.red
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

public enum DSGradients {
    public static let violet = LinearGradient(
        colors: [
            Color(hex: "#ED3CCA"),
            Color(hex: "#DF34D2"),
            Color(hex: "#D02BD9"),
            Color(hex: "#BF22E1"),
            Color(hex: "#AE1AE8"),
            Color(hex: "#9A10F0"),
            Color(hex: "#8306F7"),
            Color(hex: "#6600FF")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let smoky = LinearGradient(
        colors: [
            Color(hex: "#9797AF").opacity(0.2),
            Color(hex: "#000000")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
