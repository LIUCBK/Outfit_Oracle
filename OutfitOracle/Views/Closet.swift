//
//  ClosetView.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/25.
//

import SwiftUI

struct ClosetView: View {
    @ObservedObject var viewModel = ClothesViewModel()
    @State private var selectedType: ClothesType?
    @State private var showingAddClothes = false
    @State private var selectedItem: ClothesItem?
    @State private var showingItemDetail = false
    @State private var showingDeleteConfirmation = false
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var filteredClothes: [ClothesItem] {
        viewModel.getFilteredClothes(type: selectedType)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                isSelected: selectedType == nil,
                                label: "All",
                                systemImage: "square.grid.2x2"
                            ) {
                                selectedType = nil
                            }
                            
                            ForEach(ClothesType.allCases) { type in
                                FilterButton(
                                    isSelected: selectedType == type,
                                    label: type.rawValue,
                                    systemImage: type.iconName
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading your closet...")
                        Spacer()
                    } else if filteredClothes.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "hanger")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Your closet is empty")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("Add some clothes to get started")
                                .foregroundColor(.gray)
                            
                            Button {
                                showingAddClothes = true
                            } label: {
                                Text("Add Clothes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredClothes) { item in
                                    Button {
                                        selectedItem = item
                                        showingItemDetail = true
                                    } label: {
                                        ClothesItemView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle()) 
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            selectedItem = item
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddClothes = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            
            .fullScreenCover(isPresented: $showingAddClothes, onDismiss: {
                viewModel.fetchClothes()
            }) {
                Add()
            }
            .fullScreenCover(isPresented: $showingItemDetail, onDismiss: {
                viewModel.fetchClothes()
            }) {
                if let item = selectedItem {
                    ClothesDetailView(clothesItem: item, viewModel: viewModel)
                }
            }
            .onAppear {
                viewModel.fetchClothes()
            }
        }
    }
}

struct FilterButton: View {
    var isSelected: Bool
    var label: String
    var systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(label)
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(8)
            .shadow(radius: 2)
        }
    }
}

struct ClothesItemView: View {
    let item: ClothesItem
    
    var body: some View {
        VStack {
            // Using AsyncImage from SwiftUI
            if let url = URL(string: item.imageURL) {
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
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                }
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(item.type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                    
                    Text(item.material)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Circle()
                    .fill(item.color)
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.thickness ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundColor(star <= item.thickness ? .yellow : .gray)
                }
            }
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ClothesDetailView: View {
    let clothesItem: ClothesItem
    @ObservedObject var viewModel: ClothesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Using AsyncImage from SwiftUI
                    if let url = URL(string: clothesItem.imageURL) {
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
                                    .scaledToFit()
                            case .failure:
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.2))
                            }
                        }
                        .cornerRadius(12)
                        .padding()
                    } else {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .frame(height: 300)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            )
                            .padding()
                    }
                    
                    VStack(spacing: 20) {
                        DetailRow(icon: clothesItem.type.iconName, label: "Type", value: clothesItem.type.rawValue)
                        
                        DetailRow(icon: "thermometer", label: "Thickness") {
                            HStack {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= clothesItem.thickness ? "star.fill" : "star")
                                        .foregroundColor(star <= clothesItem.thickness ? .yellow : .gray)
                                }
                            }
                        }
                        
                        DetailRow(icon: "paintpalette", label: "Color") {
                            HStack {
                                Circle()
                                    .fill(clothesItem.color)
                                    .frame(width: 24, height: 24)
                                Text(clothesItem.colorHex)
                            }
                        }
                        
                        DetailRow(icon: "tag", label: "Material", value: clothesItem.material)
                        
                        DetailRow(icon: "calendar", label: "Added") {
                            Text(clothesItem.dateAdded, style: .date)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete from Closet", systemImage: "trash")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Clothes Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Item", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteClothesItem(clothesItem)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to remove this item from your closet?")
            }
        }
    }
}

struct DetailRow<Content: View>: View {
    let icon: String
    let label: String
    let content: Content
    
    init(icon: String, label: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.label = label
        self.content = content()
    }
    
    init(icon: String, label: String, value: String) where Content == Text {
        self.icon = icon
        self.label = label
        self.content = Text(value)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
            
            Text(label)
                .font(.headline)
            
            Spacer()
            
            content
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ClosetView(viewModel: ClothesViewModel())
}
