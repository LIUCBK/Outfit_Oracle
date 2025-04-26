//
//  Recommendation.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI

struct OutfitRecommendationView: View {
    @ObservedObject var clothesViewModel: ClothesViewModel
    let isHoliday: Bool
    let holidayInfo: (icon: String, color: Color, message: String)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Outfit Recommendation")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.leading)
            
            if clothesViewModel.clothesItems.isEmpty {
                // No clothes case
                VStack(spacing: 12) {
                    Text("Add clothes to your closet for personalized recommendations")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                // Outfit recommendation
                HStack(spacing: 24) {
                    RecommendedClothesItemView(item: clothesViewModel.currentOutfit.jacket, fallbackIcon: "jacket", fallbackColor: .gray)
                    
                    RecommendedClothesItemView(item: clothesViewModel.currentOutfit.top, fallbackIcon: "tshirt.fill", fallbackColor: .blue)
                    
                    RecommendedClothesItemView(item: clothesViewModel.currentOutfit.bottom, fallbackIcon: "figure.walk", fallbackColor: .black)
                }
                .padding(.vertical)
            }
            
            // Show special recommendation if a holiday
            if isHoliday {
                HStack(spacing: 8) {
                    Image(systemName: holidayInfo.icon)
                        .foregroundColor(holidayInfo.color)
                    Text(holidayInfo.message)
                        .font(.headline)
                        .foregroundColor(holidayInfo.color)
                }
                .padding()
                .background(holidayInfo.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            if !isHoliday {
                HStack(spacing: 8) {
                    Image(systemName: holidayInfo.icon)
                        .foregroundColor(holidayInfo.color)
                    Text(holidayInfo.message)
                        .font(.headline)
                        .foregroundColor(holidayInfo.color)
                }
                .padding()
                .background(holidayInfo.color.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
