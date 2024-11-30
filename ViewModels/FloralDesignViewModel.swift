import Foundation
import SwiftUI

@MainActor
class FloralDesignViewModel: ObservableObject {
    @Published var designs: [FloralDesign] = []
    @Published var messages: [Message] = []
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    // For demo purposes - replace with secure authentication
    private let adminPassword = "admin123"
    private let clientPassword = "client123"
    
    // MARK: - Authentication
    
    func authenticate(password: String) {
        if password == adminPassword {
            currentUser = User(id: UUID(), name: "Admin", role: .admin)
            isAuthenticated = true
        } else if password == clientPassword {
            currentUser = User(id: UUID(), name: "Client", role: .client)
            isAuthenticated = true
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Design Management
    
    func createDesign(title: String, description: String, price: Double) {
        guard let user = currentUser else { return }
        
        let newDesign = FloralDesign(
            title: title,
            description: description,
            price: price,
            uploadedBy: user
        )
        designs.append(newDesign)
    }
    
    func updateDesign(_ design: FloralDesign) {
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            designs[index] = design
        }
    }
    
    func deleteDesign(_ design: FloralDesign) {
        guard let user = currentUser, user.canDelete else { return }
        designs.removeAll { $0.id == design.id }
    }
    
    // MARK: - Message Management
    
    func sendMessage(content: String, designId: UUID, attachments: [String] = []) {
        guard let user = currentUser else { return }
        
        let message = Message(
            id: UUID(),
            sender: user,
            content: content,
            timestamp: Date(),
            attachments: attachments,
            designId: designId
        )
        messages.append(message)
    }
    
    func getMessages(for designId: UUID) -> [Message] {
        return messages.filter { $0.designId == designId }
    }
    
    // MARK: - Image Management
    
    func uploadImage() async throws {
        guard let user = currentUser, user.canUpload else { return }
        // TODO: Implement image upload functionality using PhotosPicker
    }
    
    func deleteImage(_ imageURL: String, from design: FloralDesign) {
        guard let user = currentUser, user.canDelete else { return }
        if var updatedDesign = designs.first(where: { $0.id == design.id }) {
            updatedDesign.imageURLs.removeAll { $0 == imageURL }
            updateDesign(updatedDesign)
        }
    }
}
