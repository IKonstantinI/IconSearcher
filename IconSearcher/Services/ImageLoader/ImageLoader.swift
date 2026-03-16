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
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        diskCache.fetch(forKey: url.absoluteString) { [weak self] data in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                self.memoryCache.setObject(image, forKey: url as NSURL)
                completion(image)
                return
            }
            
            if let operation = runningOperations[url] {
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
                
                if let operation = self.runningOperations[url] {
                    operation.completions.forEach { handler in
                        DispatchQueue.main.async { handler(image) }
                    }
                }
                
                self.runningOperations[url] = nil
            }
            
            let operation = ImageLoadOperation(task: task)
            operation.addCompletion(completion)
            runningOperations[url] = operation
            task.resume()
        }
    }
    
    func cancelLoad(for url: URL) {
        if let operation = runningOperations[url] {
            operation.task.cancel()
            runningOperations[url] = nil
        }
    }
}
