import Foundation

enum AppError: Error {
    case imagePickerError(String)
    case saveError(String)
    case loadError(String)
    case permissionDenied(String)
    
    var localizedDescription: String {
        switch self {
        case .imagePickerError(let message):
            return "Image Error: \(message)"
        case .saveError(let message):
            return "Save Error: \(message)"
        case .loadError(let message):
            return "Load Error: \(message)"
        case .permissionDenied(let message):
            return "Permission Denied: \(message)"
        }
    }
}