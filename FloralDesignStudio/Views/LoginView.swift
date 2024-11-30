import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: FloralDesignViewModel
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color(white: 0.98)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Title
                    Text("Floral Design Studio")
                        .font(.custom("Zapfino", size: 36))
                        .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.horizontal)
                    
                    // Password Field
                    VStack(spacing: 20) {
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 250)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                            .focused($isPasswordFocused)
                            .submitLabel(.done)
                            .accessibilityLabel("Enter password")
                        
                        // Login Button
                        Button(action: login) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(password.isEmpty ? Color.gray : Color(red: 34/255, green: 139/255, blue: 34/255))
                                    .frame(width: 200, height: 44)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Enter Studio")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(password.isEmpty || isLoading)
                        .accessibilityLabel(isLoading ? "Logging in" : "Enter Studio button")
                        .accessibilityHint("Double tap to enter")
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                isPasswordFocused = true
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            isPasswordFocused = true
        }
    }
    
    private func login() {
        guard !password.isEmpty else {
            errorMessage = "Please enter the password"
            showError = true
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // For demo, just log in as designer
            viewModel.login(username: "Designer", email: "designer@example.com", role: .designer)
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(FloralDesignViewModel())
}
