import UIKit

final class ImageLoader: @unchecked Sendable, ImageLoaderProtocol {
    
    // MARK: - Properties
    
    private let cache: ImageCachingServiceProtocol
    private let downloader: ImageDownloadManagerProtocol
    private let cacheTTL: TimeInterval
    
    // MARK: - Initialization

    init(
        cache: ImageCachingServiceProtocol = ImageCachingService(
            diskCache: try! ImageCacheService()
        ),
        downloader: ImageDownloadManagerProtocol = ImageDownloadManager(),
        cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    ) {
        self.cache = cache
        self.downloader = downloader
        self.cacheTTL = cacheTTL
        
        self.cache.cleanUp(maxAge: cacheTTL)
    }
    
    // MARK: - ImageLoaderProtocol
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        cache.getImage(for: url) { [weak self] cachedImage in
            if let cachedImage = cachedImage {
                completion(cachedImage)
                return
            }
            
            self?.downloadAndCacheImage(from: url, completion: completion)
        }
    }
    
    func cancelLoad(for url: URL) {
        downloader.cancelLoad(for: url)
    }
    
    // MARK: - Private Methods
    
    private func downloadAndCacheImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        downloader.downloadImage(from: url) { [weak self] image in
            guard let self = self,
                  let image = image,
                  let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
                completion(nil)
                return
            }
            
            self.cache.saveImage(image, data: data, for: url)
            
            completion(image)
        }
    }
}
