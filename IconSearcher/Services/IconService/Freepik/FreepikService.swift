import Foundation

private struct FreepikApiKeys: Codable {
    let freepikApiKey: String
}

final class FreepikService: IconServiceProtocol {
    
    // MARK: - Properties
    
    private let apiKey: String
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Initialization

    init(
        apiKey: String,
        networkManager: NetworkManagerProtocol
    ) {
        precondition(!apiKey.isEmpty, "API key must not be empty")
        self.apiKey = apiKey
        self.networkManager = networkManager
    }
    
    convenience init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        let apiKey = Self.loadApiKeyFromBundle() ?? ""
        self.init(apiKey: apiKey, networkManager: networkManager)
    }
    
    // MARK: - IconServiceProtocol
    
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    ) {
        var components = API.Freepik.components
        let page = (start / limit) + 1
        
        components.queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = components.url else {
            completion(.failure(FreepikServiceError.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: API.Freepik.apiKeyHeader)
        
        networkManager.request(with: request) { [weak self] (result: Result<FreepikResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let icons = self.map(freepikIcons: response.data)
                let total = response.meta.pagination.total
                completion(.success((icons, total)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func map(freepikIcons: [FreepikIcon]) -> [Icon] {
        return freepikIcons.compactMap { freepikIcon in
            guard let bestThumbnail = freepikIcon.thumbnails.max(by: { $0.width < $1.width }) else {
                return nil
            }
            
            let tags = freepikIcon.tags?.map { $0.name } ?? []
            
            return Icon(
                name: freepikIcon.name,
                tags: tags,
                url: bestThumbnail.url,
                width: bestThumbnail.width,
                height: bestThumbnail.height
            )
        }
    }
    
    // MARK: - Bundle Loading (private)

    private static func loadApiKeyFromBundle() -> String? {
        guard let keysFileURL = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {
            assertionFailure("Keys.plist not found. This is expected in unit tests.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: keysFileURL)
            let decoder = PropertyListDecoder()
            let keys = try decoder.decode(FreepikApiKeys.self, from: data)
            
            if keys.freepikApiKey.isEmpty {
                assertionFailure("Keys.plist is empty")
                return nil
            }
            
            return keys.freepikApiKey
        } catch {
            assertionFailure("Could not decode Keys.plist: \(error)")
            return nil
        }
    }
}
