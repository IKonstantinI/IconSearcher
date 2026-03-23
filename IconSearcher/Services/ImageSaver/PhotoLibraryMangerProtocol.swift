import UIKit

protocol PhotoLibraryManagerProtocol {
    func saveImage(
        _ image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

