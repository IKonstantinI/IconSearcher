import UIKit

protocol ImageDownloadManagerProtocol {

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void)

    func cancelLoad(for url: URL)
}

