import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FloralDesignViewModel()
    
    var body: some View {
        NavigationView {
            if viewModel.isAuthenticated {
                DashboardView(viewModel: viewModel)
            } else {
                LoginView()
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
