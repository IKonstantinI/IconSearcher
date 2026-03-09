import UIKit
import Photos

final class ImageSaver {
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
    
    
    func saveImage(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data, UIImage(data: data) != nil else {
                let downloadError = URLError(.badServerResponse)
                DispatchQueue.main.async { completion(.failure(downloadError)) }
                return
            }
            
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized else {
                    DispatchQueue.main.async { completion(.failure(ImageSaverError.permissionDenied)) }
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, data: data, options: nil)
                }) { success, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else if success {
                            completion(.success(()))
                        } else {
                            completion(.failure(ImageSaverError.unknownSaveError))
                        }
                    }
                }
            }
        }.resume()
    }
}
