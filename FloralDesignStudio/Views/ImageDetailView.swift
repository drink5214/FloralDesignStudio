import SwiftUI

struct ImageDetailView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    let moodBoard: MoodBoardEntity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(moodBoard.title ?? "Untitled Mood Board")
                        .font(.title)
                        .padding(.horizontal)
                    
                    if let images = moodBoard.images as? Set<ImageEntity> {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                            ForEach(Array(images), id: \.id) { image in
                                if let imagePath = image.imagePath {
                                    AsyncImage(url: URL(fileURLWithPath: imagePath)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .clipped()
                                            .cornerRadius(8)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(height: 200)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
