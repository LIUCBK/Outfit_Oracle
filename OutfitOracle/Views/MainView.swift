//
//  MainView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/26.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var clothesViewModel = ClothesViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab (Weather & Outfit Recommendations)
            HomeView(clothesViewModel: clothesViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "sun.max.fill")
                        Text("Today")
                    }
                }
                .tag(0)
            
            // Closet Tab
            ClosetView(viewModel: clothesViewModel)
                   .tabItem {
                       VStack {
                           Image(systemName: "hanger")
                           Text("Closet")
                       }
                   }
                   .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Me")
                    }
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainView()
}
