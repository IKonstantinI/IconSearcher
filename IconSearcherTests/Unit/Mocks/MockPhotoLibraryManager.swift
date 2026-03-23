import UIKit
@testable import IconSearcher

final class MockPhotoLibraryManager: PhotoLibraryManagerProtocol {
    
    // MARK: - Properties
    
    var shouldFail = false
    var saveCalled = false
    var lastImage: UIImage?
    var saveCallCount = 0
    
    enum MockError: LocalizedError {
        case saveFailed
        
        var errorDescription: String? {
            return "Ошибка сохранения"
        }
    }
    
    // MARK: - PhotoLibraryManaging
    
    func saveImage(
        _ image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        saveCalled = true
        lastImage = image
        saveCallCount += 1
        
        if shouldFail {
            completion(.failure(MockError.saveFailed))
        } else {
            completion(.success(()))
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        saveCalled = false
        lastImage = nil
        saveCallCount = 0
    }
}
