import UIKit

protocol ImageLoaderProtocol {

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)

    func cancelLoad(for url: URL)
}

