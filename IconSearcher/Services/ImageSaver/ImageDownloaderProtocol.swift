import UIKit

protocol ImageDownloaderProtocol {
    func downloadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}
