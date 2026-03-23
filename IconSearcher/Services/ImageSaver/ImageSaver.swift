import UIKit

final class ImageSaver: @unchecked Sendable, ImageSaverProtocol {
    
    // MARK: - Properties
    
    private let downloader: ImageDownloaderProtocol
    private let photoManager: PhotoLibraryManagerProtocol
    
    // MARK: - Initialization
    

    init(
        downloader: ImageDownloaderProtocol = ImageDownloader(),
        photoManager: PhotoLibraryManagerProtocol = PhotoLibraryManager()
    ) {
        self.downloader = downloader
        self.photoManager = photoManager
    }
    
    // MARK: - Public Methods

    func saveImage(
        from url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        downloader.downloadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.photoManager.saveImage(image, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

