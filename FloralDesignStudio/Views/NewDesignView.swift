import SwiftUI
import CoreData

struct NewDesignView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FloralDesignViewModel
    
    @State private var title = ""
    @State private var designDescription = ""
    @State private var selectedClient: ClientEntity?
    @State private var status: DesignStatus = .draft
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Description", text: $designDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Picker("Client", selection: $selectedClient) {
                        Text("None").tag(nil as ClientEntity?)
                        ForEach(viewModel.clients) { client in
                            Text(client.name ?? "").tag(client as ClientEntity?)
                        }
                    }
                } header: {
                    Text("Client")
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach([
                            DesignStatus.draft,
                            DesignStatus.inProgress,
                            DesignStatus.review,
                            DesignStatus.completed,
                            DesignStatus.archived
                        ], id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                } header: {
                    Text("Status")
                }
            }
            .navigationTitle("New Design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        createDesign()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func createDesign() {
        _ = viewModel.createDesign(
            title: title,
            description: designDescription,
            client: selectedClient,
            status: status
        )
        dismiss()
    }
}

struct NewDesignView_Previews: PreviewProvider {
    static var previews: some View {
        NewDesignView(viewModel: FloralDesignViewModel())
    }
}
