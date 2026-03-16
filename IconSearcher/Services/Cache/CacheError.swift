import Foundation

enum CacheError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileSystemError(Error)
    case caсheDirectoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data for caching: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode cached data: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "A file system error occurred: \(error.localizedDescription)"
        case .caсheDirectoryNotFound:
            return "Could not find or create cache directory."
        }
    }
}
