import Foundation

//MARK: - Protocol

protocol IconRepositoryProtocol {
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    )
}

// MARK: - Implementation

final class IconRepository: IconRepositoryProtocol {
    
    // MARK: - Properties
    
    private let networkService: IconServiceProtocol
    private let cacheService: RequestCacheServiceProtocol
    
    // MARK: - Initalization

    init(
        networkService: IconServiceProtocol,
        cacheService: RequestCacheServiceProtocol
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    convenience init() {
        guard let networkService = FreepikServiceFactory.makeDefault() else {
            fatalError("Failed to create FreepikService. Check Keys.plist")
        }
        
        let cacheService = RequestCacheService()
        self.init(
            networkService: networkService,
            cacheService: cacheService
        )
    }
    
    // MARK: - Public Methods
    
    func searchIcons(
        query: String,
        limit: Int,
        start: Int,
        completion: @escaping (Result<([Icon], total: Int), Error>) -> Void
    ) {
        if start > 0 {
            networkService.searchIcons(query: query, limit: limit, start: start, completion: completion)
            return
        }
        
        cacheService.getCachedResponse(for: query) { [weak self] cachedData in
            guard self != nil else { return }
            
            if let cachedData = cachedData {
                completion(.success((cachedData.icons, total: cachedData.total)))
                return
            }
        }
        
        networkService.searchIcons(query: query, limit: limit, start: start) { result in
            switch result {
            case .success(let (icons, total)):
                if start == 0 {
                    let responseToCache = CachedIconsResponse(icons: icons, total: total)
                    self.cacheService.cacheResponse(responseToCache, for: query)
                }
                completion(.success((icons, total: total)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
