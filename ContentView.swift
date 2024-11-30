import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FloralDesignViewModel()
    @FocusState private var isPasswordFieldFocused: Bool
    
    // Custom colors
    let floralGreen = Color(red: 34/255, green: 139/255, blue: 34/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(white: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Floral Design Studio")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(floralGreen)
                        .padding(.top, 20)
                    
                    if !viewModel.isAuthenticated {
                        PasswordView(viewModel: viewModel, isPasswordFieldFocused: _isPasswordFieldFocused)
                    } else {
                        DashboardView(viewModel: viewModel)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PasswordView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    @State private var password = ""
    @FocusState var isPasswordFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            SecureField("Password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isPasswordFieldFocused)
                .submitLabel(.go)
                .onSubmit {
                    viewModel.authenticate(password: password)
                }
            
            Button("Enter Studio") {
                viewModel.authenticate(password: password)
            }
            .buttonStyle(GreenButtonStyle())
        }
        .padding(.horizontal, 40)
        .onAppear {
            isPasswordFieldFocused = true
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 1)
                    )
            )
            .foregroundColor(.green)
    }
}

struct DashboardView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    @State private var showingNewDesign = false
    
    var body: some View {
        VStack {
            HStack {
                Text("My Designs")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Spacer()
                
                if viewModel.currentUser?.canUpload == true {
                    UploadButton {
                        showingNewDesign = true
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.designs.isEmpty {
                ContentUnavailableView {
                    Label("No Designs", systemImage: "photo.on.rectangle.angled")
                        .foregroundColor(.green)
                } description: {
                    Text("Add your first floral design")
                        .foregroundColor(.green)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.designs) { design in
                            DesignCard(design: design, viewModel: viewModel)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingNewDesign) {
            NewDesignView(viewModel: viewModel)
        }
    }
}

struct DesignCard: View {
    let design: FloralDesign
    @ObservedObject var viewModel: FloralDesignViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(design.title)
                .font(.headline)
                .foregroundColor(.green)
            
            Text(design.description)
                .font(.subheadline)
                .foregroundColor(.green)
            
            HStack {
                Text("$\(String(format: "%.2f", design.price))")
                    .foregroundColor(.green)
                
                Spacer()
                
                if viewModel.currentUser?.canDelete == true {
                    DeleteButton {
                        viewModel.deleteDesign(design)
                    }
                }
                
                Text(design.status.rawValue)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct NewDesignView: View {
    @ObservedObject var viewModel: FloralDesignViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                    .foregroundColor(.green)
                
                TextField("Description", text: $description)
                    .foregroundColor(.green)
                
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.green)
            }
            .navigationTitle("New Design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if let priceValue = Double(price) {
                            viewModel.createDesign(
                                title: title,
                                description: description,
                                price: priceValue
                            )
                            dismiss()
                        }
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
}

// Custom button style for green buttons
struct GreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Color(red: 34/255, green: 139/255, blue: 34/255)
                    .shadow(radius: 3)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

// Custom circular button for upload
struct UploadButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color(red: 34/255, green: 139/255, blue: 34/255))
                        .shadow(radius: 3)
                )
        }
    }
}

// Custom circular button for delete
struct DeleteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.red)
                        .shadow(radius: 3)
                )
        }
    }
}

#Preview {
    ContentView()
}
