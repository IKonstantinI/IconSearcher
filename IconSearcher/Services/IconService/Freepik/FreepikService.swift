import Foundation

private struct ApiKeys: Codable {
    let freepikApiKey: String
}

final class FreepikService: IconServiceProtocol {
    
    private let networkManager: NetworkManagerProtocol
    private let apiKey: String?
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
        self.apiKey = Self.loadApiKey()
    }
    
    private static func loadApiKey() -> String? {
        guard let keysFileURL = Bundle.main.url(forResource: "Keys", withExtension: "plist") else {
            assertionFailure("Keys.plist not found.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: keysFileURL)
            let decoder = PropertyListDecoder()
            let keys = try decoder.decode(ApiKeys.self, from: data)
            
            if keys.freepikApiKey.isEmpty {
                assertionFailure("Keys.plist is empty")
                return nil
            }
            
            return keys.freepikApiKey
        } catch {
            assertionFailure("Could not decode Keys.plist")
            return nil
        }
    }
    
    func searchIcons(query: String, limit: Int, start: Int, completion: @escaping (Result<([Icon], total: Int), Error>) -> Void) {
        
        guard let apiKey = apiKey else {
            completion(.failure(FreepikServiceError.apiKeyMissing))
            return
        }
        
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
}
