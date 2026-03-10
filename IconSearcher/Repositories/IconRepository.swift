import Foundation

protocol IconRepositoryProtocol {
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    )
}

final class IconRepository: IconRepositoryProtocol {
    private let networkService: IconServiceProtocol
    private let cacheService: RequestCacheServiceProtocol
    
    init(
        networkService: IconServiceProtocol = FreepikService(),
        cacheService: RequestCacheServiceProtocol = RequestCacheService()
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    ) {
        if start > 0 {
            print("Пагинация: запрос '\(query)' идет в сеть.")
            networkService.searchIcons(query: query, limit: limit, start: start, completion: completion)
            return
        }
        
        if let cachedData = cacheService.getCachedResponse(for: query) {
            print("Запрос '\(query)': данные найдены в кеше.")
            completion(.success((cachedData.icons, total: cachedData.total)))
            return
        }
        
        print("Запрос '\(query)': кеш пуст, идем в сеть.")
        networkService.searchIcons(query: query, limit: limit, start: start) { [weak self] result in
            switch result {
            case .success(let (icons, total)):
                let responseToCache = CachedIconsResponse(icons: icons, total: total)
                self?.cacheService.cacheResponse(responseToCache, for: query)
                completion(.success((icons, total: total)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
