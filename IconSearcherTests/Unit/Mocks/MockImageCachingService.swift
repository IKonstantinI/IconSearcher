import UIKit
@testable import IconSearcher

final class MockImageCachingService: ImageCachingServiceProtocol {
    
    // MARK: - Properties
    
    var cachedImage: UIImage?
    var getImageCalled = false
    var saveImageCalled = false
    var cleanUpCalled = false
    
    var getImageCallCount = 0
    var saveImageCallCount = 0
    
    // MARK: - ImageCachingServiceProtocol
    
    func getImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        getImageCalled = true
        getImageCallCount += 1
        DispatchQueue.main.async {
            completion(self.cachedImage)
        }
    }
    
    func saveImage(_ image: UIImage, data: Data, for url: URL) {
        saveImageCalled = true
        saveImageCallCount += 1
    }
    
    func cleanUp(maxAge: TimeInterval) {
        cleanUpCalled = true
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        cachedImage = nil
        getImageCalled = false
        saveImageCalled = false
        cleanUpCalled = false
        getImageCallCount = 0
        saveImageCallCount = 0
    }
}
