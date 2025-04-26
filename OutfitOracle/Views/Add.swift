//
//  Add.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/25.
//

import SwiftUI
import PhotosUI

struct Add: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ClothesViewModel()
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var uploadedImage: UIImage?
    @State private var previewImage: Image?
    @State private var selectedClothesType: ClothesType? = nil
    @State private var thickness: Int = 0
    @State private var selectedColor: Color = .blue
    @State private var material: String = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var formIsValid: Bool {
        previewImage != nil && !material.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.90)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                   
                    if let previewImage = previewImage {
                        previewImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 280)
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "person.crop.rectangle.badge.plus.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 330, height: 330)
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker(selection: $selectedPhoto) {
                        Label("Upload Your Clothes", systemImage: "photo.fill.on.rectangle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.vertical)
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                uploadedImage = uiImage
                                previewImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Form {
                        Section(header: Text("Clothing Details")) {
                            Picker("Clothes Type", selection: $selectedClothesType) {
                                Text("No type selected").tag(nil as String?)
                                
                                ForEach(ClothesType.allCases) { type in
                                    Label(type.rawValue, systemImage: type.iconName).tag(type as ClothesType?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            HStack {
                                Text("Thickness")
                                Spacer()
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= thickness ? "star.fill" : "star")
                                        .foregroundColor(star <= thickness ? .yellow : .gray)
                                        .onTapGesture {
                                            thickness = star
                                        }
                                }
                            }
                            
                            ColorPicker("Color", selection: $selectedColor)
                            
                            TextField("Material (e.g., Cotton, Wool, Denim)", text: $material)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView("Saving...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarBackButtonHidden()
            .navigationTitle("Add New Clothes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveClothes()
                    }
                    .disabled(!formIsValid || viewModel.isLoading)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Success" {
                            dismiss()
                        }
                    }
                )
            }
            .onChange(of: viewModel.errorMessage) {
                if !viewModel.errorMessage.isEmpty {
                    alertTitle = "Error"
                    alertMessage = viewModel.errorMessage
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveClothes() {
        guard let image = uploadedImage else {
            alertTitle = "Error"
            alertMessage = "Please select an image"
            showingAlert = true
            return
        }
        
        viewModel.saveClothesItem(
            image: image,
            type: selectedClothesType!,
            thickness: thickness,
            color: selectedColor,
            material: material
        )
        
        alertTitle = "Success"
        alertMessage = "Your clothes have been saved to your closet!"
        showingAlert = true
    }
}

#Preview {
    Add()
}
