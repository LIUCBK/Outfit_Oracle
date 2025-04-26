//
//  RecommendedClothesItemView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI

struct RecommendedClothesItemView: View {
    let item: ClothesItem?
    let fallbackIcon: String
    let fallbackColor: Color
    
    var body: some View {
        VStack {
            if let item = item, let url = URL(string: item.imageURL) {
                // Show actual image from user's closet
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: fallbackIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(item.color)
                    @unknown default:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                // Item details
                Text(item.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Thickness indicator
                HStack(spacing: 2) {
                    ForEach(1...item.thickness, id: \.self) { _ in
                        Image(systemName: "line.horizontal")
                            .font(.system(size: 8))
                            .foregroundColor(.black)
                    }
                }
            } else {
                Image(systemName: fallbackIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(fallbackColor)
                    .frame(width: 60, height: 80)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}
