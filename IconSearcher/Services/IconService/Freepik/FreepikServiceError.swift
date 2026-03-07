import Foundation

enum FreepikServiceError: Error, LocalizedError {
    case apiKeyMissing
    case badURL
    
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key for Freepik is not configured correctly. Check Keys.plist and console logs."
        case .badURL:
            return "Could not construct a valid URL for the Freepik API request."
        }
    }
}
