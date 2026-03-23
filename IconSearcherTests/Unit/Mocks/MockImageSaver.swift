import Foundation
@testable import IconSearcher

final class MockImageSaver: ImageSaverProtocol {
    
    var shouldFail = false
    
    var saveImageCalled = false
    
    var lastSavedURL: URL?
    
    var saveImageCallCount = 0
    
    var completionToReturn: Result<Void, Error>?
    
    func saveImage(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        saveImageCalled = true
        lastSavedURL = url
        saveImageCallCount += 1
        
        if let completionToReturn = completionToReturn {
            completion(completionToReturn)
            return
        }
        
        if shouldFail {
            completion(.failure(ImageSaverError.unknownSaveError))
        } else {
            completion(.success(()))
        }
    }
    
    enum ImageSaverError: LocalizedError {
        case permissionDenied
        case unknownSaveError
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Доступ к галерее запрещен. Пожалуйста, разрешите доступ в Настройках."
            case .unknownSaveError:
                return "Не удалось сохранить изображение по неизвестной причине."
            }
        }
    }
}
