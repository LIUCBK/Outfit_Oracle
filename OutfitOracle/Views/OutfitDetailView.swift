//
//  OutfitDetailView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI

struct OutfitDetailView: View {
    let outfit: RecentOutfit
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text(outfit.date, style: .date)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= outfit.rating ? "star.fill" : "star")
                                .foregroundColor(star <= outfit.rating ? .yellow : .gray)
                                .font(.title)
                        }
                    }
                    
                    // Outfit items
                    HStack(spacing: 24) {
                        OutfitItemView(icon: "tshirt.fill", color: .blue)
                        OutfitItemView(icon: "figure.walk", color: .black)
                        OutfitItemView(icon: "shoe", color: .brown)
                    }
                    .padding(.vertical, 40)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Outfit Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct OutfitItemView: View {
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
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

#Preview {
    OutfitDetailView(outfit: RecentOutfit(date: Date(), rating: 4))
}
