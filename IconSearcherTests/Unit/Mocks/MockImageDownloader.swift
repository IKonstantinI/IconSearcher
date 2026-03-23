import UIKit
@testable import IconSearcher

final class MockImageDownloader: ImageDownloaderProtocol {
    
    // MARK: - Properties
    
    var shouldFail = false
    var mockImage = UIImage()
    var downloadCalled = false
    var lastURL: URL?
    var downloadCallCount = 0
    
    enum MockError: LocalizedError {
        case downloadFailed
        
        var errorDescription: String? {
            return "Ошибка загрузки"
        }
    }
    
    // MARK: - ImageDownloading
    
    func downloadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        downloadCalled = true
        lastURL = url
        downloadCallCount += 1
        
        if shouldFail {
            completion(.failure(MockError.downloadFailed))
        } else {
            completion(.success(mockImage))
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        downloadCalled = false
        lastURL = nil
        downloadCallCount = 0
    }
}
