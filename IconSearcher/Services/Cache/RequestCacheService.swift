import UIKit

// MARK: - Orchestrator Cache Service

final class RequestCacheService: RequestCacheServiceProtocol {
    
    
    // MARK: - Properties
    
    private let memoryCache: Cache<String, CacheEntry>
    private let diskCache: DiskCacheServiceProtocol
    private let cacheTTL: TimeInterval = 24 * 60 * 60
    
    // MARK: - Initalization
    
    init(memoryCache: Cache<String, CacheEntry> = .init(),
        diskCache: DiskCacheServiceProtocol = try! DiskCacheService(directoryName: "IconCache")) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        cleanUpCache()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Handler
    
    @objc private func clearMemoryCache() {
        print("Received memory warning. Clearing L1 cache.")
        memoryCache.removeAll()
    }
    
    // MARK: - RequestCacheServiceProtocol
    
    func getCachedResponse(for query: String, completion: @escaping (CachedIconsResponse?) -> Void) {
        if let entry = memoryCache[query], !isStale(entry: entry) {
            completion(entry.response)
            return
        }
            
        diskCache.fetch(forKey: query) { [weak self] (result: Result<CacheEntry?, Error>) in
            guard let self = self else { return }
                
            switch result {
            case .success(let entry):
                guard let entry = entry else {
                    completion(nil)
                    return
                }
                    
                if self.isStale(entry: entry) {
                    self.diskCache.remove(forKey: query, completion: nil)
                    completion(nil)
                    return
                }
               
                self.memoryCache[query] = entry
                completion(entry.response)

            case .failure(let error):
                print("\(error.localizedDescription).")
                self.diskCache.remove(forKey: query, completion: nil)
                completion(nil)
            }
        }
    }
    
    func cacheResponse(_ response: CachedIconsResponse, for query: String) {
        let entry = CacheEntry(response: response, timestamp: Date())
        
        memoryCache[query] = entry
        
        diskCache.save(entry, forKey: query) { error in
            if let error = error {
                print("Failed to save to L2 cache: \(error.localizedDescription)")
            }
        }
    }
    
    func cleanUpCache() {
        diskCache.cleanUp(maxAge: cacheTTL)
    }
    
    // MARK: - Private Methods
    
    private func isStale(entry: CacheEntry) -> Bool {
        Date().timeIntervalSince(entry.timestamp) >= cacheTTL
    }
}
