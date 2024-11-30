import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FloralDesign")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Image Management
    
    func saveImage(_ image: UIImage, forMoodBoard moodBoard: MoodBoardEntity) async throws -> ImageEntity {
        let imageEntity = ImageEntity(context: context)
        imageEntity.id = UUID()
        imageEntity.uploadedAt = Date()
        imageEntity.moodBoard = moodBoard
        
        // Save image to Documents directory asynchronously
        return try await Task {
            let imagePath = try saveImageToDocuments(image, withId: imageEntity.id!)
            imageEntity.imagePath = imagePath
            saveContext()
            return imageEntity
        }.value
    }
    
    func loadImage(from imageEntity: ImageEntity) -> UIImage? {
        guard let imagePath = imageEntity.imagePath else { return nil }
        return loadImageFromDocuments(atPath: imagePath)
    }
    
    func deleteImage(_ imageEntity: ImageEntity) {
        if let imagePath = imageEntity.imagePath {
            deleteImageFromDocuments(atPath: imagePath)
        }
        context.delete(imageEntity)
        saveContext()
    }
    
    // MARK: - File Management
    
    private func saveImageToDocuments(_ image: UIImage, withId id: UUID) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "com.floraldesignstudio", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])
        }
        
        let filename = "\(id.uuidString).jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDirectory = documentsDirectory.appendingPathComponent("Images", isDirectory: true)
        
        // Create Images directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        
        let fileURL = imageDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL)
        
        return fileURL.path
    }
    
    private func loadImageFromDocuments(atPath path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }
    
    private func deleteImageFromDocuments(atPath path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
    
    // MARK: - MoodBoard Management
    
    func createMoodBoard(title: String, description: String, client: ClientEntity?, design: DesignEntity?) -> MoodBoardEntity {
        let moodBoard = MoodBoardEntity(context: context)
        moodBoard.id = UUID()
        moodBoard.title = title
        moodBoard.moodBoardDescription = description
        moodBoard.client = client
        moodBoard.design = design
        moodBoard.createdAt = Date()
        moodBoard.updatedAt = Date()
        
        saveContext()
        return moodBoard
    }
    
    func deleteMoodBoard(_ moodBoard: MoodBoardEntity) {
        // Delete associated images first
        if let images = moodBoard.images as? Set<ImageEntity> {
            images.forEach { deleteImage($0) }
        }
        
        context.delete(moodBoard)
        saveContext()
    }
    
    func fetchAllMoodBoards() -> [MoodBoardEntity] {
        let request: NSFetchRequest<MoodBoardEntity> = MoodBoardEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodBoardEntity.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching mood boards: \(error)")
            return []
        }
    }
    
    // MARK: - Design Management
    
    func createDesign(title: String, description: String, designer: UserEntity, client: ClientEntity?, status: DesignStatus = .draft) -> DesignEntity {
        let design = DesignEntity(context: context)
        design.id = UUID()
        design.title = title
        design.designDescription = description
        design.designer = designer
        design.client = client
        design.status = status.rawValue
        design.createdAt = Date()
        design.updatedAt = Date()
        
        saveContext()
        return design
    }
    
    func deleteDesign(_ design: DesignEntity) {
        context.delete(design)
        saveContext()
    }
    
    func fetchAllDesigns() -> [DesignEntity] {
        let request: NSFetchRequest<DesignEntity> = DesignEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DesignEntity.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching designs: \(error)")
            return []
        }
    }
    
    // MARK: - Client Management
    
    func createClient(name: String, email: String?, phone: String?) -> ClientEntity {
        let client = ClientEntity(context: context)
        client.id = UUID()
        client.name = name
        client.email = email
        client.phone = phone
        
        saveContext()
        return client
    }
    
    func fetchAllClients() -> [ClientEntity] {
        let request: NSFetchRequest<ClientEntity> = ClientEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ClientEntity.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching clients: \(error)")
            return []
        }
    }
    
    // MARK: - User Management
    
    func createUser(username: String, email: String, role: String) -> UserEntity {
        let user = UserEntity(context: context)
        user.id = UUID()
        user.username = username
        user.email = email
        user.role = role
        
        saveContext()
        return user
    }
    
    func fetchAllUsers() -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserEntity.username, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
}
