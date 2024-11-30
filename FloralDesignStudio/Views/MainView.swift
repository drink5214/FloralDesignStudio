import SwiftUI

// MARK: - Navigation Button
struct MainNavigationButton: View {
    let title: String
    let action: () -> Void
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Helvetica", size: 20))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 34/255, green: 139/255, blue: 34/255))
                )
        }
    }
}

// MARK: - Main Content
struct MainContent: View {
    @Binding var showMoodBoard: Bool
    @Binding var showIntakeForms: Bool
    @Binding var showChat: Bool
    @Binding var showClientList: Bool
    
    var body: some View {
        ZStack {
            // Background Image
            Image("floral_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("Floral Design Studio")
                    .font(.custom("Zapfino", size: 36))
                    .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Top Row
                HStack(spacing: 20) {
                    MainNavigationButton(
                        title: "Mood\nBoard",
                        action: { showMoodBoard = true },
                        width: 150,
                        height: 150
                    )
                    
                    MainNavigationButton(
                        title: "Floral\nPlan",
                        action: { showIntakeForms = true },
                        width: 150,
                        height: 150
                    )
                }
                
                // Middle Row
                HStack(spacing: 20) {
                    MainNavigationButton(
                        title: "Floral\nContract",
                        action: { },
                        width: 150,
                        height: 150
                    )
                    
                    MainNavigationButton(
                        title: "Chat",
                        action: { showChat = true },
                        width: 150,
                        height: 150
                    )
                }
                
                // Bottom Row - Client List
                MainNavigationButton(
                    title: "Client List",
                    action: { showClientList = true },
                    width: 320,
                    height: 80
                )
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Main View
struct MainView: View {
    @EnvironmentObject var viewModel: FloralDesignViewModel
    @State private var showMoodBoard = false
    @State private var showIntakeForms = false
    @State private var showChat = false
    @State private var showClientList = false
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                MainContent(
                    showMoodBoard: $showMoodBoard,
                    showIntakeForms: $showIntakeForms,
                    showChat: $showChat,
                    showClientList: $showClientList
                )
                .fullScreenCover(isPresented: $showMoodBoard) {
                    if let currentUser = viewModel.currentUser {
                        NewMoodBoardView(viewModel: viewModel)
                    }
                }
                .sheet(isPresented: $showIntakeForms) {
                    IntakeFormView()
                }
                .sheet(isPresented: $showChat) {
                    Text("Chat View Coming Soon")
                }
                .sheet(isPresented: $showClientList) {
                    Text("Client List Coming Soon")
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(FloralDesignViewModel())
}
