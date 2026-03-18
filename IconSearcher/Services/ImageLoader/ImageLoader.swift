import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
    func cancelLoad(for url: URL)
}

private class ImageLoadOperation {
    var task: URLSessionDataTask
    var completions = [(UIImage?) -> Void]()
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func addCompletion(_ completion: @escaping (UIImage?) -> Void) {
        completions.append(completion)
    }
}

final class ImageLoader: ImageLoaderProtocol {
    
    // MARK: - Properties
    
    static let shared = ImageLoader()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: ImageCacheService
    private var runningOperations = [URL: ImageLoadOperation]()
    private let operationsQueue = DispatchQueue(label: "com.IconSearcher.imageLoader.operations")
    private let cacheTTL: TimeInterval = 7 * 24 * 60 * 60
    
    // MARK: - Initalization
    
    private init() {
        do {
            self.diskCache = try ImageCacheService()
        } catch {
            fatalError("Failed to initialize ImageCacheService: \(error)")
        }
        self.diskCache.cleanUp(maxAge: cacheTTL)
    }
    
    // MARK: - ImageLoaderProtocol
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let memoryImage = getImageFromMemoryCache(for: url) {
            completion(memoryImage)
            return
        }
        
        getImageFromDiskCache(for: url) { [weak self] diskImage in
            if let diskImage = diskImage {
                completion(diskImage)
                return
            }
            
            self?.downloadImage(for: url, completion: completion)
        }
    }
    
    func cancelLoad(for url: URL) {
        self.operationsQueue.sync {
            if let operation = self.runningOperations[url] {
                operation.task.cancel()
                self.runningOperations[url] = nil
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getImageFromMemoryCache(for url: URL) -> UIImage? {
        return memoryCache.object(forKey: url as NSURL)
    }
    
    private func getImageFromDiskCache(for url: URL, completion: @escaping (UIImage?) -> Void) {
        diskCache.fetch(forKey: url.absoluteString) { data in
            if let data = data, let image = UIImage(data: data) {
                self.memoryCache.setObject(image, forKey: url as NSURL)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    private func downloadImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        operationsQueue.sync {
            if let operation = self.runningOperations[url] {
                operation.addCompletion(completion)
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                let image = data.flatMap { UIImage(data: $0) }
                
                if let image = image, let data = data {
                    self.memoryCache.setObject(image, forKey: url as NSURL)
                    self.diskCache.save(data, forKey: url.absoluteString)
                }
                
                self.operationsQueue.sync {
                    if let operation = self.runningOperations[url] {
                        operation.completions.forEach { handler in
                            DispatchQueue.main.async {
                                handler(image)
                            }
                        }
                    }
                    self.runningOperations[url] = nil
                }
            }
            
            let newOperation = ImageLoadOperation(task: task)
            newOperation.addCompletion(completion)
            self.runningOperations[url] = newOperation
            task.resume()
        }
    }
}
