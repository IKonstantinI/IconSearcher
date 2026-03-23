import UIKit

protocol ImageCachingServiceProtocol {
    func getImage(for url: URL, completion: @escaping (UIImage?) -> Void)
    func saveImage(_ image: UIImage, data: Data, for url: URL)
    func cleanUp(maxAge: TimeInterval)
}
