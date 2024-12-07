import SwiftUI

struct MainLandingPage: View {
    @EnvironmentObject var appState: AppState
    
    struct GreenButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.4, green: 0.8, blue: 0.4)) // Default green color
                .foregroundColor(.white)
                .cornerRadius(10)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Floral Design Studio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Spacer()
                
                VStack(spacing: 15) {
                    NavigationLink(destination: MoodBoardView()) {
                        Text("Mood Board")
                    }
                    .buttonStyle(GreenButtonStyle())
                    
                    NavigationLink(destination: Text("Floral Plan View")) {
                        Text("Floral Plan")
                    }
                    .buttonStyle(GreenButtonStyle())
                    
                    NavigationLink(destination: Text("Floral Contract View")) {
                        Text("Floral Contract")
                    }
                    .buttonStyle(GreenButtonStyle())
                    
                    NavigationLink(destination: Text("Chat View")) {
                        Text("Chat")
                    }
                    .buttonStyle(GreenButtonStyle())
                    
                    if appState.isDesigner {
                        NavigationLink(destination: Text("Client List View")) {
                            Text("Client List")
                        }
                        .buttonStyle(GreenButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct MainLandingPage_Previews: PreviewProvider {
    static var previews: some View {
        MainLandingPage()
            .environmentObject(AppState())
    }
}
