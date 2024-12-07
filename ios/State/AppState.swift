import SwiftUI

class AppState: ObservableObject {
    @Published var isDesigner: Bool = false
    @Published var currentUser: User?
    @Published var selectedMoodBoardImages: [UIImage] = []
    
    struct User {
        var id: String
        var name: String
        var email: String
        var isDesigner: Bool
    }
    
    func signIn(email: String, password: String) {
        // TODO: Implement authentication
    }
    
    func signOut() {
        currentUser = nil
        isDesigner = false
    }
}
