//
//  HomeView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State var weatherVM = WeatherViewModel()
    @ObservedObject var clothesViewModel: ClothesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var noClothesAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("What to Wear:")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Weather and date section
                        WeatherDateView(weatherVM: weatherVM)
                        
                        // Outfit recommendation section
                        OutfitRecommendationView(
                            clothesViewModel: clothesViewModel,
                            isHoliday: isHoliday(),
                            holidayInfo: holidayInfo()
                        )                        
                        
                        Button {
                            refreshOutfitRecommendation()
                        } label: {
                            Text("Refresh")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
           
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Log out successful!")
                            dismiss()
                        } catch {
                            print("😡 ERROR: Could not sign out!")
                        }
                    }
                }
            }
            .alert("No Clothes Found", isPresented: $noClothesAlert) {
                Button("Add Clothes", role: .none) {
                    // Switch to closet tab - this would need to be handled via a callback
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Add clothes to your closet for personalized recommendations.")
            }
            .task {
                await weatherVM.getData()
        
                refreshOutfitRecommendation()
            }
        }
    }
    
    private func refreshOutfitRecommendation() {
        if clothesViewModel.clothesItems.isEmpty {
            noClothesAlert = true
            return
        }
        
        clothesViewModel.generateOutfitRecommendation(temperature: weatherVM.temperature)
    }
    
    // Check if today is a holiday
    func isHoliday() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // St. Patrick's Day
        if month == 3 && day == 17 {
            return true
        }
        
        // 4th of July
        if month == 7 && day == 4 {
            return true
        }
        
        // Christmas
        if month == 12 && day == 25 {
            return true
        }
        
        // Halloween
        if month == 10 && day == 31 {
            return true
        }
        
        return false
    }
    
    // Get holiday info
    func holidayInfo() -> (icon: String, color: Color, message: String) {
        let now = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // St. Patrick's Day
        if month == 3 && day == 17 {
            return ("leaf.fill", .green, "Wear green for St. Patrick's Day")
        }
        
        // 4th of July
        if month == 7 && day == 4 {
            return ("sparkles", .blue, "Wear red, white, and blue for Independence Day")
        }
        
        // Christmas
        if month == 12 && day == 25 {
            return ("gift.fill", .red, "Wear festive colors for Christmas")
        }
        
        // Halloween
        if month == 10 && day == 31 {
            return ("moon.stars.fill", .orange, "Wear orange and black for Halloween")
        }
        
        return ("face.smiling", .blue, "No special recommendation for today.")
    }
}

#Preview {
    HomeView(clothesViewModel: ClothesViewModel.mockViewModel())
}
