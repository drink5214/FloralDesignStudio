import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isDesigner: Bool = false
    @Published var selectedTab: Int = 0
    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published var activePath = NavigationPath()
    @Published var moodBoardImages: [UIImage] = []
    
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    func navigateToRoot() {
        activePath = NavigationPath()
    }
}