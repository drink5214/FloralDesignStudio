import SwiftUI
import CoreData

@MainActor
class FloralDesignViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published private(set) var clients: [ClientEntity] = []
    @Published private(set) var designs: [DesignEntity] = []
    @Published private(set) var moodBoards: [MoodBoardEntity] = []
    
    let coreDataManager = CoreDataManager.shared
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe CoreData changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContext.didChangeObjectsNotification,
            object: coreDataManager.context
        )
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        // Update published properties when CoreData changes
        Task { @MainActor in
            self.clients = coreDataManager.fetchAllClients()
            self.designs = coreDataManager.fetchAllDesigns()
            self.moodBoards = coreDataManager.fetchAllMoodBoards()
        }
    }
    
    // MARK: - Authentication
    
    func login(username: String, email: String, role: UserRole) {
        let user = User(username: username, email: email, role: role)
        self.currentUser = user
        self.isAuthenticated = true
        
        // Create or update user entity
        _ = findOrCreateUserEntity(for: user)
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Authorization
    
    func canModifyMoodBoard(_ moodBoard: MoodBoardEntity) -> Bool {
        guard let currentUser = currentUser else { return false }
        
        switch currentUser.role {
        case .admin:
            return true
        case .designer:
            return moodBoard.design?.designer?.asUser.id == currentUser.id
        case .client:
            return moodBoard.client?.asClient.id == currentUser.id
        }
    }
    
    // MARK: - MoodBoard Management
    
    func createMoodBoard(title: String, description: String, client: ClientEntity?, design: DesignEntity?) -> MoodBoardEntity {
        coreDataManager.createMoodBoard(title: title, description: description, client: client, design: design)
    }
    
    func deleteMoodBoard(_ moodBoard: MoodBoardEntity) {
        coreDataManager.deleteMoodBoard(moodBoard)
    }
    
    // MARK: - Image Management
    
    func saveImage(_ image: UIImage, forMoodBoard moodBoard: MoodBoardEntity) async throws -> ImageEntity {
        try await coreDataManager.saveImage(image, forMoodBoard: moodBoard)
    }
    
    // MARK: - Design Management
    
    func createDesign(title: String, description: String, client: ClientEntity?, status: DesignStatus) -> DesignEntity? {
        guard let currentUser = currentUser else { return nil }
        guard let userEntity = findOrCreateUserEntity(for: currentUser) else { return nil }
        let design = coreDataManager.createDesign(
            title: title,
            description: description,
            designer: userEntity,
            client: client,
            status: status
        )
        return design
    }
    
    func deleteDesign(_ design: DesignEntity) {
        guard canModifyDesign(design) else { return }
        coreDataManager.deleteDesign(design)
    }
    
    func updateDesign(_ design: DesignEntity, title: String, description: String, status: DesignStatus) {
        guard canModifyDesign(design) else { return }
        
        design.title = title
        design.designDescription = description
        design.status = status.rawValue
        design.updatedAt = Date()
        
        do {
            try coreDataManager.context.save()
        } catch {
            print("Error updating design: \(error)")
        }
    }
    
    func canModifyDesign(_ design: DesignEntity) -> Bool {
        guard let currentUser = currentUser else { return false }
        
        switch currentUser.role {
        case .admin:
            return true
        case .designer:
            return design.designer?.asUser.id == currentUser.id
        case .client:
            return false
        }
    }
    
    // MARK: - Client Management
    
    func createClient(name: String, email: String?, phone: String?) -> ClientEntity {
        coreDataManager.createClient(name: name, email: email, phone: phone)
    }
    
    func fetchAllClients() -> [ClientEntity] {
        coreDataManager.fetchAllClients()
    }
    
    // MARK: - Helper Methods
    
    private func findOrCreateUserEntity(for user: User) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        if let existingUser = try? coreDataManager.context.fetch(request).first {
            return existingUser
        }
        
        return coreDataManager.createUser(
            username: user.username,
            email: user.email,
            role: user.role.rawValue
        )
    }
}
