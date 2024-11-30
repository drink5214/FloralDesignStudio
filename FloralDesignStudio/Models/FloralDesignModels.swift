import Foundation
import SwiftUI
import CoreData

// MARK: - Model Types

enum UserRole: String, Codable {
    case admin
    case designer
    case client
}

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var role: UserRole
    
    init(id: UUID = UUID(), username: String, email: String, role: UserRole) {
        self.id = id
        self.username = username
        self.email = email
        self.role = role
    }
}

enum DesignStatus: String, Codable {
    case draft = "Draft"
    case inProgress = "In Progress"
    case review = "Review"
    case completed = "Completed"
    case archived = "Archived"
}

struct FloralDesign: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var status: DesignStatus
    let createdAt: Date
    var updatedAt: Date
    var client: Client?
    var designer: User?
    var moodBoards: [MoodBoard]
    
    init(id: UUID = UUID(), title: String, description: String, status: DesignStatus = .draft, createdAt: Date = Date(), updatedAt: Date = Date(), client: Client? = nil, designer: User? = nil, moodBoards: [MoodBoard] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.client = client
        self.designer = designer
        self.moodBoards = moodBoards
    }
}

struct MoodBoard: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    let createdAt: Date
    var updatedAt: Date
    var client: Client?
    var design: FloralDesign?
    var images: [MoodBoardImage]
    
    init(id: UUID = UUID(), title: String, description: String, createdAt: Date = Date(), updatedAt: Date = Date(), client: Client? = nil, design: FloralDesign? = nil, images: [MoodBoardImage] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.client = client
        self.design = design
        self.images = images
    }
}

struct MoodBoardImage: Identifiable, Codable {
    let id: UUID
    let imagePath: String
    let uploadedAt: Date
    
    init(id: UUID = UUID(), imagePath: String, uploadedAt: Date = Date()) {
        self.id = id
        self.imagePath = imagePath
        self.uploadedAt = uploadedAt
    }
}

struct Client: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String?
    var phone: String?
    
    init(id: UUID = UUID(), name: String, email: String? = nil, phone: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
    }
}

// MARK: - Message Model
struct Message: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var content: String
    var sender: User
    var receiver: User
    var designId: UUID?
    var createdAt: Date
    var updatedAt: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), 
         content: String, 
         sender: User, 
         receiver: User, 
         designId: UUID? = nil, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date(),
         isRead: Bool = false) {
        self.id = id
        self.content = content
        self.sender = sender
        self.receiver = receiver
        self.designId = designId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isRead = isRead
    }
    
    // Convenience initializer for quick message creation
    static func create(content: String, from sender: User, to receiver: User, designId: UUID? = nil) -> Message {
        Message(content: content, sender: sender, receiver: receiver, designId: designId)
    }
}

// MARK: - Message Extensions
extension Message {
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // For Equatable conformance
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    // User role-based helpers
    var isFromUser: Bool {
        sender.role == .client
    }
    
    var isFromDesigner: Bool {
        sender.role == .designer
    }
    
    // Formatted timestamp for display
    var displayTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        
        let timeDiff = Date().timeIntervalSince(createdAt)
        if timeDiff < 24 * 60 * 60 { // Less than 24 hours
            return createdAt.formatted(date: .omitted, time: .shortened)
        } else {
            return formatter.localizedString(for: createdAt, relativeTo: Date())
        }
    }
}

// MARK: - Chat Model
struct Chat: Codable, Identifiable {
    let id: UUID
    var participants: [User]
    var messages: [Message]
    var lastMessage: Message?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), participants: [User], messages: [Message] = [], lastMessage: Message? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.participants = participants
        self.messages = messages
        self.lastMessage = lastMessage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - CoreData Extensions
extension UserEntity {
    var roleEnum: UserRole {
        get {
            UserRole(rawValue: role ?? "client") ?? .client
        }
        set {
            role = newValue.rawValue
        }
    }
    
    var asUser: User {
        User(id: id ?? UUID(),
             username: username ?? "",
             email: email ?? "",
             role: roleEnum)
    }
}

extension DesignEntity {
    var statusEnum: DesignStatus {
        get {
            DesignStatus(rawValue: status ?? "Draft") ?? .draft
        }
        set {
            status = newValue.rawValue
        }
    }
    
    var designStatus: DesignStatus {
        get { statusEnum }
        set { statusEnum = newValue }
    }
    
    var asDesign: FloralDesign {
        FloralDesign(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            description: self.designDescription ?? "",
            status: statusEnum,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date(),
            client: self.client?.asClient,
            designer: self.designer?.asUser,
            moodBoards: self.moodBoard.map { [$0.asMoodBoard] } ?? []
        )
    }
}

extension MoodBoardEntity {
    var asMoodBoard: MoodBoard {
        MoodBoard(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            description: self.moodBoardDescription ?? "",
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date(),
            client: self.client?.asClient,
            design: self.design?.asDesign,
            images: (self.images?.allObjects as? [ImageEntity])?.map { $0.asMoodBoardImage } ?? []
        )
    }
}

extension ImageEntity {
    var asMoodBoardImage: MoodBoardImage {
        MoodBoardImage(
            id: self.id ?? UUID(),
            imagePath: self.imagePath ?? "",
            uploadedAt: self.uploadedAt ?? Date()
        )
    }
}

extension ClientEntity {
    var asClient: Client {
        Client(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            email: self.email,
            phone: self.phone
        )
    }
}
