import Foundation

final class FreepikService: IconServiceProtocol {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func searchIcons(query: String, limit: Int, start: Int, completion: @escaping (Result<([Icon], total: Int), any Error>) -> Void) {
        var components = URLComponents(string: "https://api.iconify.design/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "start", value: String(start))
        ]
        
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        networkManager.request(url: url) { [weak self] (result: Result<SearchResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                if result.icons.isEmpty {
                    completion(.success(([], 0)))
                    return
                }
                self.fetchDetails(or: result.icons, total: result.total, completion: completion)
            }
        }
    }
    
    private func fetchDetails(or iconNames: [String], total: Int, completion: @escaping (Result<([Icon], total: Int), Error>) -> Void) {
        
        var iconsMap: [String: Icon] = [:]
        iconNames.forEach { iconsMap[$0] = Icon(fullName: $0) }
        
        let groupedByPrefix = Dictionary(grouping: iconNames, by: { Icon(fullName: $0).collectionPrefix })
        
        let group = DispatchGroup()
        
        var firstError: Error?
        let errorLock = NSLock()
        
        for (prefix, names) in groupedByPrefix {
            let iconNamesOnly = names.map { Icon(fullName: $0).iconName }
            
            var components = URLComponents(string: "https://api.iconify.design/\(prefix).json")
            components?.queryItems = [URLQueryItem(name: "icons", value: iconNamesOnly.joined(separator: ","))]
            
            guard let url = components?.url else { continue }
            
            group.enter()
            networkManager.request(url: url) { (result: Result<IconDetailResponse, Error>) in
                switch result {
                case .success(let detailResponse):
                    for (iconName, metaData) in detailResponse.icons {
                        let fullName = "\(prefix):\(iconName)"
                        iconsMap[fullName]?.width = detailResponse.width > 0 ? detailResponse.width : 24
                        iconsMap[fullName]?.height = detailResponse.height > 0 ? detailResponse.height : 24
                        iconsMap[fullName]?.tags = metaData.tags ?? []
                    }
                case .failure(let error):
                    errorLock.lock()
                    if firstError == nil { firstError = error }
                    errorLock.unlock()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = firstError {
                completion(.failure(error))
            } else {
                let finalIcons = iconNames.compactMap { iconsMap[$0] }
                completion(.success((finalIcons, total)))
            }
        }
    }
}
