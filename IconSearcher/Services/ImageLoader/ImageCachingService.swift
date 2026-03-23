import UIKit

final class ImageCachingService: ImageCachingServiceProtocol {
    
    // MARK: - Properties
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: ImageCacheService
    private let cacheQueue = DispatchQueue(label: "com.IconSearcher.imageCache.operations")
    
    // MARK: - Initialization
    
    init(diskCache: ImageCacheService) {
        self.diskCache = diskCache
    }
    
    // MARK: - ImageCachingServiceProtocol
    
    func getImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if let memoryImage = getFromMemoryCache(for: url) {
            completion(memoryImage)
            return
        }
        
        getFromDiskCache(for: url) { [weak self] diskImage in
            if let diskImage = diskImage {
                self?.saveToMemoryCache(diskImage, for: url)
                completion(diskImage)
            } else {
                completion(nil)
            }
        }
    }
    
    func saveImage(_ image: UIImage, data: Data, for url: URL) {
        saveToMemoryCache(image, for: url)
        
        saveToDiskCache(data, for: url)
    }
    
    func cleanUp(maxAge: TimeInterval) {
        diskCache.cleanUp(maxAge: maxAge)
    }
    
    // MARK: - Private Methods - Memory Cache
    
    private func getFromMemoryCache(for url: URL) -> UIImage? {
        return memoryCache.object(forKey: url as NSURL)
    }
    
    private func saveToMemoryCache(_ image: UIImage, for url: URL) {
        memoryCache.setObject(image, forKey: url as NSURL)
    }
    
    // MARK: - Private Methods - Disk Cache
    
    private func getFromDiskCache(for url: URL, completion: @escaping (UIImage?) -> Void) {
        diskCache.fetch(forKey: url.absoluteString) { data in
            guard let data = data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }
    
    private func saveToDiskCache(_ data: Data, for url: URL) {
        diskCache.save(data, forKey: url.absoluteString, completion: nil)
    }
}

