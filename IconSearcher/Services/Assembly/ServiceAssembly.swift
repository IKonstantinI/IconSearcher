import Foundation

enum ServiceAssembly {
    
    // MARK: - ImageLoader
    
    static func makeImageLoader() -> ImageLoader? {
        return ImageLoader.makeDefault()
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
