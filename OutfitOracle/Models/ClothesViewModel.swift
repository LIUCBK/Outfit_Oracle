//
//  ClothesViewModel.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ClothesViewModel: ObservableObject {
    @Published var clothesItems: [ClothesItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentOutfit: (jacket: ClothesItem?, top: ClothesItem?, bottom: ClothesItem?)
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    init() {
        // Initialize with nil outfit
        currentOutfit = (nil, nil, nil)
        fetchClothes()
    }
    
    func fetchClothes() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        
        db.collection("clothes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateAdded", descending: true)
            .addSnapshotListener { (snapshot, error) in
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching clothes: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No documents found"
                    return
                }
                
                self.clothesItems = documents.compactMap { document -> ClothesItem? in
                    do {
                        return try document.data(as: ClothesItem.self)
                    } catch {
                        print("Error decoding clothes item: \(error)")
                        return nil
                    }
                }
            }
    }
    
    // Generate a new outfit recommendation based on temperature
    func generateOutfitRecommendation(temperature: Double) {
        if clothesItems.isEmpty {
            // No clothes available
            currentOutfit = (nil, nil, nil)
            return
        }
        
        currentOutfit = OutfitRecommendationService.generateOutfitRecommendation(
            from: clothesItems,
            temperature: temperature
        )
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "AppError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        let filename = "\(userId)/clothes/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child(filename)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "AppError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    func saveClothesItem(image: UIImage, type: ClothesType, thickness: Int, color: Color, material: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        
        uploadImage(image) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let imageUrl):
                    let newClothesItem = ClothesItem(
                        userId: userId,
                        type: type,
                        thickness: thickness,
                        colorHex: color.toHex() ?? "#0000FF",
                        material: material,
                        imageURL: imageUrl.absoluteString,
                        dateAdded: Date()
                    )
                    
                    do {
                        _ = try self.db.collection("clothes").addDocument(from: newClothesItem)
                    } catch {
                        self.errorMessage = "Error saving clothes item: \(error.localizedDescription)"
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Error uploading image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteClothesItem(_ clothesItem: ClothesItem) {
        guard let id = clothesItem.id else { return }
        
        // Delete the image from storage
        if let imageURL = URL(string: clothesItem.imageURL) {
            let storageRef = storage.reference(forURL: imageURL.absoluteString)
            storageRef.delete { error in
                if let error = error {
                    print("Error deleting image: \(error.localizedDescription)")
                }
            }
        }
        
        // Delete the document from Firestore
        db.collection("clothes").document(id).delete() { error in
            if let error = error {
                self.errorMessage = "Error deleting item: \(error.localizedDescription)"
            }
        }
    }
    
    func getFilteredClothes(type: ClothesType?) -> [ClothesItem] {
        if let type = type {
            return clothesItems.filter { $0.type == type }
        } else {
            return clothesItems
        }
    }
    
    // For preview and testing purposes
    static func mockViewModel() -> ClothesViewModel {
        let model = ClothesViewModel()
        
        // Create sample clothes items
        let sampleItems: [ClothesItem] = [
            ClothesItem(
                id: "1",
                userId: "preview-user",
                type: .top,
                thickness: 2,
                colorHex: "#3B82F6", // Blue
                material: "Cotton",
                imageURL: "https://example.com/placeholder.jpg",
                dateAdded: Date()
            ),
            ClothesItem(
                id: "2",
                userId: "preview-user",
                type: .bottom,
                thickness: 4,
                colorHex: "#1F2937", // Dark blue/navy
                material: "Denim",
                imageURL: "https://example.com/placeholder.jpg",
                dateAdded: Date().addingTimeInterval(-86400) // 1 day ago
            ),
            ClothesItem(
                id: "3",
                userId: "preview-user",
                type: .jacket,
                thickness: 5,
                colorHex: "#4B5563", // Gray
                material: "Wool",
                imageURL: "https://example.com/placeholder.jpg",
                dateAdded: Date().addingTimeInterval(-172800) // 2 days ago
            )
        ]
        
        model.clothesItems = sampleItems
        model.isLoading = false
        
        return model
    }
}

// Extension to convert UIImage from SwiftUI Image
extension UIImage {
    @MainActor static func from(_ image: Image) -> UIImage? {
        let renderer = ImageRenderer(content: image)
        return renderer.uiImage
    }
}
