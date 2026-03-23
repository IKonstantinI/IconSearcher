import UIKit

final class ImageDownloader: ImageDownloaderProtocol {
    
    enum DownloadError: LocalizedError {
        case noData
        case invalidImage
        case httpError(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .noData:
                return "Нет данных"
            case .invalidImage:
                return "Некорректное изображение"
            case .httpError(let statusCode):
                return "HTTP ошибка: \(statusCode)"
            }
        }
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - ImageDownloading
    
    func downloadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        session.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(DownloadError.noData))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(DownloadError.httpError(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(DownloadError.invalidImage))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }
}
