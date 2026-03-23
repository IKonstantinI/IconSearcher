import UIKit

final class ImageDownloadManager: ImageDownloadManagerProtocol {
    
    // MARK: - ImageLoadOperation
    
    private final class ImageLoadOperation {
        var task: URLSessionDataTask
        var completions = [(UIImage?) -> Void]()
        
        init(task: URLSessionDataTask) {
            self.task = task
        }
        
        func addCompletion(_ completion: @escaping (UIImage?) -> Void) {
            completions.append(completion)
        }
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    private var runningOperations = [URL: ImageLoadOperation]()
    private let operationsQueue = DispatchQueue(label: "com.IconSearcher.imageDownloader.operations")
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - ImageDownloadManagerProtocol
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        operationsQueue.sync {
            if let operation = runningOperations[url] {
                operation.addCompletion(completion)
                return
            }
            
            let task = session.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                
                let image = data.flatMap { UIImage(data: $0) }
                
                self.completeOperation(for: url, with: image)
            }
            
            let newOperation = ImageLoadOperation(task: task)
            newOperation.addCompletion(completion)
            runningOperations[url] = newOperation
            
            task.resume()
        }
    }
    
    func cancelLoad(for url: URL) {
        operationsQueue.sync {
            if let operation = runningOperations[url] {
                operation.task.cancel()
                runningOperations[url] = nil
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func completeOperation(for url: URL, with image: UIImage?) {
        operationsQueue.sync {
            guard let operation = runningOperations[url] else {
                return
            }
            
            operation.completions.forEach { handler in
                DispatchQueue.main.async {
                    handler(image)
                }
            }
            
            runningOperations[url] = nil
        }
    }
}

