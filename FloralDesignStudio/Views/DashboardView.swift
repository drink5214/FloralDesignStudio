import SwiftUI
import PhotosUI

struct DashboardView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    @State private var showingNewDesignSheet = false
    @State private var showingNewMoodBoardSheet = false
    @State private var selectedDesign: DesignEntity?
    @State private var selectedMoodBoard: MoodBoardEntity?
    
    private let columns = [
        GridItem(.adaptive(minimum: 300), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !viewModel.designs.isEmpty {
                        designsSection
                    }
                    
                    if !viewModel.moodBoards.isEmpty {
                        moodBoardsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingNewDesignSheet = true }) {
                            Label("New Design", systemImage: "plus.square")
                        }
                        
                        Button(action: { showingNewMoodBoardSheet = true }) {
                            Label("New Mood Board", systemImage: "plus.rectangle.on.rectangle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewDesignSheet) {
                NewDesignView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNewMoodBoardSheet) {
                NewMoodBoardView(viewModel: viewModel)
            }
            .sheet(item: $selectedDesign) { design in
                DesignDetailView(viewModel: viewModel, design: design)
            }
            .sheet(item: $selectedMoodBoard) { moodBoard in
                ImageDetailView(viewModel: viewModel, moodBoard: moodBoard)
            }
        }
    }
    
    private var designsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Designs")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.designs) { design in
                    DesignCard(design: design)
                        .onTapGesture {
                            selectedDesign = design
                        }
                }
            }
        }
    }
    
    private var moodBoardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Boards")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.moodBoards) { moodBoard in
                    MoodBoardCard(moodBoard: moodBoard)
                        .onTapGesture {
                            selectedMoodBoard = moodBoard
                        }
                }
            }
        }
    }
}

struct DesignCard: View {
    let design: DesignEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(design.title ?? "Untitled Design")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(design.designDescription ?? "No description")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(design.status ?? "draft")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
                
                Spacer()
                
                if let updatedAt = design.updatedAt {
                    Text(updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private var statusColor: Color {
        guard let status = design.status else { return .gray }
        switch status {
        case "draft":
            return .gray
        case "inProgress":
            return .blue
        case "review":
            return .orange
        case "completed":
            return .green
        case "archived":
            return .purple
        default:
            return .gray
        }
    }
}

struct MoodBoardCard: View {
    let moodBoard: MoodBoardEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let images = moodBoard.images as? Set<ImageEntity>,
               let firstImage = images.first,
               let imagePath = firstImage.imagePath {
                AsyncImage(url: URL(fileURLWithPath: imagePath)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(height: 150)
                }
            } else {
                Color.gray.opacity(0.2)
                    .frame(height: 150)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(moodBoard.title ?? "Untitled Mood Board")
                    .font(.headline)
                
                Text(moodBoard.moodBoardDescription ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let updatedAt = moodBoard.updatedAt {
                    Text(updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
