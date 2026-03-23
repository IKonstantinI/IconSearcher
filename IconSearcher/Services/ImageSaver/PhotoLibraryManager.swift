import Photos
import UIKit

final class PhotoLibraryManager: PhotoLibraryManagerProtocol {
    
    enum SaveError: LocalizedError {
        case permissionDenied
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Доступ к галерее запрещен. Пожалуйста, разрешите доступ в Настройках."
            case .unknownError:
                return "Не удалось сохранить изображение по неизвестной причине."
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - PhotoLibraryManaging
    
    func saveImage(
        _ image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(.failure(SaveError.permissionDenied))
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(SaveError.unknownError))
                    }
                }
            }
        }
    }
}
