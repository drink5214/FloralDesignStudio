import SwiftUI
import PhotosUI

struct NewMoodBoardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FloralDesignViewModel
    let design: DesignEntity?
    
    @State private var title = ""
    @State private var moodBoardDescription = ""
    @State private var selectedClient: ClientEntity?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var isLoading = false
    
    init(viewModel: FloralDesignViewModel, design: DesignEntity? = nil) {
        self.viewModel = viewModel
        self.design = design
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Title", text: $title)
                        TextField("Description", text: $moodBoardDescription, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    Section {
                        Picker("Client", selection: $selectedClient) {
                            Text("None").tag(nil as ClientEntity?)
                            ForEach(viewModel.clients) { client in
                                Text(client.name ?? "").tag(client as ClientEntity?)
                            }
                        }
                    } header: {
                        Text("Client")
                    }
                    
                    Section {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Add Images", systemImage: "photo.on.rectangle.angled")
                        }
                        
                        if !selectedPhotos.isEmpty {
                            Text("\(selectedPhotos.count) photos selected")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Mood Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createMoodBoard()
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhotos,
                maxSelectionCount: 10,
                matching: .images
            )
            .overlay {
                if isLoading {
                    Color(.systemBackground)
                        .opacity(0.8)
                        .ignoresSafeArea()
                    
                    ProgressView("Creating mood board...")
                }
            }
        }
    }
    
    private func createMoodBoard() {
        isLoading = true
        
        // Create the mood board
        let moodBoard = viewModel.createMoodBoard(
            title: title,
            description: moodBoardDescription,
            client: selectedClient,
            design: design
        )
        
        // Upload images
        Task {
            for item in selectedPhotos {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    if let _ = try? await viewModel.coreDataManager.saveImage(uiImage, forMoodBoard: moodBoard) {
                        // Image saved successfully
                    }
                }
            }
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}
