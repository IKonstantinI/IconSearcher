import Foundation

private struct FreepikApiKeys: Codable {
    let freepikApiKey: String
}

enum FreepikServiceFactory {
    
    static func makeDefault() -> FreepikService? {
        guard let apiKey = loadApiKeyFromBundle(), !apiKey.isEmpty else {
            return nil
        }
        
        let networkManager = NetworkManager()
        return FreepikService(apiKey: apiKey, networkManager: networkManager)
    }

    static func makeWithApiKey(_ apiKey: String) -> FreepikService {
        let networkManager = NetworkManager()
        return FreepikService(apiKey: apiKey, networkManager: networkManager)
    }
    
    // MARK: - Private
    
    private static func loadApiKeyFromBundle() -> String? {
        guard let keysFileURL = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: keysFileURL)
            let decoder = PropertyListDecoder()
            let keys = try decoder.decode(FreepikApiKeys.self, from: data)
            return keys.freepikApiKey.isEmpty ? nil : keys.freepikApiKey
        } catch {
            return nil
        }
    }
}

