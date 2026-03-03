import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
    func cancelLoad()
}

final class ImageLoader: ImageLoaderProtocol {
    private let cache = Cache<URL, UIImage>()
    private var currentTask: URLSessionDataTask?
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.value(forKey: url) {
            completion(cachedImage)
            return
        }
        
        currentTask?.cancel()
        
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let image = UIImage(data: data) else { return }
            self?.cache.setValue(image, forKey: url)
            
            DispatchQueue.main.async { completion(image) }
        }
        
        currentTask?.resume()
    }
    
    func cancelLoad() {
        currentTask?.cancel()
        currentTask = nil
    }
}
