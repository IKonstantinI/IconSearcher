import Foundation

final class IconifyService {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func searchIcons(query: String, completion: @escaping (Result<[Icon], Error>) -> Void) {
        
        var components = URLComponents(string: "https://api.iconify.design/search")
        components?.queryItems = [URLQueryItem(name: "query", value: query)]
        
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        networkManager.request(url: url) { [weak self] (result: Result<SearchResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let searchResult):
                if searchResult.icons.isEmpty {
                    completion(.success([]))
                    return
                }
                
                self.fetchDetails(or: searchResult.icons, completion: completion)
            }
        }
    }
    
    private func fetchDetails(or iconNames: [String], completion: @escaping (Result<[Icon], Error>) -> Void) {
        
        var iconsMap: [String: Icon] = [:]
        iconNames.forEach { iconsMap[$0] = Icon(fullName: $0) }
        
        let groupedByPrefix = Dictionary(grouping: iconNames, by: { Icon(fullName: $0).collectionPrefix })
        
        let group = DispatchGroup()
        
        var firstError: Error?
        let errorLock = NSLock()
        
        for (prefix, names) in groupedByPrefix {
            let iconNamesOnly = names.map { Icon(fullName: $0).iconName }
            
            var components = URLComponents(string: "https://api.iconify.design/\(prefix).json")
            components?.queryItems = [URLQueryItem(name: "icons", value: iconNamesOnly.joined(separator: ":"))]
            
            guard let url = components?.url else { continue }
            
            group.enter()
            networkManager.request(url: url) { (result: Result<IconDetailResponse, Error>) in
                switch result {
                case .success(let detailResponse):
                    for (iconName, metaData) in detailResponse.icons {
                        let fullName = "\(prefix):\(iconName)"
                        iconsMap[fullName]?.width = detailResponse.width
                        iconsMap[fullName]?.height = detailResponse.height
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
                completion(.success(finalIcons))
            }
        }
    }
}
