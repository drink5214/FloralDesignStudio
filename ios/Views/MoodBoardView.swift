import SwiftUI

struct MoodBoardView: View {
    @EnvironmentObject var appState: AppState
    @State private var isImagePickerPresented = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            Text("Mood Board")
                .font(.largeTitle)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(appState.selectedMoodBoardImages.indices, id: \.self) { index in
                        Image(uiImage: appState.selectedMoodBoardImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    source = .camera
                    isImagePickerPresented = true
                }) {
                    Text("Take Photo")
                }
                
                Button(action: {
                    source = .photoLibrary
                    isImagePickerPresented = true
                }) {
                    Text("Choose Photo")
                }
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(sourceType: source) { image in
                if let image = image {
                    appState.selectedMoodBoardImages.append(image)
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let completionHandler: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completionHandler: (UIImage?) -> Void
        
        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            completionHandler(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true)
        }
    }
}
