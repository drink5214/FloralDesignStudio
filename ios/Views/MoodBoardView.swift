import SwiftUI

struct MoodBoardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingOptions = false
    
    var body: some View {
        VStack {
            Text("Mood Board")
                .font(.largeTitle)
            
            Button("Upload") {
                showingOptions = true
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary)
        }
    }
}