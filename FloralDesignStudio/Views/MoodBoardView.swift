import SwiftUI
import PhotosUI
import UIKit
import CoreData

struct MoodBoardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FloralDesignViewModel
    let moodBoard: MoodBoardEntity
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImage: ImageEntity?
    @State private var showingImageDetail = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    // Back Button
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                    }
                    
                    Spacer()
                    
                    // Upload Button
                    if viewModel.canModifyMoodBoard(moodBoard) {
                        PhotosPicker(selection: $selectedItems,
                                   matching: .images) {
                            Circle()
                                .fill(Color(red: 34/255, green: 139/255, blue: 34/255))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                // Title
                Text("Mood Board")
                    .font(.custom("Zapfino", size: 32))
                    .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                
                // Content - Instagram-style layout
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(moodBoard.images as? Set<ImageEntity> ?? []), id: \.id) { imageEntity in
                            if let uiImage = coreDataManager.loadImage(from: imageEntity) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .clipped()
                                    .onTapGesture {
                                        selectedImage = imageEntity
                                        showingImageDetail = true
                                    }
                            }
                        }
                    }
                    .padding()
                }
                .padding(.top, 20)
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onChange(of: selectedItems) { _, items in
            Task {
                await handleImageSelection(items)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Image Options", isPresented: $showingImageDetail) {
            if viewModel.canModifyMoodBoard(moodBoard) {
                Button("Delete", role: .destructive) {
                    if let image = selectedImage {
                        deleteImage(image)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func handleImageSelection(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        
        await MainActor.run { isLoading = true }
        
        do {
            for item in items {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let _ = try await viewModel.saveImage(uiImage, forMoodBoard: moodBoard)
                }
            }
            
            await MainActor.run {
                selectedItems = []
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
                isLoading = false
            }
        }
    }
    
    private func deleteImage(_ image: ImageEntity) {
        coreDataManager.deleteImage(image)
        selectedImage = nil
        showingImageDetail = false
    }
}
