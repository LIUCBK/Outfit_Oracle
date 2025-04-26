//
//  Clothes.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/25.
//

import SwiftUI
import FirebaseFirestore

enum ClothesType: String, Codable, CaseIterable, Identifiable {
    case top = "Top"
    case bottom = "Bottom"
    case jacket = "Jacket"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .top: return "tshirt"
        case .bottom: return "figure.walk"
        case .jacket: return "jacket"

        }
    }
}

struct ClothesItem: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var type: ClothesType
    var thickness: Int
    var colorHex: String
    var material: String
    var imageURL: String
    var dateAdded: Date
    
    // Computed property to convert hex string to Color (not stored in Firestore)
    var color: Color {
        get {
            Color(hex: colorHex) ?? .blue
        }
        set {
            colorHex = newValue.toHex() ?? "#0000FF"
        }
    }
}

// Extensions to help with color conversion
extension Color {
    // Convert hex string to Color
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    // Convert Color to hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

