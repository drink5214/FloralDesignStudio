import SwiftUI

struct MainLandingPage: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text("Floral Design Studio")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    NavigationLink("Mood Board") {
                        MoodBoardView()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    if appState.isDesigner {
                        NavigationLink("Client List") {
                            Text("Client List View")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
        }
        .environmentObject(appState)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}