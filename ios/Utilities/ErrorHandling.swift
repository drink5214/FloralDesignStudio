import Foundation

enum AppError: Error {
    case authenticationFailed(String)
    case networkError(String)
    case dataError(String)
    case imageError(String)
    case storageError(String)
    
    var localizedDescription: String {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .imageError(let message):
            return "Image Error: \(message)"
        case .storageError(let message):
            return "Storage Error: \(message)"
        }
    }
}

class ErrorHandler {
    static func handle(_ error: AppError) {
        // TODO: Implement proper error handling and logging
        print(error.localizedDescription)
    }
    
    static func handle(_ error: Error) {
        // Handle unknown errors
        print("Unknown Error: \(error.localizedDescription)")
    }
}
