import SwiftUI
import PhotosUI
import CoreData

// MARK: - Design Header View
struct DesignHeaderView: View {
    let design: DesignEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(design.title ?? "")
                .font(.title)
                .foregroundColor(AppColors.forestGreen)
            
            Text(design.designDescription ?? "")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

// MARK: - Client Information View
struct ClientInformationView: View {
    let client: UserEntity?
    
    var body: some View {
        if let client = client {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name: \(client.username ?? "")")
                    Text("Email: \(client.email ?? "")")
                }
                .padding(.horizontal)
            } header: {
                Text("Client Information")
                    .font(.headline)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Design Status View
struct DesignStatusView: View {
    let status: DesignStatus
    
    var body: some View {
        Section {
            Text(status.rawValue.capitalized)
                .padding(.horizontal)
                .foregroundColor(statusColor)
        } header: {
            Text("Status")
                .font(.headline)
                .padding(.horizontal)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .draft:
            return .gray
        case .inProgress:
            return .blue
        case .review:
            return .orange
        case .completed:
            return .green
        case .archived:
            return .purple
        }
    }
}

// MARK: - Design Action Buttons
struct DesignActionButtons: View {
    let design: DesignEntity
    @Binding var showingImagePicker: Bool
    @Binding var showingDeleteAlert: Bool
    @EnvironmentObject var viewModel: FloralDesignViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            if viewModel.canModifyDesign(design) {
                Button {
                    showingImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Add Images")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.forestGreen)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Design")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Main Design Detail View
struct DesignDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FloralDesignViewModel
    let design: DesignEntity
    
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedStatus: DesignStatus = .draft
    @State private var showingDeleteAlert = false
    @State private var showingNewMoodBoard = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Design Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        if isEditing {
                            editableInfoSection
                        } else {
                            displayInfoSection
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    // Mood Boards Section
                    if let moodBoard = design.moodBoard, moodBoard.title != nil {
                        moodBoardsSection
                    }
                }
                .padding()
            }
            .navigationTitle(design.title ?? "Design Details")
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
                    Menu {
                        Button(role: .destructive, action: deleteDesign) {
                            Label("Delete Design", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .alert("Delete Design", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteDesign()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this design? This action cannot be undone.")
            }
        }
    }
    
    private var editableInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $editedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $editedDescription, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
            
            Picker("Status", selection: $editedStatus) {
                Text("Draft").tag(DesignStatus.draft)
                Text("In Progress").tag(DesignStatus.inProgress)
                Text("Review").tag(DesignStatus.review)
                Text("Completed").tag(DesignStatus.completed)
                Text("Archived").tag(DesignStatus.archived)
            }
        }
    }
    
    private var displayInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(design.title ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(design.designDescription ?? "")
                .font(.body)
                .foregroundColor(.gray)
            
            if let status = DesignStatus(rawValue: design.status ?? "") {
                DesignStatusView(status: status)
            }
            
            if let client = design.client {
                Text("Client: \(client.name ?? "")")
                    .font(.subheadline)
            }
            
            if let designer = design.designer {
                Text("Designer: \(designer.username ?? "")")
                    .font(.subheadline)
            }
        }
    }
    
    private var moodBoardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Board")
                .font(.title3)
                .fontWeight(.bold)
            
            if let moodBoard = design.moodBoard {
                NavigationLink(destination: MoodBoardView(viewModel: viewModel, moodBoard: moodBoard)) {
                    MoodBoardRow(moodBoard: moodBoard)
                }
            }
        }
    }
    
    private var addMoodBoardButton: some View {
        Button(action: {
            showingNewMoodBoard = true
        }) {
            Label("Add Mood Board", systemImage: "plus.circle.fill")
        }
        .sheet(isPresented: $showingNewMoodBoard) {
            NavigationView {
                NewMoodBoardView(
                    viewModel: viewModel,
                    design: design
                )
            }
        }
    }
    
    private var editButton: some View {
        Button(action: {
            if isEditing {
                // Save changes through ViewModel when exiting edit mode
                viewModel.updateDesign(
                    design,
                    title: editedTitle,
                    description: editedDescription,
                    status: editedStatus
                )
            } else {
                // Start editing
                editedTitle = design.title ?? ""
                editedDescription = design.designDescription ?? ""
                editedStatus = DesignStatus(rawValue: design.status ?? "") ?? .draft
            }
            isEditing.toggle()
        }) {
            Text(isEditing ? "Done" : "Edit")
        }
    }
    
    private func deleteDesign() {
        viewModel.deleteDesign(design)
        dismiss()
    }
}

// MARK: - Supporting Views
struct MoodBoardRow: View {
    let moodBoard: MoodBoardEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(moodBoard.title ?? "")
                    .font(.headline)
                Text(moodBoard.moodBoardDescription ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
