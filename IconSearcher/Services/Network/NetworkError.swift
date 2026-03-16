import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case serverError(statusCode: Int)
    case decodingError(Error)
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode the server's response: \(error.localizedDescription)"
        case .other(let error):
            return error.localizedDescription
        } 
    }
}
