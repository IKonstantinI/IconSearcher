import UIKit
import os.log

// MARK: - Orchestrator Cache Service

final class RequestCacheService: RequestCacheServiceProtocol {
    
    // MARK: - Logger
    
    private let logger = Logger(
        subsystem: "com.bertoldi.IconSearcher",
        category: "RequestCache"
    )
    
    
    // MARK: - Properties
    
    private let memoryCache: Cache<String, CacheEntry>
    private let diskCache: DiskCacheServiceProtocol
    private let cacheTTL: TimeInterval = 24 * 60 * 60
    
    // MARK: - Initialization

    init(
        memoryCache: Cache<String, CacheEntry> = .init(),
        diskCache: DiskCacheServiceProtocol
    ) throws {
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
    
    convenience init() {
        do {
            let diskCache = try DiskCacheService(directoryName: "IconCache")
            try self.init(diskCache: diskCache)
        } catch {
            fatalError("Failed to create DiskCacheService: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Handler
    
    @objc private func clearMemoryCache() {
        logger.warning("Received memory warning. Clearing L1 cache.")
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
                logger.error("Cache fetch failed: \(error.localizedDescription)")
                self.diskCache.remove(forKey: query, completion: nil)
                completion(nil)
            }
        }
    }

    func cacheResponse(_ response: CachedIconsResponse, for query: String) {
        let entry = CacheEntry(response: response, timestamp: Date())

        memoryCache[query] = entry

        diskCache.save(entry, forKey: query) { [weak self] error in
            if let error = error {
                self?.logger.error("Failed to save to L2 cache: \(error.localizedDescription)")
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
