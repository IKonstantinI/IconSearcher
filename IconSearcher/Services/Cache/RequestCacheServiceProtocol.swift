import Foundation

// MARK: - Cache Models

final class CacheEntry: Codable {
    let response: CachedIconsResponse
    let timestamp: Date
    init(response: CachedIconsResponse, timestamp: Date) {
        self.response = response
        self.timestamp = timestamp
    }
}

final class CachedIconsResponse: Codable {
    let icons: [Icon]
    let total: Int
    init(icons: [Icon], total: Int) {
        self.icons = icons
        self.total = total
    }
}

// MARK: - Protocol

protocol RequestCacheServiceProtocol {
    func getCachedResponse(for query: String, completion: @escaping (CachedIconsResponse?) -> Void)
    func cacheResponse(_ response: CachedIconsResponse, for query: String)
    func cleanUpCache()
}
