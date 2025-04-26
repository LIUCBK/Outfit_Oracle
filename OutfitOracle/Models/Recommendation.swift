//
//  Recommendation.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import Foundation
import SwiftUI

class OutfitRecommendationService {
    static func getRecommendedOutfitThickness(for temperature: Double) -> (jacketThickness: Int, topThickness: Int, bottomThickness: Int) {
        if temperature <= 32 {
            // Cold weather - thick clothes (4-5)
            let jacketThickness = Int.random(in: 4...5)
            let topThickness = Int.random(in: 4...5)
            let bottomThickness = Int.random(in: 4...5)
            return (jacketThickness, topThickness, bottomThickness)
        } else if temperature <= 60 {
            // Mild weather - medium thickness (3)
            return (3, 3, 3)
        } else {
            // Warm weather - light clothes (1-2)
            let jacketThickness = Int.random(in: 1...2)
            let topThickness = Int.random(in: 1...2)
            let bottomThickness = Int.random(in: 1...2)
            return (jacketThickness, topThickness, bottomThickness)
        }
    }
    
    // Generate a random outfit
    static func generateOutfitRecommendation(from clothesItems: [ClothesItem], temperature: Double) -> (jacket: ClothesItem?, top: ClothesItem?, bottom: ClothesItem?) {
        // Get recommended thickness based on temperature
        let recommendedThickness = getRecommendedOutfitThickness(for: temperature)
        
        // Find clothes of each type
        let jacketOptions = clothesItems.filter { $0.type == .jacket && $0.thickness == recommendedThickness.jacketThickness }
        let topOptions = clothesItems.filter { $0.type == .top && $0.thickness == recommendedThickness.topThickness }
        let bottomOptions = clothesItems.filter { $0.type == .bottom && $0.thickness == recommendedThickness.bottomThickness }
        
        // If no matches by exact thickness, get all items of the type
        let allJackets = clothesItems.filter { $0.type == .jacket }
        let allTops = clothesItems.filter { $0.type == .top }
        let allBottoms = clothesItems.filter { $0.type == .bottom }
        
        // Randomly select one item from each category if available
        let jacket = jacketOptions.isEmpty ? allJackets.randomElement() : jacketOptions.randomElement()
        let top = topOptions.isEmpty ? allTops.randomElement() : topOptions.randomElement()
        let bottom = bottomOptions.isEmpty ? allBottoms.randomElement() : bottomOptions.randomElement()
        
        return (jacket, top, bottom)
    }
}
