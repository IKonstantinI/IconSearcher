import Foundation

enum ServiceAssembly {
    
    // MARK: - ImageLoader
    
    static func makeImageLoader() -> ImageLoader {
        do {
            let diskCache = try ImageCacheService()
            let cache = ImageCachingService(diskCache: diskCache)
            let downloader = ImageDownloadManager()
            return ImageLoader(cache: cache, downloader: downloader)
        } catch {
            fatalError("Failed to create ImageLoader: \(error)")
        }
    }
    
    static func makeImageLoader(
        diskCache: ImageCacheService,
        session: URLSession = .shared,
        cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    ) -> ImageLoader {
        let cache = ImageCachingService(diskCache: diskCache)
        let downloader = ImageDownloadManager(session: session)
        return ImageLoader(cache: cache, downloader: downloader, cacheTTL: cacheTTL)
    }
}
