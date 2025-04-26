//
//  ProfileView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userName = ""
    @State private var recentOutfits: [RecentOutfit] = [
        RecentOutfit(date: Date(), rating: 4),
        RecentOutfit(date: Date().addingTimeInterval(-86400), rating: 2),
        RecentOutfit(date: Date().addingTimeInterval(-172800), rating: 5),
        RecentOutfit(date: Date().addingTimeInterval(-259200), rating: 3)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Profile")
                        .bold()
                        .font(.title)
                        .padding(.top)
              
                    VStack(spacing: 16) {
                        Image(systemName: "cat.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        TextField("Enter Your User Name", text: $userName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outfit History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recentOutfits) { outfit in
                            RecentOutfitRow(outfit: outfit)
                        }
                    }
                    
                    Spacer()
 
                }
            }
            .navigationBarTitleDisplayMode(.inline)

        }
    }
}

struct RecentOutfit: Identifiable {
    let id = UUID()
    let date: Date
    let rating: Int
}

struct RecentOutfitRow: View {
    let outfit: RecentOutfit
    @State private var showDetail = false
    
    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack {
                Text(outfit.date, style: .date)
                    .font(.subheadline)
                
                Spacer()
                
                // Star rating
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= outfit.rating ? "star.fill" : "star")
                            .foregroundColor(star <= outfit.rating ? .yellow : .gray)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 1)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showDetail) {
            OutfitDetailView(outfit: outfit)
        }
    }
}

#Preview {
    ProfileView()
}
