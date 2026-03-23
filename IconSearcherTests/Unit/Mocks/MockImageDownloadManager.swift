import UIKit
@testable import IconSearcher

final class MockImageDownloadManager: ImageDownloadManagerProtocol {
    
    // MARK: - Properties
    
    var downloadedImage: UIImage?
    var downloadCalled = false
    var cancelLoadCalled = false
    var downloadCallCount = 0
    
    // MARK: - ImageDownloadManagerProtocol
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        downloadCalled = true
        downloadCallCount += 1
        DispatchQueue.main.async {
            completion(self.downloadedImage)
        }
    }
    
    func cancelLoad(for url: URL) {
        cancelLoadCalled = true
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        downloadedImage = nil
        downloadCalled = false
        cancelLoadCalled = false
        downloadCallCount = 0
    }
}
